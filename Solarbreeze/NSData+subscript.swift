//
//  NSData+subscript.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

public extension Data {
    subscript(origin: Int) -> UInt8 {
        get {
            var result: UInt8 = 0;
            if (origin < self.count) {
                (self as NSData).getBytes(&result, range: NSMakeRange(origin, MemoryLayout<UInt8>.size))
            }
            return result;
        }
    }    
}
