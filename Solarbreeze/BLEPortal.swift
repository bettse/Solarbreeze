//
//  BLEPortal.swift
//  TokenMaker
//
//  Created by Eric Betts on 6/2/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPortal : Portal, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let singleton = BLEPortal()
    
    let short_service_uuid = CBUUID(string: "1530")
    let service_uuid = CBUUID(string: "533E1530-3ABE-F33F-CD00-594E8B0A8EA3")
    let write_uuid = CBUUID(string: "533E1543-3ABE-F33F-CD00-594E8B0A8EA3")
    let read_uuid = CBUUID(string: "533E1542-3ABE-F33F-CD00-594E8B0A8EA3")
    
    var centralManager : CBCentralManager?
    var device : CBPeripheral?
    var readCharacteristic : CBCharacteristic?
    var writeCharacteristic : CBCharacteristic?
    
    var delegate : PortalDelegate? = nil
    
    func discover() {
        print("BLEPortal discover")
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            print("Central state \(central.state)")
            let peripherals = central.retrieveConnectedPeripherals(withServices: [short_service_uuid])
            if (peripherals.isEmpty) {
                print("No peripherals known, scanning")
                central.scanForPeripherals(withServices: [short_service_uuid], options:nil)
            } else {
                if (peripherals.count > 1) {
                    print("Found \(peripherals.count) peripherals, but coded to only handle 1")
                }
                if let peripheral = peripherals.first {
                    if (self.device == nil && peripheral.state == .disconnected) {
                        self.device = peripheral
                        central.connect(peripheral, options: nil)
                    }
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnectPeripheral")
        central.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([service_uuid])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral")
        self.delegate?.deviceDisconnected(self)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDiscoverPeripheral \(peripheral)")
        if let device = self.device {
            if device.state == .disconnected {
                central.connect(device, options: nil)
            }
        } else if (peripheral.state == .disconnected) {
            self.device = peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    //Mark -
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("didDiscoverCharacteristicsForService [error: \(error)]")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if (characteristic.properties.contains(.notify)) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    readCharacteristic = characteristic
                }
                if (characteristic.properties.contains(.write)) {
                    writeCharacteristic = characteristic
                }                
            }
            
            self.delegate?.deviceConnected(self)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("didDiscoverServices [error: \(error)]")
            return
        }
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("didUpdateValueForCharacteristic [error: \(error)]")
        } else if let report = characteristic.value {
            //print("BLE IN: \(report)")
            self.delegate?.input(report)
        }
    }
    
    func output(_ report: Data) {
        guard let peripheral = self.device else {
            return
        }
        
        guard let writeCharacteristic = self.writeCharacteristic else {
            return
        }
        //print("BLE OUT: \(report)")
        
        peripheral.writeValue(report, for: writeCharacteristic, type: .withResponse)
    }
}
