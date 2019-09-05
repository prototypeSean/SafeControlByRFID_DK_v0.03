//
//  SafeControlViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/30.
//  Copyright © 2019 DennisKao. All rights reserved.
//
// 人員管制的首頁 臨時版

import UIKit
// 第一次收到收到RFID要把人放到清單上 第二次要移除
// 這裡的資料靠 SafeControlModel 提供
class SafeControlViewController: UIViewController, BluetoothModelDelegate {
    
    var firecommandDB: FirecommandDatabase!

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
