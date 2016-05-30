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
     high bit: token update bit
     low bit: token state bit
     
     00 = no token
     01 = token present
     10 = token left (present, update state to not present)
     11 = token entered (not present, update state to present)
     */
    func placeToken(newToken: Token) {
        let index = activeTokens.filter{ $0.1 == nil }.map{ $0.0 }.first ?? activeTokens.count
        activeTokens[index] = newToken
        status |= (0b10 << (2 * UInt32(index)))
        sendStatus()
    }
    
    func removeToken(oldToken: Token) {
        let index = activeTokens.filter{ $0.1.uid == oldToken.uid }.map{ $0.0 }.first
        if let index = index {
            activeTokens.removeValueForKey(index)
            status |= (0b10 << (2 * UInt32(index)))
            sendStatus()
        } else {
            print("Tried to remove token that wasn't active")
        }
        
    }
    
    func clearAllTokens() {
        activeTokens.forEach { (index, token) in
            removeToken(token)
        }
    }
    
    func sendStatus() {
        //Status may contain update flags, so only the state flags can be cleared
        status &= 0xAAAAAAAA
        activeTokens.forEach { (index, _) in
            //Set the state bit for all active tokens
            status |= (0b01 << (2 * UInt32(index)))
        }
        
        let s = NSData(bytes: &status, length: sizeof(UInt32)) //Make bytes more accessible
        print("sendStatus: \(s)")
        let response : NSData = NSData(bytes: [0x53/* 'S' */, s[0], s[1], s[2], s[3], nextSequence, 0x01, 0xaa, 0x86, 0x02, 0x19] as [UInt8], length: 11)
        //Clear update bits
        status = status & 0x55555555 //0x55 = 0b01010101
        bleInterface.outgoingReport(response)
    }
    
    func incomingReport(report: NSData) {
        var response : NSData = NSData()
        print("Command \(Character(UnicodeScalar(report[0])))")

        switch(report[0]){
        case "A".asciiValue:
            response = NSData(bytes: [report[0], report[1], 0x62, 0x02, 0x19, 0xaa, 0x01, 0x5e, 0x49, 0x53, 0xbb, 0x35, 0xc6] as [UInt8], length: 13)
            break
        case "J".asciiValue:
            response = NSData(bytes: [report[0], 0x00, 0x00, 0x00] as [UInt8], length: 4)
            break
        case "L".asciiValue:
            break
        case "Q".asciiValue:
            let temp = NSData(bytes: [report[0], report[1], report[2]] as [UInt8], length: 3).mutableCopy()
            let index = Int(report[1] & 0x0f)
            let blockNumber = report[2]
            if let token = activeTokens[index] {
                let mf = token as MifareClassic //Read blocks encrypted
                temp.appendData(mf.block(blockNumber))
            }
            print("\tresponse \(temp    )")
            response = temp as! NSData
            break
        case "R".asciiValue:
            print("\tparameters: \(report)")
            response = NSData(bytes: [report[0], 0x02, 0x19] as [UInt8], length: 3)
            break
        case "S".asciiValue:
            sendStatus()
            break
        case "W".asciiValue:
            let index = Int(report[1] & 0x0f)
            let blockNumber = report[2]
            if let token = activeTokens[index] {
                token.load(blockNumber, blockData: report.subdataWithRange(NSMakeRange(3, MifareClassic.blockSize)))
                token.dump(appDelegate.applicationDocumentsDirectory)
            }
            response = NSData(bytes: [report[0], report[1], report[2]] as [UInt8], length: 3)
            break
        default:
            print("Unhandled \(report[0])")
        }
        
        if (response.length > 0) {
            bleInterface.outgoingReport(response)
        }
    }
}