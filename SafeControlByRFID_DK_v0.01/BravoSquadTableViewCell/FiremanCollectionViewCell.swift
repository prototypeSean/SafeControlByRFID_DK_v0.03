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
    let barMaxTime:Double = 30
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = LifeCircleColor.normal.getUIColor()
        countDown()
    }
    
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
        self.photo.image = UIImage(named: fireman!.uuid)
        
        // 這裡應該是要把時間戳轉成純文字
        let dateFormater:DateFormatter = DateFormatter()
        dateFormater.dateFormat = "HH:mm:ss"
        
        // TODO:-- 這邊不太確定轉得對不對 DB存的已經是純文字應該不需要這麼麻煩
        // 把字串轉成Date -->再轉成1970-->運算
        //              -->轉成需要的文字格式
        let dateString = dateFormater.date(from: fireman!.timestamp)
        // 把 Date 傳成時間戳格式
        let dateTimeStamp  = dateString!.timeIntervalSince1970
        
        
        let date = Date(timeIntervalSince1970: dateTimeStamp)
        
        // 轉了半天為了顯示在這
        timestampLable.text = dateFormater.string(from: date)
        
        timestamp = dateTimeStamp
        let time_deff = Date().timeIntervalSince1970 - timestamp!
        var ratio:Double = (barMaxTime - time_deff)/barMaxTime
        ratio = ratio < 0 ? 0:ratio;
        changeColor(by: ratio)
        barLeftVIew.setBar(ratio: ratio)
    }
    
    func countDown(){
        if timestamp == nil{
            //changeColor(by: 1)
            //barLeftVIew.setBar(ratio: 1)
        }
        else{
            let time_deff = Date().timeIntervalSince1970 - timestamp!
            var ratio:Double = (barMaxTime - time_deff)/barMaxTime
            // 三元表達式 if ratio<0 就令 ratio=0 else ratio=ratio
            ratio = ratio < 0 ? 0:ratio;
            changeColor(by: ratio)
            barLeftVIew.setBar(ratio: ratio)
        }
        // 每0.1秒執行一次自己 直到instance解放 應該改成ratio=0就停
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.countDown()
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


