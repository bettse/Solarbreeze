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
    let HEX = 0x10
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
    
    var status : UInt32 = 0;
    var activeTokens : [Int:Token] = [Int:Token]()
    
    init() {
        bleInterface.registerIncomingReportCallback(incomingReport)
    }
    
    func start() {
        bleInterface.start()
    }
    
    func stop() {
        bleInterface.stop()
    }
    
    /*
     Status is 16 pairs of bits
     high bit: token state changed
     low bit: token present
     
     00 = no token
     01 = token present
     10 = token left (present, changing state to not present)
     11 = token entered (not present, changing state to present)
     */
    func placeToken(newToken: Token) {
        let openIndex = activeTokens.filter{ $0.1 == nil }.map{ $0.0 }.first ?? activeTokens.count        
        activeTokens[openIndex] = newToken
        status = status | (0b11 << (2 * UInt32(openIndex)))
        print("Placed at \(openIndex), status is \(String(status, radix: HEX))")
    }
    
    func removeToken(oldToken: Token) {
        let index = activeTokens.filter{ $0.1.uid == oldToken.uid }.map{ $0.0 }.first
        if let index = index {
            activeTokens.removeValueForKey(index)
            status = status & ~(0 ^ 0b01 << (2 * UInt32(index)))  //zero out the status bit, and set the update bit
            print("Removed from \(index), status is \(String(status, radix: HEX))")
        } else {
            print("Tried to remove token that wasn't active")
        }
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
            let s = NSData(bytes: &status, length: sizeof(UInt32)) //Make bytes more accessible
            response = NSData(bytes: [report[0], s[0], s[1], s[2], s[3], nextSequence, 0x01, 0xaa, 0x86, 0x02, 0x19] as [UInt8], length: 11)
            //Clear update bits
            status = status & 0x55555555 //0x55 = 0b01010101
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