//
//  Token.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
import UIKit

class Token : MifareClassic, CustomStringConvertible {
    static let fileManager = NSFileManager()
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let BINARY = 2
    let HEX = 0x10

    
    var description: String {
        let me = String(self.dynamicType).componentsSeparatedByString(".").last!
        return "\(me)(\(uid.toHex) - \(name))"
    }
    
    override var filename : String {
        get {
            return "\(uid.toHex)-\(name).bin"
        }
    }
    
    var modelId : UInt16 {
        get {
            return block(1).subdataWithRange(NSMakeRange(0, 2)).uint16
        }
    }
    
    var model : Model {
        get {
            return Model(id: UInt(modelId))
        }
    }
    
    var name : String {
        get {
            return model.name
        }
    }
    
    var sequenceA : UInt8 {
        get {
            return block(0x08).subdataWithRange(NSMakeRange(9, 1)).uint8
        }
    }
    
    var sequenceB : UInt8 {
        get {
            return block(0x24).subdataWithRange(NSMakeRange(9, 1)).uint8
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
        return block(primaryAreaNumber + offset)
    }
    
    func skipEncryption(blockNumber: Int, blockData: NSData) -> Bool {
        return (blockNumber < 8 || sectorTrailer(blockNumber) || blockData.isEqualToData(emptyBlock))
    }
    
    func keyForBlock(blockNumber: Int) -> NSData {
        return keyForBlock(UInt8(blockNumber))
    }
    
    func keyForBlock(blockNumber: UInt8) -> NSData {
        let suffix : String = "Pbclevtug (P) 2010 Npgvivfvba. Nyy Evtugf Erfreirq. "
        let preKey = NSMutableData()
        preKey.appendData(block(0))
        preKey.appendData(block(1))
        preKey.appendByte(blockNumber)
        preKey.appendData(suffix.rot13.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        //CC_MD5(preKey.bytes, (unsigned int)preKey.length, key);
        
        return NSData(data: preKey)
    }
    
    func decrypt(blockNumber: Int, blockData: NSData) -> NSData {
        return commonCrypt(blockNumber, blockData: blockData, encrypt: false)
    }
    
    func encrypt(blockNumber: Int, blockData: NSData) -> NSData {
        return commonCrypt(blockNumber, blockData: blockData, encrypt: true)
    }
    
    func commonCrypt(blockNumber: Int, blockData: NSData, encrypt: Bool) -> NSData {
        if (blockData.length != MifareClassic.blockSize) {
            print("blockData must be exactly \(MifareClassic.blockSize) bytes")
            return blockData
        }
        
        if (skipEncryption(blockNumber, blockData: blockData)) {
            return blockData
        }
        
        /*
        let key = self.keyForBlock(blockNumber)
        
        let aes = try! AES(key: key.arrayOfBytes(), blockMode: .ECB)
        var newBytes : [UInt8]
        
        if (encrypt) {
            newBytes = try! aes.encrypt(blockData.arrayOfBytes(), padding: nil)
        } else {
            newBytes = try! aes.decrypt(blockData.arrayOfBytes(), padding: nil)
        }
        
        return NSData(bytes: newBytes)
        */
        return blockData
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
                            fileList.append(Token(image: image))
                        }
                    }
                }
            }
        }
        
        
        fileList.sortInPlace({ (a, b) -> Bool in
            return a.uid.uint32 > b.uid.uint32
        })
        return fileList
    }
    
}