//
//  SafeControlViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/30.
//  Copyright © 2019 DennisKao. All rights reserved.
//
// 人員管制的首頁

import UIKit
// 第一次收到收到RFID要把人放到清單上 第二次要移除
// 這裡的資料靠 SafeControlModel 提供
class SafeControlViewController: UIViewController{
    @IBAction func rere(_ sender: UIButton) {
        self.SafeControlTableView.beginUpdates()
        self.SafeControlTableView.endUpdates()
    }
    
    var firecommandDB: FirecommandDatabase!

    let model = SafeControllModel()
    
    
    @IBOutlet weak var SafeControlTableView: UITableView!
    
//    func didReciveRFIDDate(uuid: String) {
//        print("收到RFID Data ＝ \(uuid)")
//    }
    override func viewWillAppear(_ animated: Bool) {
        SafeControlTableView.delegate = self
        SafeControlTableView.dataSource = self
        model.delegate = self
//        SafeControlTableView.estimatedRowHeight = 600
//        SafeControlTableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        BluetoothModel.singletion.delegate = self
        // 建立DB連線
        firecommandDB = FirecommandDatabase()
        firecommandDB.createTableFireman()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddNewFiremanViewController
        destination.setupModel(model: model)
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

extension SafeControlViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.getBravoSquads().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BravoSquadTableViewCell") as! BravoSquadTableViewCell
        let bravoSquad = model.getBravoSquads()[indexPath.row]
        cell.setBravoSquad(bravoSquad: bravoSquad)
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? BravoSquadTableViewCell{
//        let bravoSquad = model.getBravoSquads()[indexPath.row]
        print("condition:\(cell.ppp.count)")
        
        if cell.ppp.count >= 5 && indexPath.section == 0{
            
            print("ppp高度高度\(CGFloat(cell.ppp.count*600))")
            return CGFloat(cell.ppp.count/5*600)
        }else
        {
            return 600
            }}
        return 600
    }
}

extension SafeControlViewController:SafeControllModelDelegate{
    func dataDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.SafeControlTableView.reloadData()
            print("更新資料by Model delegate & 已執行 -- reloadData")
        }
    }
}
