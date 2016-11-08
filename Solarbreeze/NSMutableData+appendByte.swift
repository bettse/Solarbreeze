//
//  NSMutableData+appendByte.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
//http://stackoverflow.com/questions/25734357/swift-nsmutabledata-append-byte
extension NSMutableData {
    func appendByte(_ b: UInt8) {
        var newByte = b
        self.append(&newByte, length: 1)
    }
}
