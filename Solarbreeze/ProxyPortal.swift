//
//  ProxyPortal.swift
//  TokenMaker
//
//  Created by Eric Betts on 6/3/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation

class ProxyPortal : PortalDelegate {
    var bleportal : BLEPortal = BLEPortal.singleton
    var connected : Portal? = nil
    var delegate : PortalDelegate? = nil
    
    init() {
        self.bleportal.discover()
        self.bleportal.delegate = self
    }
    
    func deviceConnected(_ portal : Portal) {
        print("Connected \(portal)")
        self.connected = portal
        self.delegate?.deviceConnected(portal)
    }
    
    func deviceDisconnected(_ portal : Portal) {
        print("Disconnected")
        self.connected = nil
        self.delegate?.deviceDisconnected(portal)
    }
    
    func input(_ report: Data) {
        self.delegate?.input(report)
    }
    
    func output(_ report : Data, delay : TimeInterval = 0.0) {
        guard self.connected != nil else {
            print("No device connected for sending output")
            return
        }
        
        if let ble = self.connected as? BLEPortal {
            ble.output(report)
        }
    }
}
