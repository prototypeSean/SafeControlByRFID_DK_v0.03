//
//  FiremanCollectionView.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/16.
//  Copyright © 2019 elijah tam. All rights reserved.
//
// 最上層顯示消防員大頭跟各種欄位的cell 暫時都不改 先吃得下DB再說
import Foundation
import UIKit

class FiremanCollectionViewCell:UICollectionViewCell{
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var timestampLable: UILabel!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var barLeftVIew: BarLeftView!
    
    private var timestamp:TimeInterval?
    // 單位是秒
    let barMaxTime:Double = 30
    
    override func awakeFromNib() {
        // cell的圓角
        self.layer.cornerRadius = 5.0
        super.awakeFromNib()
        self.backgroundColor = LifeCircleColor.normal.getUIColor()
        countDown()
    }
    
    // 準備好一個消防員的cell需要呈現的資料
    // 時間計算方法：逼逼的時候存入資料庫逼逼的時間 -> 要計算的時候用(當下時間-逼逼時間)=進去了多久
    // 因為sqlite只能存純文字 所以需要一些轉換
    // 時間戳label 應該要顯示進去多久
    func setFireman(fireman:FiremanForBravoSquad?){
        if fireman == nil{
            self.nameLable.text = nil
            self.photo.image = nil
            timestampLable.text = nil
            timestamp = nil
            changeColor(by: 1)
            barLeftVIew.setBar(ratio: 1)
            return
        }
        self.nameLable.text = fireman!.name
        self.photo.image = fireman!.image
        
        // 從資料庫讀出時間戳字串-->取最後一筆-->拿來計算(會取到逼逼出來的？)
        
        
        // 從資料庫取出並轉成陣列
        let dateStringArray = fireman!.timestamp.components(separatedBy: ",")
        
        // 最新的一筆拿來計算？
        let latestTimeStamp = dateStringArray.last
        
        // 把他轉成可以計算的格式 String->時間戳1970格式 --> 傳給上面func外的變數給countdown用
        let doubleLtestTimeStamp = Double(latestTimeStamp!)!
        self.timestamp = doubleLtestTimeStamp
        
        print("最後一筆時間戳\(String(describing: latestTimeStamp))")
        
        
        // 要給label顯示的時間字串格式
        let dateFormater:DateFormatter = DateFormatter()
        dateFormater.dateFormat = "HH:mm:ss"
        let dateTimeLabel = Date(timeIntervalSince1970: doubleLtestTimeStamp)
        timestampLable.text = dateFormater.string(from: dateTimeLabel)
        
        // 現在時間 - 逼楅時間
        let time_diff = Date().timeIntervalSince1970 - doubleLtestTimeStamp
        print("time_diff:\(time_diff)")
        // (總氣瓶時間 -(進去了多久))/ 總時間
        
        var ratio:Double = (barMaxTime - time_diff)/barMaxTime
        ratio = ratio < 0 ? 0:ratio;
        changeColor(by: ratio)
        barLeftVIew.setBar(ratio: ratio)
    }
    
    
    //
    func countDown(){
        if timestamp == nil{
            //changeColor(by: 1)
            //barLeftVIew.setBar(ratio: 1)
//            print("func countDown 沒抓到時間戳!")
        }
        else{
            let time_diff = Date().timeIntervalSince1970 - timestamp!
            var ratio:Double = (barMaxTime - time_diff)/barMaxTime
            // 三元表達式 if ratio<0 就令 ratio=0 else ratio=ratio
            ratio = ratio < 0 ? 0:ratio;
            changeColor(by: ratio)
            barLeftVIew.setBar(ratio: ratio)
        }
        // 每0.1秒執行一次自己 直到instance解放 應該改成ratio=0就停
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.countDown()
//            print("倒數一次")
        }
    }
    
    private func changeColor(by ratio:Double){
        var colorSetting:LifeCircleColor = LifeCircleColor.normal
        if ratio <= 0.5{
            colorSetting = .alert
        }
        if ratio < 0.3{
            colorSetting = .critical
        }
        self.backgroundColor = colorSetting.getUIColor()
        barLeftVIew.setBar(color: colorSetting)
    }
}


