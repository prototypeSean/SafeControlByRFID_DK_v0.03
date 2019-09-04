//
//  SafeControlViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/30.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit
// 第一次收到收到RFID要把人放到清單上 第二次要移除
class SafeControlViewController: UIViewController, BluetoothModelDelegate {
    
    var firecommandDB: FirecommandDatabase!
    
    
//    @IBAction func addFireManBtn(_ sender: Any) {
//        firecommandDB.addNewFireman(serialNumber: 65536, firemanName: "某某某", firemanCallsign: "謝謝你9527", firemanRFID: "123123", firemanDepartment: "第三新東京大隊")
//    }
    
    
    @IBOutlet weak var SafeControlTableView: UITableView!
    func didReciveRFIDDate(uuid: String) {
        print("收到RFID Data ＝ \(uuid)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BluetoothModel.singletion.delegate = self
        // 建立DB連線
        firecommandDB = FirecommandDatabase()
        firecommandDB.createTableFireman()
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
