//
//  String+rot13.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/28/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
//https://gist.github.com/jgallagher/ca55cab8126073e39bd1
extension String {
    var rot13: String {
        get {
            var rot13key = [Character:Character]()
            let uppercase : [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
            let lowercase : [Character] = Array("abcdefghijklmnopqrstuvwxyz".characters)
            for u in uppercase {
                rot13key[u] = uppercase[(uppercase.indexOf(u)! + 13) % 26]
            }
            for l in lowercase {
                rot13key[l] = lowercase[(lowercase.indexOf(l)! + 13) % 26]
            }
            
            return String(self.characters.map({ rot13key[$0] ?? $0 }))
        }
    }
}