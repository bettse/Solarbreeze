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
    static let fileManager = FileManager()
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let BINARY = 2
    let HEX = 0x10
    
    override var description: String {
        let me = String(describing: type(of: self)).components(separatedBy: ".").last!
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
            return block(1).subdata(in: NSMakeRange(0, 2)).uint16
        }
        set(newModelId) {
            //Assume this is happening on a zero'd out new token
            var m = newModelId
            let newBlock = (block(1) as NSData).mutableCopy()
            (newBlock as AnyObject).replaceBytes(in: NSMakeRange(0, 2), withBytes: &m)
            load(1, blockData: newBlock as! Data)
            updateCrc()
        }
    }
    
    var flags : UInt16 {
        get {
            return block(1).subdata(in: NSMakeRange(12, 2)).uint16
        }
        set (newFlags) {
            //Assume this is happening on a zero'd out new token
            var m = newFlags
            let newBlock = (block(1) as NSData).mutableCopy()
            (newBlock as AnyObject).replaceBytes(in: NSMakeRange(12, 2), withBytes: &m)
            load(1, blockData: newBlock as! Data)
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
    
    convenience init(image: Data) {
        self.init(uid: image.subdata(in: NSMakeRange(0, 4)))
        self.data = (image as NSData).mutableCopy() as! NSMutableData
    }

    func primaryData(_ offset: Int) -> Data {
        return decryptedBlock(primaryAreaNumber + offset)
    }
    
    func decryptedBlock(_ blockNumber: Int) -> Data {
        return decrypt(blockNumber, blockData: block(blockNumber))
    }
    
    //Never return keys in sector trailor
    override func block(_ blockNumber: Int) -> Data {
        if (blockNumber == 3) {
            return MifareClassic.ro_sector as Data
        } else if (blockNumber % 4 == 3) {
            return MifareClassic.rw_sector as Data
        } else {
            return super.block(blockNumber)
        }
    }
    
    func skipEncryption(_ blockNumber: Int, blockData: Data) -> Bool {
        if (blockData.count != MifareClassic.blockSize) {
            print("blockData must be exactly \(MifareClassic.blockSize) bytes")
            return true
        }
        return (blockNumber < 8 || sectorTrailer(blockNumber) || (blockData == MifareClassic.emptyBlock))
    }
    
    func keyForBlock(_ blockNumber: Int) -> Data {
        return keyForBlock(UInt8(blockNumber))
    }
    
    func keyForBlock(_ blockNumber: UInt8) -> Data {
        let suffix : String = " Pbclevtug (P) 2010 Npgvivfvba. Nyy Evtugf Erfreirq. "
        let preKey = NSMutableData()
        preKey.append(block(0))
        preKey.append(block(1))
        preKey.appendByte(blockNumber)
        preKey.append(suffix.rot13.data(using: String.Encoding.utf8)!)
        return (NSData(data: preKey as Data) as Data).md5()
    }
    
    func updateCrc(_ index : Int = 0) {
        let input = NSMutableData()
        switch (index) {
        case 0:
            let block1 = (block(1).subdata(in: NSMakeRange(0, 14)) as NSData).mutableCopy()
            input.append(block(0))
            input.append(block1 as! Data)
            block1.append(input.crcCCITT)
            load(1, blockData: block1 as! Data)
        case 1:
            let primary0 = (primaryData(0).subdata(in: NSMakeRange(0, 14)) as NSData).mutableCopy()
            input.append(primary0 as! Data)
            input.appendByte(5)
            input.appendByte(0)
            
            primary0.append(input.crcCCITT)
            //print("primary0 = \(primary0) vs \(primaryData(0))")
            //print("encrypted primary0 = \(encrypt(primaryAreaNumber, blockData: primary0 as! NSData)) vs \(block(primaryAreaNumber))")
            load(primaryAreaNumber, blockData: encrypt(primaryAreaNumber, blockData: primary0 as! Data))
        default:
            print("CRC Index \(index) is not supported")
        }
    }
    
    func decrypt(_ blockNumber: Int, blockData: Data) -> Data {
        return commonCrypt(blockNumber, blockData: blockData, encrypt: false)
    }
    
    func encrypt(_ blockNumber: Int, blockData: Data) -> Data {
        return commonCrypt(blockNumber, blockData: blockData, encrypt: true)
    }
    
    func commonCrypt(_ blockNumber: Int, blockData: Data, encrypt: Bool) -> Data {
        if (skipEncryption(blockNumber, blockData: blockData)) {
            return blockData
        }
        let key = self.keyForBlock(blockNumber)
        
        let aes = try! AES(key: key.arrayOfBytes(), blockMode: .ecb, padding: NoPadding())
        var newBytes : [UInt8]
        
        if (encrypt) {
            newBytes = try! aes.encrypt(blockData.arrayOfBytes())
        } else {
            newBytes = try! aes.decrypt(blockData.arrayOfBytes())
        }
        
        return Data(bytes: newBytes)
    }
    
    //Return instance of correct subclass
    static func factory(_ data: Data) -> Token {
        let t = Token(image: data)
        switch(t.role) {
        case .skylander:
            return SkylanderToken(image: data)
        case .giant:
            return SkylanderToken(image: data)
        case .trapMaster:
            return SkylanderToken(image: data)
        case .swapForce:
            return SkylanderToken(image: data)
        case .superCharger:
            return SkylanderToken(image: data)
        case .sidekick:
            return SkylanderToken(image: data)
        case .mini:
            return SkylanderToken(image: data)
        //case .Vehicle:
        //case .MagicItem: //Includes Traps, includes AdventurePacks
    
        default:
            return t
        }
    }
    
    static func build(_ model: Model) -> Token {
        var random = arc4random()
        let uid = Data(bytes: UnsafePointer<UInt8>(&random), count: sizeof(UInt32))
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
        
        let files = self.fileManager.enumerator(
            at: self.appDelegate.applicationDocumentsDirectory as URL,
            includingPropertiesForKeys: nil,
            options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles,
            errorHandler: nil)
        
        if let files = files {
            for file in files {
                if ((file as AnyObject).absoluteString??.hasSuffix("bin"))! { // checks the extension
                    if let image = try? Data(contentsOf: file as! URL) {
                        if (image.count == MifareClassic.tokenSize) {
                            fileList.append(Token.factory(image))
                        }
                    }
                }
            }
        }
        
        
        fileList.sort(by: { (a, b) -> Bool in
            return a.modelId > b.modelId
        })
        return fileList
    }
    
}
