//
//  Token.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

class Token : MifareClassic {
    static let fileManager = NSFileManager()
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let BINARY = 2
    let HEX = 0x10
    
    override var description: String {
        let me = String(self.dynamicType).componentsSeparatedByString(".").last!
        return "\(me)(\(uid.toHex) - \(name))"
    }
    
    override var filename : String {
        get {
            return "\(uid.toHex)-\(name).bin"
        }
    }

    //Also known as 'ID' or 'type'.  I wanted to avoid those terms because of their alternate meanings
    var modelId : UInt16 {
        get {
            return block(1).subdataWithRange(NSMakeRange(0, 2)).uint16
        }
        set(newModelId) {
            //Assume this is happening on a zero'd out new token
            var m = newModelId
            let newBlock = block(1).mutableCopy()
            newBlock.replaceBytesInRange(NSMakeRange(0, 2), withBytes: &m)
            load(1, blockData: newBlock as! NSData)
            updateCrc()
        }
    }
    
    var flags : UInt16 {
        get {
            return block(1).subdataWithRange(NSMakeRange(12, 2)).uint16
        }
        set (newFlags) {
            //Assume this is happening on a zero'd out new token
            var m = newFlags
            let newBlock = block(1).mutableCopy()
            newBlock.replaceBytesInRange(NSMakeRange(12, 2), withBytes: &m)
            load(1, blockData: newBlock as! NSData)
            updateCrc()
        }
    }
    
    var model : Model {
        get {
            return Model(id: UInt(modelId), flags: flags)
        }
        set (newModel) {
            self.modelId = UInt16(newModel.id)
            self.flags = newModel.flags
        }
    }
    
    var name : String {
        get {
            return model.name
        }
    }
    
    var role : Role {
        get {
            return model.role
        }
    }
    
    var series : Series {
        get {
            return model.series
        }
    }
    
    var color : UIColor {
        get {
            return model.color
        }
    }
    
    var symbol : String {
        get {
            return model.symbol
        }
    }
    
    var sequenceA : UInt8 {
        get {
            return decryptedBlock(0x08)[9]
        }
    }
    
    var sequenceB : UInt8 {
        get {
            return decryptedBlock(0x24)[9]
        }
    }
    
    var primaryAreaNumber : Int {
        get {
            return (sequenceA > sequenceB) ? 0x08 : 0x24
        }
    }
    
    convenience init(image: NSData) {
        self.init(uid: image.subdataWithRange(NSMakeRange(0, 4)))
        self.data = image.mutableCopy() as! NSMutableData
    }

    func primaryData(offset: Int) -> NSData {
        return decryptedBlock(primaryAreaNumber + offset)
    }
    
    func decryptedBlock(blockNumber: Int) -> NSData {
        return decrypt(blockNumber, blockData: block(blockNumber))
    }
    
    //Never return keys in sector trailor
    override func block(blockNumber: Int) -> NSData {
        if (blockNumber == 3) {
            return MifareClassic.ro_sector
        } else if (blockNumber % 4 == 3) {
            return MifareClassic.rw_sector
        } else {
            return super.block(blockNumber)
        }
    }
    
    func skipEncryption(blockNumber: Int, blockData: NSData) -> Bool {
        if (blockData.length != MifareClassic.blockSize) {
            print("blockData must be exactly \(MifareClassic.blockSize) bytes")
            return true
        }
        return (blockNumber < 8 || sectorTrailer(blockNumber) || blockData.isEqualToData(MifareClassic.emptyBlock))
    }
    
    func keyForBlock(blockNumber: Int) -> NSData {
        return keyForBlock(UInt8(blockNumber))
    }
    
    func keyForBlock(blockNumber: UInt8) -> NSData {
        let suffix : String = " Pbclevtug (P) 2010 Npgvivfvba. Nyy Evtugf Erfreirq. "
        let preKey = NSMutableData()
        preKey.appendData(block(0))
        preKey.appendData(block(1))
        preKey.appendByte(blockNumber)
        preKey.appendData(suffix.rot13.dataUsingEncoding(NSUTF8StringEncoding)!)
        return NSData(data: preKey).md5()
    }
    
