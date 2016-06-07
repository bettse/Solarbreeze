//
//  SkylanderToken.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
class SkylanderToken : Token {
    override var description: String {
        let me = String(self.dynamicType).componentsSeparatedByString(".").last!
        return "\(me)(\(uid.toHex) - \(name) xp: \(xp0)/\(xp1)/\(xp2) gold: \(gold))"
    }
    
    var xp0 : UInt16 {
        get {
            return primaryData(0).subdataWithRange(NSMakeRange(0, 2)).uint16
        }
    }
    
    var xp1 : UInt16 {
        get {
            return primaryData(9).subdataWithRange(NSMakeRange(3, 2)).uint16
        }
    }
    
    var xp2 : UInt32 {
        get {
            return primaryData(9).subdataWithRange(NSMakeRange(8, 3)).uint32
        }
    }
    
    var gold : UInt16 {
        get {
            return primaryData(0).subdataWithRange(NSMakeRange(3, 2)).uint16
        }
        set(newVal) {
            var gold : UInt16 = newVal
            let primary0 = primaryData(0).mutableCopy() as! NSMutableData
            primary0.replaceBytesInRange(NSMakeRange(3, 2), withBytes: &gold)

            load(primaryAreaNumber, blockData: encrypt(primaryAreaNumber, blockData: primary0 as NSData))
            updateCrc(1)            
        }
    }
}