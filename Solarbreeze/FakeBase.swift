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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let bleInterface = FakeBaseInterface()
    
    var corrolationGenerator = (1..<UInt8.max-1).makeIterator()
    var nextSequence : UInt8 {
        get {
            if let next = corrolationGenerator.next() {
                return next
            } else {
                corrolationGenerator = (1..<UInt8.max-1).makeIterator()
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
    func placeToken(_ newToken: Token) {
        let index = activeTokens.filter{ $0.1 == nil }.map{ $0.0 }.first ?? activeTokens.count
        activeTokens[index] = newToken
        status |= (0b10 << (2 * UInt32(index)))
        sendStatus()
    }
    
    func removeToken(_ oldToken: Token) {
        let index = activeTokens.filter{ $0.1.uid == oldToken.uid }.map{ $0.0 }.first
        if let index = index {
            activeTokens.removeValue(forKey: index)
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
        
        let s = Data(buffer: UnsafeBufferPointer(start: &status, count: 1))                
        let response : Data = Data(bytes: UnsafePointer<UInt8>([0x53/* 'S' */, s[0], s[1], s[2], s[3], nextSequence, 0x01, 0xaa, 0x86, 0x02, 0x19] as [UInt8]), count: 11)
        //Clear update bits
        status = status & 0x55555555 //0x55 = 0b01010101
        print("S \(s)")
        bleInterface.outgoingReport(response)
    }
    
    func incomingReport(_ report: Data) {
        var response : Data = Data()
        //print("Command \(Character(UnicodeScalar(report[0])))")

        switch(report[0]){
        case "A".asciiValue:
            response = Data(bytes: UnsafePointer<UInt8>([report[0], report[1], 0x62, 0x02, 0x19, 0xaa, 0x01, 0x5e, 0x49, 0x53, 0xbb, 0x35, 0xc6] as [UInt8]), count: 13)
            break
        case "J".asciiValue:
            response = Data(bytes: UnsafePointer<UInt8>([report[0], 0x00, 0x00, 0x00] as [UInt8]), count: 4)
            break
        case "L".asciiValue:
            break
        case "Q".asciiValue:
            var temp = Data(bytes: report.bytes, count: 3)
            let index = Int(report[1] & 0x0f)
            let blockNumber = report[2]
            if let token = activeTokens[index] {                
                let blockData = token.block(blockNumber)
                temp.append(blockData)
                print("Q #\(index) b\(blockNumber): \(blockData)")
            } else {
                print("Q Error: no token at #\(index)")
            }
            response = temp
            break
        case "R".asciiValue:
            //print("\tparameters: \(report)")
            response = Data(bytes: UnsafePointer<UInt8>([report[0], 0x02, 0x19] as [UInt8]), count: 3)
            break
        case "S".asciiValue:
            sendStatus()
            break
        case "W".asciiValue:
            let index = Int(report[1] & 0x0f)
            let blockNumber = report[2]
            let blockData = report.subdata(in: 3..<3+MifareClassic.blockSize)
            if let token = activeTokens[index] {
                token.load(blockNumber, blockData: blockData)
                print("W #\(index) b\(blockNumber): \(blockData)")
                token.dump(appDelegate.applicationDocumentsDirectory)
            } else {
                print("W error: No token at \(index)")
            }
            response = report.subdata(in: 0..<2)
            break
        default:
            print("Unhandled \(report[0])")
        }
        
        if (response.count > 0) {
            bleInterface.outgoingReport(response)
        }
    }
}
