//
//  NSData+hexstring.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

public extension Data {
    init(fromHex: String) {
        let hexArray = fromHex.trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: " ")
        let hexBytes : [UInt8] = hexArray.map({UInt8($0, radix: 0x10)!})
        self = Data(bytes: hexBytes as [UInt8])        
    }
    
    var toHex : String {
        let s = "\(self)".components(separatedBy: " ").joined(separator: "").trimmingCharacters(in: CharacterSet.init(charactersIn: "< >"))
        return s
    }
}