    func updateCrc(index : Int = 0) {
        let input = NSMutableData()
        switch (index) {
        case 0:
            let block1 = block(1).subdataWithRange(NSMakeRange(0, 14)).mutableCopy()
            input.appendData(block(0))
            input.appendData(block1 as! NSData)
            block1.appendData(input.crcCCITT)
            load(1, blockData: block1 as! NSData)
        case 1:
            let primary0 = primaryData(0).subdataWithRange(NSMakeRange(0, 14)).mutableCopy()
            input.appendData(primary0 as! NSData)
            input.appendByte(5)
            input.appendByte(0)
            
            primary0.appendData(input.crcCCITT)
            //print("primary0 = \(primary0) vs \(primaryData(0))")
            //print("encrypted primary0 = \(encrypt(primaryAreaNumber, blockData: primary0 as! NSData)) vs \(block(primaryAreaNumber))")
            load(primaryAreaNumber, blockData: encrypt(primaryAreaNumber, blockData: primary0 as! NSData))
        default:
            print("CRC Index \(index) is not supported")
        }
    }
    
    func decrypt(blockNumber: Int, blockData: NSData) -> NSData {
        return commonCrypt(blockNumber, blockData: blockData, encrypt: false)
    }
    
    func encrypt(blockNumber: Int, blockData: NSData) -> NSData {
        return commonCrypt(blockNumber, blockData: blockData, encrypt: true)
    }
    
    func commonCrypt(blockNumber: Int, blockData: NSData, encrypt: Bool) -> NSData {
        if (skipEncryption(blockNumber, blockData: blockData)) {
            return blockData
        }
        let key = self.keyForBlock(blockNumber)
        
        let aes = try! AES(key: key.arrayOfBytes(), blockMode: .ECB, padding: NoPadding())
        var newBytes : [UInt8]
        
        if (encrypt) {
            newBytes = try! aes.encrypt(blockData.arrayOfBytes())
        } else {
            newBytes = try! aes.decrypt(blockData.arrayOfBytes())
        }
        
        return NSData(bytes: newBytes)
    }
    
    //Return instance of correct subclass
    static func factory(data: NSData) -> Token {
        let t = Token(image: data)
        switch(t.role) {
        case .Skylander:
            return SkylanderToken(image: data)
        case .Giant:
            return SkylanderToken(image: data)
        case .TrapMaster:
            return SkylanderToken(image: data)
        case .SWAPForce:
            return SkylanderToken(image: data)
        case .SuperCharger:
            return SkylanderToken(image: data)
        case .Sidekick:
            return SkylanderToken(image: data)
        case .Mini:
            return SkylanderToken(image: data)
        //case .Vehicle:
        //case .MagicItem: //Includes Traps, includes AdventurePacks
    
        default:
            return t
        }
    }
    
    static func build(model: Model) -> Token {
        var random = arc4random()
        let uid = NSData(bytes: &random, length: sizeof(UInt32))
        let token = Token(uid: uid)

        (1..<MifareClassic.blockCount).forEach { (blockNumber) in
            if (blockNumber == 3) {
                token.load(blockNumber, blockData: ro_sector)
            } else if (blockNumber % 4 == 3) {
                token.load(blockNumber, blockData: rw_sector)
            } else {
                token.load(blockNumber, blockData: emptyBlock)
            }
        }
        
        token.model = model
        
        return token
    }
    
    static func all() -> [Token] {
        var fileList = [Token]()
        
        let files = self.fileManager.enumeratorAtURL(
            self.appDelegate.applicationDocumentsDirectory,
            includingPropertiesForKeys: nil,
            options: NSDirectoryEnumerationOptions.SkipsHiddenFiles,
            errorHandler: nil)
        
        if let files = files {
            for file in files {
                if file.absoluteString.hasSuffix("bin") { // checks the extension
                    if let image = NSData(contentsOfURL: file as! NSURL) {
                        if (image.length == MifareClassic.tokenSize) {
                            fileList.append(Token.factory(image))
                        }
                    }
                }
            }
        }
        
        
        fileList.sortInPlace({ (a, b) -> Bool in
            return a.modelId > b.modelId
        })
        return fileList
    }
    
}