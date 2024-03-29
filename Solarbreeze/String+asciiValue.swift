//
//  String+asciiValue.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
//http://stackoverflow.com/questions/29835242/whats-the-simplest-way-to-convert-from-a-single-character-string-to-an-ascii-va
extension String {
    var asciiValue: UInt8 {
        if (unicodeValue > 0 && unicodeValue < 0xFF) {
            return UInt8(unicodeValue)
        }
        return 0
    }
    var unicodeValue: UInt32 {
        guard let first = first, count == 1 else  { return 0 }
        return first.unicodeScalarsValue
    }
    func asciiValueAt(pos: UInt32) -> UInt32 {
        guard count > 0 && Int(pos) < count else  { return 0 }
        return Array(self)[Int(pos)].unicodeScalarsValue
    }
}
extension Character {
    var unicodeScalarsValue: UInt32 {
        return String(self).unicodeScalars.first!.value
    }
}
