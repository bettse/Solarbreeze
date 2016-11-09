//
//  MifareClassic.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

enum NfcType : UInt8 {
    case none = 0
    case mifareClassic1K = 0x08
    case mifareMini = 0x09
    case mifareClassic4K = 0x18
    case desFire = 0x20
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
    
    static let rw_sector = Data(fromHex: "00 00 00 00 00 00 7F 0F 08 69 ff ff ff ff ff ff")
    static let ro_sector = Data(fromHex: "00 00 00 00 00 00 0F 0F 0F 69 ff ff ff ff ff ff")
    static let emptyBlock = Data(fromHex: "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00")
    
    //let sector_trailor = NSData(bytes: [0, 0, 0, 0, 0, 0, 0x77, 0x87, 0x88, 0, 0, 0, 0, 0, 0, 0] as [UInt8], length: MifareClassic.blockSize)
    
    var nfcType : NfcType = .mifareClassic1K
    var uid : Data
    var data : Data = Data()
    
    var filename : String {
        get {
            return "\(uid.toHex).bin"
        }
    }
    
    var description: String {
        let me = String(describing: type(of: self)).components(separatedBy: ".").last!
        return "\(me)(\(uid.toHex))"
    }
    
    init(uid: Data) {
        self.uid = uid
        self.data = Data(capacity: MifareClassic.tokenSize)
        self.data.replaceSubrange(0..<4, with: uid)        
    }
    
    
    //MARK: - Hashable
    var hashValue : Int {
        get {
            return uid.hashValue
        }
    }
    
    func block(_ blockNumber: UInt8) -> Data {
        return block(Int(blockNumber))
    }
    
    func block(_ blockNumber: Int) -> Data {
        let blockStart = blockNumber * MifareClassic.blockSize
        return data.subdata(in: blockStart..<(blockStart+MifareClassic.blockSize))
    }
    
    func load(_ blockNumber: Int, blockData: Data) {
        let blockStart = blockNumber * MifareClassic.blockSize
        data.replaceSubrange(blockStart..<(blockStart+MifareClassic.blockSize), with: blockData)
    }
    
    func load(_ blockNumber: UInt8, blockData: Data) {
        load(Int(blockNumber), blockData: blockData)
    }
    
    func sectorTrailer(_ blockNumber : Int) -> Bool {
        return (blockNumber + 1) % 4 == 0
    }
    
    func dump(_ path: URL) {
        do {
            try data.write(to: path.appendingPathComponent(filename), options: .atomic)
        } catch {
        }
    }
}
