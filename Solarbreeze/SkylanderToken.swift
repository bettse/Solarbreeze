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
        let me = String(describing: type(of: self)).components(separatedBy: ".").last!
        return "\(me)(\(uid.toHex) - \(name) xp: \(xp0)/\(xp1)/\(xp2) gold: \(gold))"
    }
    
    var xp0 : UInt16 {
        get {
            return primaryData(0).subdata(in: 0..<2).uint16
        }
    }
    
    var xp1 : UInt16 {
        get {
            return primaryData(9).subdata(in: 3..<5).uint16
        }
    }
    
    var xp2 : UInt32 {
        get {
            return primaryData(9).subdata(in: 8..<11).uint32
        }
    }
    
    var gold : UInt16 {
        get {
            return primaryData(0).subdata(in: 3..<5).uint16
        }
        set(newVal) {
            var gold : UInt16 = newVal
            let primary0 = (primaryData(0) as NSData).mutableCopy() as! NSMutableData
            primary0.replaceBytes(in: NSMakeRange(3, 2), withBytes: &gold)

            load(primaryAreaNumber, blockData: encrypt(primaryAreaNumber, blockData: primary0 as Data))
            updateCrc(1)            
        }
    }
}
