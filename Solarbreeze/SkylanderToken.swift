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
        return "\(me)(\(uid.toHex) - \(name) xp: \(xp) gold: \(gold))"
    }
    
    var xp : UInt16 {
        get {
            return primaryData(0).subdataWithRange(NSMakeRange(0, 2)).uint16
        }
    }
    
    var gold : UInt16 {
        get {
            return primaryData(0).subdataWithRange(NSMakeRange(3, 2)).uint16
        }
    }
}