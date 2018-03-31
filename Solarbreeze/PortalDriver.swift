//
//  PortalDriver.swift
//  TokenMaker
//
//  Created by Eric Betts on 6/1/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
import UIKit

class PortalDriver : PortalDelegate {
    enum Key : UInt8 {
        case factory = 0x00
        case keygen = 0x01
    }
    let HEX = 0x10
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let portal : BLEPortal
    var next : (index: UInt8, token: SkylanderToken?) = (0, nil)
    
    let ui : PortalUIProtocol
    
    init(ui : PortalUIProtocol) {
        portal = BLEPortal.singleton        
        self.ui = ui
        self.portal.delegate = self
    }
    
    func discover() {
        self.portal.discover()
    }
    
    func input(_ report: Data) {
        let command : UInt8 = report[0]
        let contents : Data = report.subdata(in: 1..<report.count)
        
        switch(command) {
        case "A".asciiValue:
            print("Activate ack \(contents.toHexString())")
            DispatchQueue.main.sync() { self.ui.connected() }
        case "K".asciiValue:
            print("Key configuration ack \(contents)")
        case "Q".asciiValue:
            //Check for error to determine if token is writable
            let index = contents[0] & 0x0f
            let error = contents[0] & 0xf0
            let block = contents[1]
            let blockData = contents.subdata(in: 2..<2+MifareClassic.blockSize)
            if (error == 0) {
                print("Q error: Is this a non-blank token?")
                keyConfig(Key.factory)
            } else {
                if (block == 0) {
                    self.next = (index, SkylanderToken(uid:blockData.subdata(in: 0..<4)))
                    if let token = self.next.token {
                        token.load(block, blockData: blockData)
                    }
                }
                if (Int(block) < MifareClassic.blockCount) {
                    self.next.token?.load(block, blockData: blockData)
                }
                if (Int(block) < MifareClassic.blockCount - 1) {
                    readToken(index, block: block+1)
                }
                
                if (Int(block) == MifareClassic.blockCount - 1) {
                    if let token = self.next.token {
                        DispatchQueue.main.sync() { self.ui.tokenSave(token: token) }
                        // Hmm...could do the token.dump /in/ the self.ui.tokenSave
                        token.dump(appDelegate.applicationDocumentsDirectory)
                    }
                }
            }
        case "R".asciiValue:
            print("Reset ack \(contents)")
        case "S".asciiValue:
            parseStatus(report.subdata(in: 1..<5))
        case "W".asciiValue:
            let index = contents[0] & 0x0f
            _ = contents[0] & 0xf0
            let block = contents[1]

                print("W ack \(index) block \(block)")
                switch(block) {
                case 0..<UInt8(MifareClassic.blockCount - 1):
                    writeToken(index, block: block+1)
                case UInt8(MifareClassic.blockCount - 1):
                    self.next = (0, nil)
                default:
                    print("Ack for writing block \(block)")
                }
        default:
            print("Unhandled comand code: \(command) \(contents)")
        }
    }
    
    //https://fgiesen.wordpress.com/2009/12/13/decoding-morton-codes/
    func Compact1By1(_ input : UInt32) -> UInt16  {
        var x : UInt32 = input
        x &= 0x55555555;                  // x = -f-e -d-c -b-a -9-8 -7-6 -5-4 -3-2 -1-0
        x = (x ^ (x >>  1)) & 0x33333333; // x = --fe --dc --ba --98 --76 --54 --32 --10
        x = (x ^ (x >>  2)) & 0x0f0f0f0f; // x = ---- fedc ---- ba98 ---- 7654 ---- 3210
        x = (x ^ (x >>  4)) & 0x00ff00ff; // x = ---- ---- fedc ba98 ---- ---- 7654 3210
        x = (x ^ (x >>  8)) & 0x0000ffff; // x = ---- ---- ---- ---- fedc ba98 7654 3210
        return UInt16(x);
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
    func parseStatus(_ encodedStatus: Data) {
        let statusWord = encodedStatus.uint32
        let stateBits = Compact1By1(statusWord >> 0)
        let updateBits = Compact1By1(statusWord >> 1)
        if ((updateBits & stateBits) > 0) { //Arrival
            let index : UInt8 = UInt8(log2(Float(updateBits)))
            // print("New token at index \(index)")
            DispatchQueue.main.sync() { self.ui.newToken() }
            readToken(index, block: 0)
        }
    }
    
    func readToken(_ index: UInt8, block: UInt8) {
        // print("Read [\(block)] @ \(index)")
        DispatchQueue.main.sync() { self.ui.readBlock(number: Int(block)) }
        let readBlock = Data(bytes: ["Q".asciiValue, index, block] as [UInt8])
        portal.output(readBlock)
    }
 
    func writeToken(_ index: UInt8, block: UInt8) {
        guard let token = self.next.token else {
            print("Could not find token for index \(index)")
            return
        }
        
        let blockData = token.block(block)
        var write = Data(bytes: ["W".asciiValue, index, block] as [UInt8])        
        write.append(blockData)
        print("Write [\(block)]: \(write)")
        portal.output(write)
    }
    
    func keyConfig(_ state : Key) {
        let keyConfig = Data(bytes: ["K".asciiValue, state.rawValue] as [UInt8])
        portal.output(keyConfig)
    }

    @objc func getStatus() {
        let statusCommand = Data(bytes: ["S".asciiValue] as [UInt8])
        portal.output(statusCommand)
    }
    
    func deviceConnected(_ portal : Portal) {
        let activate = Data(bytes: ["A".asciiValue, 0x01])
        self.portal.output(activate)
    }
    
    func deviceDisconnected(_ portal : Portal) {
        DispatchQueue.main.sync() { self.ui.disconnected() }
    }
}


