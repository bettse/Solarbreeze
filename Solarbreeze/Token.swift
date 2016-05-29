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
    }
    
    var flags : UInt16 {
        get {
            return block(1).subdataWithRange(NSMakeRange(12, 2)).uint16
        }
    }
    
    var model : Model {
        get {
            return Model(id: UInt(modelId), flags: UInt(flags))
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
    
    var color : UIColor {
        get {
            return model.color
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
        if (blockData.length != MifareClassic.blockSize) {
            print("blockData must be exactly \(MifareClassic.blockSize) bytes")
            return true
        }
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
        return NSData(data: preKey).md5()
    }
    
    override func block(blockNumber: Int) -> NSData {
        return decrypt(blockNumber, blockData: super.block(blockNumber))
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
            return a.uid.uint32 > b.uid.uint32
        })
        return fileList
    }
    
}