//
//  NSData+asUint.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

//https://gist.github.com/tannernelson/73d0923efdee50e6c38f
extension Data {
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            (self as NSData).getBytes(&number, length: MemoryLayout<UInt8>.size)
            return number
        }
    }
    
    var uint16: UInt16 {
        get {
            var number: UInt16 = 0
            (self as NSData).getBytes(&number, length: MemoryLayout<UInt16>.size)
            return number
        }
    }
    
    var uint32: UInt32 {
        get {
            var number: UInt32 = 0
            (self as NSData).getBytes(&number, length: MemoryLayout<UInt32>.size)
            return number
        }
    }
    
    var uuid: UUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.count)
            (self as NSData).getBytes(&bytes, length: self.count * MemoryLayout<UInt8>.size)
            return (NSUUID(uuidBytes: bytes) as UUID)
        }
    }
}
