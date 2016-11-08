//
//  Dictionary+get.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

//https://gist.github.com/olgakogan/bd6e5eff98aeda63c68c
extension Dictionary {
    
    func get(_ key: Key, defaultValue: Value) -> Value {
        /**
         Returns the value for the given key (if exists), otherwise returns the default value.
         */
        if let value = self[key] {
            return value
        } else {
            return defaultValue
        }
    }
}
