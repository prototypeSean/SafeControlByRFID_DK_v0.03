//
//  BluetoothModel.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/28.
//  Copyright © 2019 DennisKao. All rights reserved.
//
//  此程式中，因為用途，所以我們設計連接的HC-08是外圍設備（Peripheral），
//  負責提供RFID的資訊給平板(Central)


import Foundation
import CoreBluetooth

// 這是從藍牙硬體中讀到的UUID
fileprivate let customService_UUID = CBUUID(string: "0xFFE0")
fileprivate let customChatacteristic_UUID = CBUUID(string: "0xFFE1")

// MARK: BluetoothModel 目前只有一個接口提供逼逼的 RFID 的 uuid
protocol BluetoothModelDelegate {
    func didReciveRFIDDate(uuid:String)
}

class BluetoothModel:NSObject{
    var delegate:BluetoothModelDelegate?
    var centralManager: CBCentralManager?
    var customPeripheral: CBPeripheral?
    var customCharacteristic:CBCharacteristic?
    
    // 為了singletion 設計的
    static let singletion = BluetoothModel()
    
    private override init() {
        super.init()
        let centralQueue:DispatchQueue = DispatchQueue(label: "centralQueue")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func sendDataToRFID(data: Data){
        customPeripheral?.writeValue(data, for: customCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        print(customPeripheral ?? "nil")
    }
}
// BluetoothModel 要用來監控所有的藍芽狀態，所以吃CBCentralManagerDelegate來用
// CBCentralManagerDelegate <-- 定義 CBCentralManager object 的代理必須符合的func . 其他提供選用的方法可用來監控外圍設備的掃描狀態，連線狀態，恢復狀態，唯一必須符合的方法是用來表示中心設備目前狀態，當中心設備的狀態改變時會被呼叫
//CBPeripheralDelegate <-- 提供func用來監控外圍設備的狀態
extension BluetoothModel:CBCentralManagerDelegate,CBPeripheralDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .unknown:
            print("未知狀態")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支援")
        case .unauthorized:
            print("未驗證")
        case .poweredOff:
            print("尚未啟動")
        case .poweredOn:
            print("啟動")
            // 因為很多Service掃出來是nil 所以設定全掃(withServices: nil)
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            print("未列入的新case")
        }
    }
    
    // 發現藍牙設備的時候，把設備存到自己的變數裡,然後告訴center連上
    // TODO: 確認是否能夠在沒連到指定設備時繼續掃描
    // TODO: 之後要把設備名稱hc08寫成變數
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("peripheral name:\(String(describing: peripheral.name))")
        print("service:\(String(describing: peripheral.services))")
        // 如果設備名稱對上了就連線
        if peripheral.name == "HC-08" {
            self.customPeripheral = peripheral
            centralManager?.connect(peripheral, options: nil)
            print("已找到HC-08")
        }
    }
    // 連接成功（連上hc-08）
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // TODO: ??這邊用self.centralManager?.stopScan() 跟 central.stopScan() 差別在哪
        // 連上之後就停止掃描
        print("連上hc-08")
        self.centralManager?.stopScan()
        peripheral.delegate = self
        customPeripheral?.discoverServices([customService_UUID])
        
    }
    
    // 連線失敗
    // 這邊要不要讓他重連呢？.connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("連線失敗")
    }

    // 斷線重連
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.centralManager?.connect(peripheral, options: nil)
    }
    
    // -------上面都是 centralManager 的事 下面開始處理外圍設備 peripheral-------
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services!{
            print("發現service \(service)")
            if service.uuid == customService_UUID{
                print("UUID吻合")
                // 為啥Ｅ寫nil 因為nil是全找
                peripheral.discoverCharacteristics([customChatacteristic_UUID], for: service)
            }
        }
    }
    
    // 找到 characteristic 之後 --> 讀取服務裡面的值 --> 監聽該值的變化
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics!{
            print("列出服務：\(characteristic)")
            // 確認uuid是我們要找的
            if characteristic.uuid == customChatacteristic_UUID{
                // 第一次跑到這時應該是nil
                print("服務中的value為：\(String(describing: characteristic.value))")
                customCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: customCharacteristic!)
            }
        }
    }
    
    // 監聽狀態
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil{
            print("監聽失敗")
            return
        }
        if characteristic.isNotifying{
            print("監聽中")
        }
    }
    
    // 接收數據 --> 檢查UUID正確 --> 把rfid_UUID資料寫進去
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // 確認服務id是我們要的
        guard characteristic.uuid == customChatacteristic_UUID else {return}
        if let val = characteristic.value, let rfid_UUID = String(data: val, encoding: .utf8){
            self.delegate?.didReciveRFIDDate(uuid: rfid_UUID)
        }
        else{
            print("characteristic.uuid正確，但是讀取數據錯誤")
        }
    }
}




