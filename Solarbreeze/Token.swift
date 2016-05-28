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
        return "\(me)(\(uid) - \(modelId))"
    }
    
    /*
    override var filename : String {
        get {
            return "\(uid.hexadecimalString)-\(name).bin"
        }
    }
    */
    
    var modelId : UInt16 {
        get {
            return block(1).subdataWithRange(NSMakeRange(0, 2)).uint16
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