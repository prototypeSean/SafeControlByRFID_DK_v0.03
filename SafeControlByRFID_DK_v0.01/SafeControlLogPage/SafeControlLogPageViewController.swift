//
//  SafeControllLogPageViewController.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/18.
//  Copyright © 2019 elijah tam. All rights reserved.
//

import Foundation
import UIKit

class SafeControlLogPageViewController:UIViewController{
    @IBOutlet weak var safeControlEnterLogTableView: UITableView!
    @IBOutlet weak var safeControlLeaveLogTableView: UITableView!
    private var model:SafeControlModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safeControlEnterLogTableView.delegate = self
        safeControlEnterLogTableView.dataSource = self
        safeControlEnterLogTableView.restorationIdentifier = "enter"
        safeControlLeaveLogTableView.delegate = self
        safeControlLeaveLogTableView.dataSource = self
        safeControlLeaveLogTableView.restorationIdentifier = "leave"
    }
    
    // 邪門的delegate用法在這
    func setupModel(model:SafeControlModel){
        self.model = model
        model.delegateForLog = self
    }
}

extension SafeControlLogPageViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "enter"{
            return model?.logEnter.count ?? 0
        }
        return model?.logLeave.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogTableViewCell") as! SafeControlLogTableViewCell
        
        if tableView.restorationIdentifier == "enter"{
            cell.setFireman(fireman: model!.logEnter[indexPath.row])
            cell.status.text = "進入"
            // 臨時外觀設定
            let cellMarginViewHeight = cell.marginView.layer.bounds.height
            cell.marginView.layer.cornerRadius = cellMarginViewHeight/2
            cell.backgroundColor = UIColor.clear
            cell.marginView.backgroundColor = #colorLiteral(red: 1, green: 0.4039215686, blue: 0.1882352941, alpha: 1)
            // 臨時外觀設定
//            cell.setColorSetting(colorSetting: .Enter)
//            cell.contentView.layer.borderWidth = 2
//            cell.contentView.layer.cornerRadius = 15
        }else{
            cell.setFireman(fireman: model!.logLeave[indexPath.row])
            cell.status.text = "離開"
            // 臨時外觀設定
            let cellMarginViewHeight = cell.marginView.layer.bounds.height
            cell.marginView.layer.cornerRadius = cellMarginViewHeight/2
            cell.backgroundColor = UIColor.clear
            cell.marginView.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.968627451, blue: 0.8549019608, alpha: 1)
            // 臨時外觀設定
//            cell.setColorSetting(colorSetting: .Leave)
        }
        
        return cell
    }
}

extension SafeControlLogPageViewController:SafeControlModelDelegate{
    func dataDidUpdate() {
        DispatchQueue.main.async {
            self.safeControlEnterLogTableView.reloadData()
            self.safeControlLeaveLogTableView.reloadData()
        }
    }
}
