//
//  FakeBaseInterface.swift
//  Solarbreeze
//
//  Created by Eric Betts on 5/27/16.
//  Copyright © 2016 Eric Betts. All rights reserved.
//

import Foundation
import CoreBluetooth

//This class represents the BLE interface for fake base
class FakeBaseInterface : NSObject, CBPeripheralManagerDelegate {
    typealias incomingReport = (Data) -> Void
    
    static let short_service_uuid = CBUUID(string: "1530")
    static let service_uuid = CBUUID(string: "533E1530-3ABE-F33F-CD00-594E8B0A8EA3")
    static let write_uuid = CBUUID(string: "533E1543-3ABE-F33F-CD00-594E8B0A8EA3")
    static let read_uuid = CBUUID(string: "533E1542-3ABE-F33F-CD00-594E8B0A8EA3")
    
    let readCharacteristic = CBMutableCharacteristic(type: FakeBaseInterface.read_uuid, properties: .notify, value: nil, permissions: .readable)
    let writeCharacteristic = CBMutableCharacteristic(type: FakeBaseInterface.write_uuid, properties: [.writeWithoutResponse, .write], value: nil, permissions: .writeable)
    
    var peripheralManager : CBPeripheralManager?
    var service : CBMutableService?
    var central : CBCentral?
    
    var incomingReportCallbacks : [incomingReport] = []
    var previousValue : NSMutableData?
    
    func start() {
        print("start")
        let queue = DispatchQueue.main
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
    }
    
    func stop() {
        if let peripheral = self.peripheralManager {
            peripheral.removeAllServices()
            peripheral.stopAdvertising()
        }
    }
    
    func registerIncomingReportCallback(_ callback: @escaping incomingReport) {
        incomingReportCallbacks.append(callback)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        peripheral.removeAllServices()
        switch peripheral.state {
        case .poweredOff:
            print("BLE OFF")
        case .poweredOn:
            print("BLE ON")
            service = CBMutableService(type: FakeBaseInterface.service_uuid, primary: true)
            service!.characteristics = [readCharacteristic, writeCharacteristic]
            peripheral.add(service!)
            peripheral.startAdvertising(
                [
                    CBAdvertisementDataSolicitedServiceUUIDsKey: [FakeBaseInterface.service_uuid],
                    CBAdvertisementDataServiceUUIDsKey: [FakeBaseInterface.short_service_uuid],
                    CBAdvertisementDataLocalNameKey: "Skylanders Portal\0"
                ]
            )
        case .unknown:
            print("NOT RECOGNIZED")
        case .unsupported:
            print("BLE NOT SUPPORTED")
        case .resetting:
            print("BLE NOT SUPPORTED")
        default:
            print("Error")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribeToCharacteristic \(characteristic.uuid)")
        if (characteristic.uuid == readCharacteristic.uuid) {
            self.central = central
            peripheral.setDesiredConnectionLatency(CBPeripheralManagerConnectionLatency.low, for: central)
        } else {
            print("Trying to subscribe to non-read characteristic?")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("didUnsubscribeFromCharacteristic \(characteristic.uuid)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            peripheral.respond(to: request, withResult: CBATTError.Code.success)
            if let newValue = request.value {
                print("<= \(newValue)")
                for callback in incomingReportCallbacks {
                    callback(newValue)
                }
            }
        }
    }
    
    func outgoingReport(_ report: Data) {
        if let peripheralManager = self.peripheralManager {
            if peripheralManager.state == .poweredOn {
                print("=> \(report)")
                peripheralManager.updateValue(report, for: self.readCharacteristic, onSubscribedCentrals: nil)
            } else {
                print("Attempted to send report when peripheralManager was not powered on")
            }
        } else {
            print("Attempted to send report when peripheralManager was not defined")
        }
    }
}
