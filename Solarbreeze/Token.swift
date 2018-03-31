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
        return "\(me)(\(uid.toHexString()) - \(name))"
    }
    
    override var filename : String {
        get {
            return "\(uid.toHexString())-\(name).bin"
        }
    }

    //Also known as 'ID' or 'type'.  I wanted to avoid those terms because of their alternate meanings
    var modelId : UInt16 {
        get {
            return block(1).subdata(in: 0..<2).uint16
        }
        set(newModelId) {
            //Assume this is happening on a zero'd out new token
            var m = newModelId
            var newBlock = block(1)
            newBlock.replaceSubrange(0..<2, with: Data(buffer: UnsafeBufferPointer(start: &m, count: 1)))
            load(1, blockData: newBlock)
            updateCrc()
        }
    }
    
    var flags : UInt16 {
        get {
            return block(1).subdata(in: 12..<14).uint16
        }
        set (newFlags) {
            //Assume this is happening on a zero'd out new token
            var m = newFlags
            var newBlock = block(1)
            newBlock.replaceSubrange(12..<14, with: Data(buffer: UnsafeBufferPointer(start: &m, count: 1)))
            load(1, blockData: newBlock)
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
        self.init(uid: image.subdata(in: 0..<4))
        self.data = image
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
        var input = Data()
        switch (index) {
        case 0:
            var block1 = block(1).subdata(in: 0..<14)
            input.append(block(0))
            input.append(block1)
            block1.append(input.crcCCITT)
            load(1, blockData: block1)
        case 1:
            var primary0 = primaryData(0).subdata(in: 0..<14)
            input.append(primary0)
            var literal : UInt8
            literal = 5
            input.append(&literal, count: 1)
            literal = 0
            input.append(&literal, count: 1)
            
            primary0.append(input.crcCCITT)
            //print("primary0 = \(primary0) vs \(primaryData(0))")
            //print("encrypted primary0 = \(encrypt(primaryAreaNumber, blockData: primary0 as! NSData)) vs \(block(primaryAreaNumber))")
            load(primaryAreaNumber, blockData: encrypt(primaryAreaNumber, blockData: primary0))
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
        
        let aes = try! AES(key: key.bytes, blockMode: .ECB, padding: Padding.noPadding)
        var newBytes : [UInt8]
        
        if (encrypt) {
            newBytes = try! aes.encrypt(blockData.bytes)
        } else {
            newBytes = try! aes.decrypt(blockData.bytes)
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
        let uid = Data(buffer: UnsafeBufferPointer(start: &random, count: 4))
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
                if let file = file as? URL {
                    if (file.absoluteString.hasSuffix("bin")) {
                        if let image = try? Data(contentsOf: file) {
                            if (image.count == MifareClassic.tokenSize) {
                                fileList.append(Token.factory(image))
                            }
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
