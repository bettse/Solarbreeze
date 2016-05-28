//
//  Report.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

class Report : CustomStringConvertible {
    let data : NSData
    
    init(data: NSData) {
        self.data = data
    }

    
    var description: String {
        let me = String(self.dynamicType).componentsSeparatedByString(".").last!
        return "\(me)::\(data)"
    }
}
