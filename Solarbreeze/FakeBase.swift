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
    
    var corrolationGenerator = (1..<UInt8.max-1).generate()
    var nextSequence : UInt8 {
        get {
            if let next = corrolationGenerator.next() {
                return next
            } else {
                corrolationGenerator = (1..<UInt8.max-1).generate()
                return 0
            }
        }
    }
    
    //Status is 16 pairs of bits
    //high bit shows...
    //low bit shows...
    //coming = 
    //going = 
    //still here = 
    //not here = 00
    var currentStatus : UInt32 = 0;
    var nextStatus : UInt32 = 0;
    
    let onPortal : [Token] = [Token]()
    
    init() {
        bleInterface.registerIncomingReportCallback(incomingReport)
    }
    
    func start() {
        bleInterface.start()
    }
    
    func stop() {
        bleInterface.stop()
    }

    
    func placeToken(newToken: Token) {
        //Sparse array in swift?
        //Add to nextStatus
    }
    
    func removeToken(oldToken: Token) {
        
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
            //shift nextStatus and OR into currentdStatus
            response = NSData(bytes: [report[0], 0x00, 0x00, 0x00, 0x00, nextSequence, 0x01, 0xaa, 0x86, 0x02, 0x19] as [UInt8], length: 11)
            //copy nextStatus into currentStatus, zero out nextStatus
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