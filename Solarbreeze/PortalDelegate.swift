//
//  PortalDelegate.swift
//  TokenMaker
//
//  Created by Eric Betts on 6/3/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

class Portal : NSObject {
    
}

protocol PortalDelegate {
    func deviceConnected(_ portal : Portal)
    func deviceDisconnected(_ portal : Portal)
    func input(_ report: Data)
}

protocol PortalUIProtocol {
    func connected()
    func disconnected()
    func newToken()
    func readBlock(number : Int)
    func tokenSave()
}
