//
//  NSData+asUint.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

//https://gist.github.com/tannernelson/73d0923efdee50e6c38f
extension NSData {
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.getBytes(&number, length: sizeof(UInt8))
            return number
        }
    }
    
    var uint16: UInt16 {
        get {
            var number: UInt16 = 0
            self.getBytes(&number, length: sizeof(UInt16))
            return number
        }
    }
    
    var uint32: UInt32 {
        get {
            var number: UInt32 = 0
            self.getBytes(&number, length: sizeof(UInt32))
            return number
        }
    }
    
    var uuid: NSUUID? {
        get {
            var bytes = [UInt8](count: self.length, repeatedValue: 0)
            self.getBytes(&bytes, length: self.length * sizeof(UInt8))
            return NSUUID(UUIDBytes: bytes)
        }
    }
}