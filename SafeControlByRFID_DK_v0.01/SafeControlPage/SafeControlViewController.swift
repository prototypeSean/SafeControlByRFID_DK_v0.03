//
//  SafeControlViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/30.
//  Copyright © 2019 DennisKao. All rights reserved.
//
// 人員管制的首頁
// 安管頁面最外層的VC 要吃下兩個協議來使用tableView的func

import UIKit
// 第一次收到收到RFID要把人放到清單上 第二次要移除
// 這裡的資料靠 SafeControlModel 提供
class SafeControlViewController: UIViewController{
    
    var firecommandDB: FirecommandDatabase!

    let model = SafeControllModel()
    
    @IBOutlet weak var SafeControlTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        SafeControlTableView.delegate = self
        SafeControlTableView.dataSource = self
        model.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 建立DB連線
        firecommandDB = FirecommandDatabase()
        firecommandDB.createTableFireman()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddNewFiremanViewController
        /// 有點邪門的寫法，因為註冊頁面是child的關係，這樣兩個VC都會收到delegate
        destination.setupModel(model: model)
    }
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
//        if let cell = tableView.cellForRow(at: indexPath) as? BravoSquadTableViewCell{
//        let bravoSquad = model.getBravoSquads()[indexPath.row]
//        print("condition:\(cell.ppp.count)")
        
        var firemansInbravoSquad = model.getBravoSquads()[indexPath.row].fireMans.count
            
        var rows = firemansInbravoSquad % 5
        if rows < 1{
            rows = 1
            print("有幾行消防員----\(rows)")
        }
        return CGFloat(rows*420)
//        if cell.ppp.count >= 5 && indexPath.section == 0{
//
//            print("ppp高度高度\(CGFloat(cell.ppp.count*600))")
//            return CGFloat(cell.ppp.count/5*600)
//        }else
//        {
//            return 600
//            }}
//        return 600
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
