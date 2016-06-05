//
//  MifareClassic.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

enum NfcType : UInt8 {
    case None = 0
    case MifareClassic1K = 0x08
    case MifareMini = 0x09
    case MifareClassic4K = 0x18
    case DesFire = 0x20
}

//MARK: - Equatable
func ==(lhs: MifareClassic, rhs: MifareClassic) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class MifareClassic : Hashable, CustomStringConvertible {
    static let sectorSize : Int = 4 //Blocks
    static let sectorCount : Int = 0x10
    static let blockCount : Int = sectorSize * sectorCount
    static let blockSize : Int = 0x10
    static let tokenSize : Int = blockSize * blockCount
    
    static let rw_sector = NSData(fromHex: "00 00 00 00 00 00 7F 0F 08 69 ff ff ff ff ff ff")
    static let ro_sector = NSData(fromHex: "00 00 00 00 00 00 0F 0F 0F 69 ff ff ff ff ff ff")
    static let emptyBlock = NSData(fromHex: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00")
    
    //let sector_trailor = NSData(bytes: [0, 0, 0, 0, 0, 0, 0x77, 0x87, 0x88, 0, 0, 0, 0, 0, 0, 0] as [UInt8], length: MifareClassic.blockSize)
    
    var nfcType : NfcType = .MifareClassic1K
    var uid : NSData
    var data : NSMutableData = NSMutableData()
    
    var filename : String {
        get {
            return "\(uid.toHex).bin"
        }
    }
    
    var description: String {
        let me = String(self.dynamicType).componentsSeparatedByString(".").last!
        return "\(me)(\(uid.toHex))"
    }
    
    init(uid: NSData) {
        self.uid = uid
        if (self.data.length > 3) { //Replace bytes
            self.data.replaceBytesInRange(NSMakeRange(0, 4), withBytes: uid.bytes)
        } else { //Add bytes
            self.data.appendData(uid)
            self.data.appendData(NSData(bytes: [UInt8](count: max(0, MifareClassic.blockSize - self.data.length), repeatedValue:0)))
        }
    }
    
    
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return uid.hashValue
        }
    }
    
    func nextBlock() -> Int {
        return data.length / MifareClassic.blockSize
    }
    
    func complete() -> Bool{
        return (nextBlock() == MifareClassic.blockCount)
    }
    
    func block(blockNumber: UInt8) -> NSData {
        return block(Int(blockNumber))
    }
    
    func block(blockNumber: Int) -> NSData {
        let blockStart = blockNumber * MifareClassic.blockSize
        let blockRange = NSMakeRange(blockStart, MifareClassic.blockSize)
        return data.subdataWithRange(blockRange)
    }
    
    func load(blockNumber: Int, blockData: NSData) {
        if (blockNumber == nextBlock()) {
            data.appendData(blockData)
        } else {
            let blockRange = NSMakeRange(blockNumber * MifareClassic.blockSize, MifareClassic.blockSize)
            data.replaceBytesInRange(blockRange, withBytes: blockData.bytes)
        }
        
    }
    
    func load(blockNumber: UInt8, blockData: NSData) {
        load(Int(blockNumber), blockData: blockData)
    }
    
    func sectorTrailer(blockNumber : Int) -> Bool {
        return (blockNumber + 1) % 4 == 0
    }
    
    func dump(path: NSURL) {
        data.writeToURL(path.URLByAppendingPathComponent(filename), atomically: true)
    }
}