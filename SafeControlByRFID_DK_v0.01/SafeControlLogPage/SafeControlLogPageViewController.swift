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
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        countSections()
    }
    
    
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
//            print("model?.logEnter\(String(describing: model?.logEnter))")
            return model?.logEnter.count ?? 0
        }
//        print("model?.logLeave\(String(describing: model?.logLeave))")
        return model?.logLeave.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogTableViewCell") as! SafeControlLogTableViewCell
        
        if tableView.restorationIdentifier == "enter"{
            cell.setFireman(fireman: model!.logEnter[indexPath.row])
            cell.status.text = "進入"
            // 臨時外觀設定
//            let cellMarginViewHeight = cell.marginView.layer.bounds.height
            cell.marginView.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            cell.marginView.backgroundColor = #colorLiteral(red: 1, green: 0.4039215686, blue: 0.1882352941, alpha: 1)
            // 臨時外觀設定
//            cell.setColorSetting(colorSetting: .Enter)
//            cell.contentView.layer.borderWidth = 2
//            cell.contentView.layer.cornerRadius = 15
        }else{
            cell.setFiremanOut(fireman: model!.logLeave[indexPath.row])
            cell.status.text = "離開"
            // 臨時外觀設定
//            let cellMarginViewHeight = cell.marginView.layer.bounds.height
            cell.marginView.layer.cornerRadius = 5
            cell.backgroundColor = UIColor.clear
            cell.marginView.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.968627451, blue: 0.8549019608, alpha: 1)
            // 臨時外觀設定
//            cell.setColorSetting(colorSetting: .Leave)
        }
        return cell
    }
    // MARK:這裡有一堆計算陣列跟時間的要做成筆記或入庫
    // 要要製作區分每天的section
    // 需要計算出有幾天->才知道有幾個section header
    // 計算log裡面總共有哪些日期
    
    /// 時間戳轉成純文字
    ///
    /// - Parameters:
    ///   - timestamp: 時間戳
    ///   - theDateFormat: "YY-MM-dd" 之類的格式
    /// - Returns: "YY-MM-dd"之類的字串
    func timeStampToString(timestamp:Double, theDateFormat:String) -> String{
        let dateformate = DateFormatter()
        //Double轉成日期
        let date = Date(timeIntervalSince1970: timestamp)
        //由參數設定指定格式
        dateformate.dateFormat = theDateFormat
        return dateformate.string(from: date)
    }
    
    // 傳入的string 一定要跟 stringsDateFormat設定的格式一樣
    func stringToDate(from string:String, stringsDateFormat:String) -> Date{
        let dateformate = DateFormatter()
        dateformate.dateFormat = stringsDateFormat
        return dateformate.date(from: string)!
    }
    
    enum logSectionCase {
        case enter
        case exit
    }
    
    func countSections(){
        var entersSection:Array<String> = []
        var leavesSection:Array<String> = []
        for ffbs in self.model!.logEnter{
            // 逐個把時間戳轉成日期->找出有幾天
            let tpIn = Double(ffbs.timestamp)!
            let dateInString = timeStampToString(timestamp: tpIn, theDateFormat: "YYYY-MM-dd")
//            print("\(ffbs.name) 的 進入年月日 \(dateInString)")
            entersSection.append(dateInString)
        }
        
        for ffbs in self.model!.logLeave{
            print("\(ffbs.name) 的 timeStamps Leave:\(ffbs.timestampout)")
            
        }
        // 用純文字的陣列來移除重複日期
        entersSection = Array(NSOrderedSet(array: entersSection)) as! Array<String>
        // 把剩下的陣列賺回date照日期重新排序
        var convertedArray: [Date] = []
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        // 最後要用的東西
        var entersSectionString:[String] = []
        
        for dat in entersSection {
            
            let date = dateFormatter2.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        // 排序 這也能拿來用其實 只是型態不是字串
        let ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        for sss in ready{
            entersSectionString.append(dateFormatter2.string(from: sss))
        }
        
        
        print("計算有幾個進入日期 \(entersSectionString)")
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
