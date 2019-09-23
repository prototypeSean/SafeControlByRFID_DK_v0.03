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
        makeSectionCell(logSectionCase: .enter)
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
            print("計算每個區域有多少row-- in\(self.makeSectionCell(logSectionCase: .enter)[section].man.count)")
            return self.makeSectionCell(logSectionCase: .enter)[section].man.count
//            return model?.logEnter.count ?? 0
        }
//        print("model?.logLeave\(String(describing: model?.logLeave))")
        print("計算每個區域有多少row-- exit\(self.makeSectionCell(logSectionCase: .enter)[section].man.count)")
        return self.makeSectionCell(logSectionCase: .exit)[section].man.count
//        return model?.logLeave.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.restorationIdentifier == "enter"{
            let ee = countSections().enter
            print("進入表格有幾區\(ee.count)")
            return ee.count
        }
        else{
            let ee = countSections().exit
            print("撤離表格有幾區\(ee.count)")
            return ee.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.restorationIdentifier == "enter"{
            let entSectionTitle = countSections().enter[section]
            return entSectionTitle
        }else{
            return countSections().exit[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SafeControlLogTableViewCell", for: indexPath) as! SafeControlLogTableViewCell
        
        if tableView.restorationIdentifier == "enter"{
//            cell.setFireman(fireman: model!.logEnter[indexPath.row])
            cell.status.text = "進入"
            let e = makeSectionCell(logSectionCase: .enter)
            
            cell.setFireman(fireman: e[indexPath.section].man[indexPath.row])

//            cell.timestamp.text = e[indexPath.section].day
            
            
            // 臨時外觀設定
            // let cellMarginViewHeight = cell.marginView.layer.bounds.height
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
    
    /// 工具: 時間戳轉成純文字
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
    
    /// 目標是得到整個logTableView要顯示多少 Section (日期)；
    /// DB 已經分類存了[進入]跟[離開]火場的欄位,並分別做成logEnter/logLeave兩種 <FiremanForBravoSquad> 陣列
    /// 所以這邊針對 logEnter logLeave 做整理來取出目標為兩個陣列「進入有哪些天」「出來有哪些天」
    func countSections() -> (enter:[String],exit:[String]){
        var entersSection:Array<String> = []
        var leavesSection:Array<String> = []
        
        // 最後要用的東西
        var entersSectionString:[String] = []
        var leavesSectionString:[String] = []
        for ffbs in self.model!.logEnter{
            // 逐個把時間戳轉成日期->找出有幾天
            let tpIn = Double(ffbs.timestamp)!
            let dateInString = timeStampToString(timestamp: tpIn, theDateFormat: "YYYY-MM-dd")
            //  print("\(ffbs.name) 的 進入年月日 \(dateInString)")
            entersSection.append(dateInString)
        }
        // logLeave 已經是只有“離開”時間戳的bravoSquad了
        for ffbs in self.model!.logLeave{
            let tpOut = Double(ffbs.timestampout)!
            let dateInString = timeStampToString(timestamp: tpOut, theDateFormat: "YYYY-MM-dd")
            // print("\(ffbs.name) 的 進入年月日 \(dateInString)")
            leavesSection.append(dateInString)
        }
        
        // 用純文字的陣列來移除重複日期 NSOrderedSet 比起set 多了會保留原本順序的特性(而且比較快？)
        entersSection = Array(NSOrderedSet(array: entersSection)) as! Array<String>
        leavesSection = Array(NSOrderedSet(array: leavesSection)) as! Array<String>
        
        // 把剩下的陣列存回date型態 等下要用來依日期重新排序
        var convertedArrayIn: [Date] = []
        var convertedArrayOut: [Date] = []
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        
        for d in entersSection {
            let date = dateFormatter2.date(from: d)
            if let date = date {
                convertedArrayIn.append(date)
            }
        }
        for d in leavesSection {
            let date = dateFormatter2.date(from: d)
            if let date = date {
                convertedArrayOut.append(date)
            }
        }
        // 照日期降序排 這也能拿來用其實 只是型態不是字串
        let resultIn = convertedArrayIn.sorted(by: { $0.compare($1) == .orderedDescending })
        let resultOut = convertedArrayOut.sorted(by: { $0.compare($1) == .orderedDescending })
        
        // 最後一個for了..轉成字串
        for rin in resultIn{
            entersSectionString.append(dateFormatter2.string(from: rin))
        }
        for rOut in resultOut{
            leavesSectionString.append(dateFormatter2.string(from: rOut))
        }
        
        
//        print("全部的進入日期 \(entersSectionString)\n全部的撤離日期 \(leavesSectionString)\n")
        return (entersSectionString,leavesSectionString)
    }
    
    func makeSectionCell(logSectionCase:logSectionCase) -> Array<(day:String,man:[FiremanForBravoSquad])>{
        // 製作整個 LogTableView 最後輸出的格式 <日：[人人人]>
        var makeSectionCellEnter:Array<(day:String,man:[FiremanForBravoSquad])>=[]
        var makeSectionCellExit:Array<(day:String,man:[FiremanForBravoSquad])>=[]
        // 依序填入日期
        switch logSectionCase {
        case .enter:
            for entSection in countSections().enter{
                makeSectionCellEnter.append((entSection,[]))
                // 從log裡面撈出日期一樣的填入FFBS
                for eachEntlog in model!.logEnter{
                    let d = Double(eachEntlog.timestamp)
                    let date = timeStampToString(timestamp: d!, theDateFormat: "YYYY-MM-dd")
//                    print("eachEntlogDay\(date)")
                    if let index = makeSectionCellEnter.firstIndex(where:{$0.day == date}) {
                        makeSectionCellEnter[index].man.append(eachEntlog)
                    }else{
//                        print("進入日期不合")
                    }
                }
            }
            return makeSectionCellEnter
        case .exit:
            for entSection in countSections().exit{
                makeSectionCellExit.append((entSection,[]))
                // 從log裡面撈出日期一樣的填入FFBS
                for eachEntlog in model!.logEnter{
                    let d = Double(eachEntlog.timestamp)
                    let date = timeStampToString(timestamp: d!, theDateFormat: "YYYY-MM-dd")
                    print("eachEntlogDay\(date)")
                    if let index = makeSectionCellExit.firstIndex(where:{$0.day == date}) {
                        makeSectionCellExit[index].man.append(eachEntlog)
                    }else{
                        print("撤出日期不合")
                    }
                }
            }
            return makeSectionCellExit
        }
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
