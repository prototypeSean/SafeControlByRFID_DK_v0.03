//
//  SafeControllModel.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/15.
//  Copyright © 2019 elijah tam. All rights reserved.
//
// 人員管制頁面的資料處理
//
import Foundation

// 只是個時間點的flag的樣子
protocol SafeControlModelDelegate{
    func dataDidUpdate()
}

protocol SafeControldelegateforAddNewFireman{
    func newFiremanRFID(uuid:String)
}
// 顯示用的小隊：陣列<消防員>
struct BravoSquad {
    var fireMans:Array<FiremanForBravoSquad>
}


class SafeControlModel:NSObject{
    
    
    // 連上資料庫（這邊要用let還是var尚存疑）
    var firemanDB = FirecommandDatabase()
    
    // 所有的小隊-- 每個小隊一個tableViewCell 每個Cell一個BravoSquad
    private var bravoSquads:Array<BravoSquad> = []
    // 進出紀錄log
    private(set) var logEnter:Array<FiremanForBravoSquad> = []
    private(set) var logLeave:Array<FiremanForBravoSquad> = []
    
    // 初始化的時候把藍芽連上 把要顯示的各小隊跟隊員準備好
    override init() {
        super.init()
        BluetoothModel.singletion.delegate = self
        bravoSquads.append(BravoSquad(fireMans: []))
    }
    
    // 資料更新的時候用的旗子
    var delegate:SafeControlModelDelegate?
    var delegateForLog:SafeControlModelDelegate?
    var delegateForAddFireman:SafeControldelegateforAddNewFireman?
    
    // 吃uuid當參數 試著把人從小隊中移出 並寫入logLeave中，移出成功＝true
    private func removeFireman(by uuid:String) -> Bool{
        // test
        //return false
        for bravoSquadIndex in 0 ..< bravoSquads.count{
            if let index = bravoSquads[bravoSquadIndex].fireMans.firstIndex(where: {$0.uuid == uuid}){
                logLeave.append(bravoSquads[bravoSquadIndex].fireMans[index])
                bravoSquads[bravoSquadIndex].fireMans.remove(at: index)
                return true
            }
        }
        return false
    }
    
    // 與移出成對，把消防員加入BravoSquad，加入成功＝true
    private func addFireman(by uuid:String) -> Bool{
        if let fireman = firemanDB.getFiremanforBravoSquad(by: uuid){
            logEnter.append(fireman)
            bravoSquads[0].fireMans.append(fireman)
//            firemanDB.updateFiremanForBravoSquadaTime(by: uuid)
            return true
        }
        return false
    }
    
    private func sortLogData(){
        logEnter.sort(by: {$0.uuid > $1.uuid})
        logEnter.sort { (a, b) -> Bool in
            return a.uuid > b.uuid
        }
        logLeave.sort(by: {$0.uuid > $1.uuid})
    }
}

// public API
extension SafeControlModel{
    func getBravoSquads() -> Array<BravoSquad>{
        return self.bravoSquads
    }
}

// delegate from bluetooth 收到藍牙傳來的UUID 就新增或移除人員,然後再給兩個ＶＣ一根旗子讓他們刷新頁面
extension SafeControlModel:BluetoothModelDelegate{
    func didReciveRFIDDate(uuid: String) {
        print("收到RFID:--處理中")
        // 如果移除失敗就新增 如果移除成功就會遇到return跳出迴圈
        if !removeFireman(by: uuid){
            if(!addFireman(by: uuid)){
                print("uuid not fuund in database!")
            }
        }
        sortLogData()
        delegate?.dataDidUpdate()
        delegateForLog?.dataDidUpdate()
        delegateForAddFireman?.newFiremanRFID(uuid: uuid)
    }
}
