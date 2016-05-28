//
//  NSData+subscript.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

public extension NSData {
    subscript(origin: Int) -> UInt8 {
        get {
            var result: UInt8 = 0;
            if (origin < self.length) {
                self.getBytes(&result, range: NSMakeRange(origin, sizeof(UInt8)))
            }
            return result;
        }
    }    
}