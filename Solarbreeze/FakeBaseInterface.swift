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
    typealias incomingReport = (NSData) -> Void
    
    static let short_service_uuid = CBUUID(string: "1530")
    static let service_uuid = CBUUID(string: "533E1530-3ABE-F33F-CD00-594E8B0A8EA3")
    static let write_uuid = CBUUID(string: "533E1543-3ABE-F33F-CD00-594E8B0A8EA3")
    static let read_uuid = CBUUID(string: "533E1542-3ABE-F33F-CD00-594E8B0A8EA3")
    
    let readCharacteristic = CBMutableCharacteristic(type: FakeBaseInterface.read_uuid, properties: .Notify, value: nil, permissions: .Readable)
    let writeCharacteristic = CBMutableCharacteristic(type: FakeBaseInterface.write_uuid, properties: [.WriteWithoutResponse, .Write], value: nil, permissions: .Writeable)
    
    var peripheralManager : CBPeripheralManager?
    var service : CBMutableService?
    var central : CBCentral?
    
    var incomingReportCallbacks : [incomingReport] = []
    var previousValue : NSMutableData?
    
    func start() {
        let queue = dispatch_get_main_queue()
        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
    }
    
    func stop() {
        if let peripheral = self.peripheralManager {
            peripheral.removeAllServices()
            peripheral.stopAdvertising()
        }
    }
    
    func registerIncomingReportCallback(callback: incomingReport) {
        incomingReportCallbacks.append(callback)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        peripheral.removeAllServices()
        switch peripheral.state {
        case .PoweredOff:
            print("BLE OFF")
        case .PoweredOn:
            service = CBMutableService(type: FakeBaseInterface.service_uuid, primary: true)
            service!.characteristics = [readCharacteristic, writeCharacteristic]
            peripheral.addService(service!)
            peripheral.startAdvertising(
                [
                    CBAdvertisementDataIsConnectable: true,
                    CBAdvertisementDataSolicitedServiceUUIDsKey: [FakeBaseInterface.service_uuid],
                    CBAdvertisementDataServiceUUIDsKey: [FakeBaseInterface.short_service_uuid],
                    CBAdvertisementDataLocalNameKey: "Skylanders Portal\0"
                ]
            )
        case .Unknown:
            print("NOT RECOGNIZED")
        case .Unsupported:
            print("BLE NOT SUPPORTED")
        case .Resetting:
            print("BLE NOT SUPPORTED")
        default:
            print("Error")
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("peripheralManagerDidStartAdvertising \(peripheral) [\(error)]")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("didSubscribeToCharacteristic \(characteristic.UUID)")
        if (characteristic.UUID == readCharacteristic.UUID) {
            self.central = central
            peripheral.setDesiredConnectionLatency(CBPeripheralManagerConnectionLatency.Low, forCentral: central)
        } else {
            print("Trying to subscribe to non-read characteristic?")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("didUnsubscribeFromCharacteristic \(characteristic.UUID)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        //print("didAddService")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("didReceiveReadRequest: \(request)")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for request in requests {
            peripheral.respondToRequest(request, withResult: CBATTError.Success)
            if let newValue = request.value {
                print("<= \(newValue)")
                for callback in incomingReportCallbacks {
                    callback(newValue)
                }
            }
        }
    }
    
    func outgoingReport(report: NSData) {
        if let peripheralManager = self.peripheralManager {
            if peripheralManager.state == CBPeripheralManagerState.PoweredOn {
                print("=> \(report)")
                peripheralManager.updateValue(report, forCharacteristic: self.readCharacteristic, onSubscribedCentrals: nil)
            } else {
                print("Attempted to send report when peripheralManager was not powered on")
            }
        } else {
            print("Attempted to send report when peripheralManager was not defined")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        print("willRestoreState")
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReadyToUpdateSubscribers")
    }
}
