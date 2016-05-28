//
//  FakeBase.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
import UIKit

class FakeBase {
    static let singleton = FakeBase()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let bleInterface = FakeBaseInterface()
    
    init() {
        bleInterface.registerIncomingReportCallback(incomingReport)
    }
    
    func start() {
        bleInterface.start()
    }
    
    func stop() {
        bleInterface.stop()
    }

    func incomingReport(report: NSData) {
        print("=> \(report)")
        
    }
}