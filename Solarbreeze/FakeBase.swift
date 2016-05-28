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
    
    static var corrolationGenerator = (1..<UInt8.max-1).generate()
    static var nextSequence : UInt8 {
        get {
            if let next = corrolationGenerator.next() {
                return next
            } else {
                corrolationGenerator = (1..<UInt8.max-1).generate()
                return 0
            }
        }
    }
    
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
        var response : NSData = NSData()
        print("Command \(Character(UnicodeScalar(report[0])))")

        switch(report[0]){
        case "A".asciiValue:
            response = NSData(bytes: [report[0], report[1], 0x62, 0x02, 0x19, 0xaa, 0x01, 0x5e, 0x49, 0x53, 0xbb, 0x35, 0xc6] as [UInt8], length: 13)
            break;
        case "J".asciiValue:
            response = NSData(bytes: [report[0], 0x00, 0x00, 0x00] as [UInt8], length: 4)
            break;
        case "L".asciiValue:
            break;
        case "Q".asciiValue:
            break;
        case "R".asciiValue:
            response = NSData(bytes: [report[0], 0x02, 0x19] as [UInt8], length: 3)
            break;
        case "S".asciiValue:
            response = NSData(bytes: [report[0], 0x00, 0x00, 0x00, 0x00, FakeBase.nextSequence, 0x01, 0xaa, 0x86, 0x02, 0x19] as [UInt8], length: 11)
            break;
        case "W".asciiValue:
            response = NSData(bytes: [report[0], report[1], report[2]] as [UInt8], length: 3)
            break;
        default:
            print("Unhandled \(report[0])")
        }
        
        if (response.length > 0) {
            bleInterface.outgoingReport(response)
        }
    }
}