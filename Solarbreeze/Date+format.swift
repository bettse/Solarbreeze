//
//  Date+format.swift
//  Solarbreeze
//
//  Created by Eric Betts on 3/30/18.
//  Copyright © 2018 Eric Betts. All rights reserved.
//

import Foundation

extension Date {
    var customTime: String {
        return Formatter.time.string(from: self)
    }
}

extension Formatter {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
