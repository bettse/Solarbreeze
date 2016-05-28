//
//  NSData+hexstring.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

public extension NSData {
    convenience init(fromHex: String) {
        let hexArray = fromHex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(" ")
        let hexBytes : [UInt8] = hexArray.map({UInt8($0, radix: 0x10)!})
        self.init(bytes: hexBytes as [UInt8], length: hexBytes.count)
    }
    
    var toHex : String {
        let s = "\(self)".componentsSeparatedByString(" ").joinWithSeparator("").stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: "< >"))
        return s
    }
}
