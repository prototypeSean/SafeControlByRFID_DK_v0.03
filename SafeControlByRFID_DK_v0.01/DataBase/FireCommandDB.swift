//
//  FireCommandDB.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/30.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import Foundation
import SQLite

class FirecommandDatabase {
//                       :PhotoPathJustSaved
    var firemanPhotoPath:URL?
    var photoManager:PhotoManager?

    var  db: Connection!
    init() {
        connectDatabase()
    }
    
    // TODO: 排序方法還沒寫 要寫給外部控制
    // 每次進去跟出來的人的 BravoSquad
    // 由 firemanForLog() 生產
    var arrayEnter:Array<FiremanForBravoSquad> = []
    var arrayExit:Array<FiremanForBravoSquad> = []
    
    // 整理出進入跟撤離任務的 Day
    // 由 missionDeployedDay() 生產
    var entersDaysString:[String] = []
    var leavesDaysString:[String] = []
    
    // log 相關的最後一步
    var makeSectionCellEnter:Array<FiremanForLog>=[]
    var makeSectionCellExit:Array<FiremanForLog>=[]
    
    
    
    
    // delegate 來的 func
    // TODO: 暫時沒用，待修
//    func getPhotoPath(photoPath: URL) {
//        firemanPhotoPath = photoPath
//    }
    
    func connectDatabase(){
    // 把DB存到(或新建)使用者檔案路徑中的db.sqlite3
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do{
            db = try Connection("\(path)/db.sqlite3")
            print("資料庫連線成功")
        }catch{
            print("資料庫連線失敗 \(error)")
        }
    }
    // MARK: ----- 設計表格 FIREMAN 及其欄位 -----
    let table_FIREMAN = Table("table_fireman")
    let table_FIREMAN_ID = Expression<Int64>("id")
    let table_FIREMAN_SN = Expression<String>("serialNumber")
    let table_FIREMAN_NAME = Expression<String>("firemanName")
    let table_FIREMAN_PHOTO_PATH = Expression<String>("firemanPhotoPath")
    let table_FIREMAN_CALLSIGN = Expression<String>("firemanCallsign")
    let table_FIREMAN_RFIDUUID = Expression<String>("firemanRFID")
    let table_FIREMAN_TIMESTAMP = Expression<String>("firemanTimeStamp")
    let table_FIREMAN_TIMESTAMPOUT = Expression<String>("firemanTimeStampOUT")
    let table_FIREMAN_DEPARTMENT = Expression<String>("firemanDepartment")
    
    // 創建表格
    func createTableFireman() {
        do{
            try db.run(table_FIREMAN.create{table in
                table.column(table_FIREMAN_ID, primaryKey: .autoincrement)
                table.column(table_FIREMAN_SN)
                table.column(table_FIREMAN_NAME)
                table.column(table_FIREMAN_PHOTO_PATH)
                table.column(table_FIREMAN_CALLSIGN)
                table.column(table_FIREMAN_RFIDUUID)
                table.column(table_FIREMAN_TIMESTAMP, defaultValue: "初始in時間戳欄位")
                table.column(table_FIREMAN_TIMESTAMPOUT, defaultValue: "初始out時間戳欄位")
                table.column(table_FIREMAN_DEPARTMENT)
            })
            print("建立 FIREMAN 表格成功")
        }catch
        {
            print("建立 FIREMAN 表格失敗！\(error)")
        }
    }
    
    // MARK: -- 表格的操作方法(應該要拉出來出來做成delegate?)
    // 新增 FireMan
    // 照片在這邊處理：吃入的參數是UIimage 要在這邊轉成檔案路徑String
    func addNewFireman(serialNumber:String,
                       firemanName:String,
                       firemanPhoto:UIImage,
                       firemanCallsign:String,
                       firemanRFID:String,
                       firemanTimeStamp:String,
                       firemanTimeStampOut:String,
                       firemanDepartment:String){
        // 讓PhotoManager介入把照片存入檔案
        photoManager = PhotoManager()
        // 要生成資料庫的時候才把照片存入本地
        let path = photoManager!.saveImageToDocumentDirectory(image: firemanPhoto, filename: firemanRFID)
        
        // 有空再處理TODO:-- 這行對應上面的暫時沒用,有空再處理（存好之後把 URL 傳入此處變數）
//        photoManager?.delegate=self
        
        
        // table_FIREMAN_PHOTO_PATH 要把 URL 轉成純文字
        let insert = table_FIREMAN.insert(
            table_FIREMAN_SN <- serialNumber,
            table_FIREMAN_NAME <- firemanName,
            table_FIREMAN_PHOTO_PATH <- path!.absoluteString,
            table_FIREMAN_CALLSIGN <- firemanCallsign,
            table_FIREMAN_RFIDUUID <- firemanRFID,
            table_FIREMAN_TIMESTAMP <- firemanTimeStamp,
            table_FIREMAN_TIMESTAMPOUT <- firemanTimeStampOut,
            table_FIREMAN_DEPARTMENT <- firemanDepartment)
        
        do{
            try db.run(insert)
            print("新增一名Fireman成功")
        }catch
        {
            print("新增一名Fireman失敗")
        }
    }
    
    
}

// 提供給安管系統的簡易版名單
public struct FiremanForBravoSquad {
    let name:String
    let uuid:String
    let timestamp:String
    let timestampout:String
    let image:UIImage
}
// 提供給 Log 頁面的struct
public struct FiremanForLog{
    let dayOnSection:String
    let fireman:Array<FiremanForBravoSquad>
}



// MARK: 取出最新一筆進入火場時間 (每次滾動都會跑一次這func可能日後會有問題)
/// 獲取最新一筆進入的時間戳
///
/// - Parameter fireman: FiremanForBravoSquad
/// - Returns: 純文字時間戳
public func getLatestedTimeStamp(fireman:FiremanForBravoSquad) -> String{
    
    // 從資料庫取出並轉成陣列
    let dateStringArray = fireman.timestamp.split(separator: ",")
//    print("getLatestedTimeStamp!!!!\(dateStringArray)")
    // 最新的一筆
    let latestTimeStamp = dateStringArray.last
    // 純文字轉乘Double = 時間戳 因為本來內容就是時間戳 轉成double就好了
    let doubleLtestTimeStamp = Double(latestTimeStamp!)!
    
    // 把最後一筆時間戳轉成時間格式
    let dateFormater:DateFormatter = DateFormatter()
    dateFormater.dateFormat = "HH:mm:ss"
    let dateTimeLabel = Date(timeIntervalSince1970: doubleLtestTimeStamp)
    let timestampLableText = dateFormater.string(from: dateTimeLabel)
    return timestampLableText
}


// 已經在removeFireman裡面更新DB 所以取出最後一筆離開火場資料暫時用不到??
/// 獲取最新一筆離開的時間戳
///
/// - Parameter fireman: FiremanForBravoSquad
/// - Returns: 純文字時間戳
public func getLatestedTimeStampOut(fireman:FiremanForBravoSquad) -> String{
    
    // 從資料庫取出並轉成陣列
    let dateStringArray = fireman.timestampout.split(separator: ",")
//    print("getLatestedTimeStampOut!!!!\(dateStringArray)")
    // 最新的一筆
    let latestTimeStamp = dateStringArray.last
    // 純文字轉Double = 時間戳 因為本來內容就是時間戳 轉成double就好了
    let doubleLtestTimeStamp = Double(latestTimeStamp!)!
    
    // 把最後一筆時間戳轉成時間格式
    let dateFormater:DateFormatter = DateFormatter()
    dateFormater.dateFormat = "HH:mm:ss"
    let dateTimeLabel = Date(timeIntervalSince1970: doubleLtestTimeStamp)
    let timestampLableText = dateFormater.string(from: dateTimeLabel)
    return timestampLableText
}


// 各種ＡＰＩ寫在這
extension FirecommandDatabase{

    enum logType {
        case enter
        case exit
    }
    
    
    // 製作 FireManForLog Struct的 dayOnSection欄位
    // 任務日期 分進入跟離開（嗶嗶進入跟撤離任務的Day）
    func missionDeployedDay(){
        
        // 先清空
        entersDaysString = []
        leavesDaysString = []
        
        var entersSection:Array<String> = []
        var leavesSection:Array<String> = []

        for ffbs in arrayEnter{
            // 逐個把時間戳轉成日期->找出有幾天
            let tpIn = Double(ffbs.timestamp)!
            let dateInString = timeStampToString(timestamp: tpIn, theDateFormat: "YYYY-MM-dd")
            //  print("\(ffbs.name) 的 進入年月日 \(dateInString)")
            entersSection.append(dateInString)
        }
        // logLeave 已經是只有“離開”時間戳的bravoSquad了
        for ffbs in arrayExit{
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
            self.entersDaysString.append(dateFormatter2.string(from: rin))
        }
        for rOut in resultOut{
            self.leavesDaysString.append(dateFormatter2.string(from: rOut))
        }
        
        // print("全部的進入日期 \(entersSectionString)\n全部的撤離日期 \(leavesSectionString)\n")
//        return (entersSectionString,leavesSectionString)
    }
    
    func allFireman(){
        for item in (try! db.prepare(table_FIREMAN)){
            print("消防員in table_FIREMAN\n id:\(item[table_FIREMAN_ID])\n,SN:\(item[table_FIREMAN_SN])\n,NAME:\(item[table_FIREMAN_NAME])\n,PhotoPaht:\(item[table_FIREMAN_PHOTO_PATH])\n,CALL SIGN:\(item[table_FIREMAN_CALLSIGN])\n,RFID:\(item[table_FIREMAN_RFIDUUID])\n,DEPARTMENT:\(item[table_FIREMAN_DEPARTMENT]),時間戳進入:\(item[table_FIREMAN_TIMESTAMP]),時間戳出:\(item[table_FIREMAN_TIMESTAMPOUT])")
        }
    }
    
    // 專門為log頁面撈資料用的 吐出的一組struct就是section跟裡面的cell
    func allfiremanForLogPage(){
        // 要先產出進去跟出來的日期才能做 TableView Section
        makeSectionCellEnter = []
        makeSectionCellExit = []
        
        firemanForLog()
        missionDeployedDay()
        print("執行 allfiremanForLog")

        
        // 基本上就是把兩個陣列再整理成表格的型態，因為時間戳格式不同要多一次轉換
        for d in entersDaysString{
            var mansInADay:Array<FiremanForBravoSquad>=[]
            for m in arrayEnter{
                if timeStampToString(timestamp: Double(m.timestamp)!, theDateFormat: "YYYY-MM-dd") == d{
                    print("插入同日期\(d)")
                    mansInADay.append(m)
                }
            }
            makeSectionCellEnter.append(FiremanForLog(dayOnSection: d, fireman: mansInADay))
        }
        
        for d2 in leavesDaysString{
            var mansInADay:Array<FiremanForBravoSquad>=[]
            for m in arrayExit{
                if timeStampToString(timestamp: Double(m.timestampout)!, theDateFormat: "YYYY-MM-dd") == d2{
                    mansInADay.append(m)
                }
            }
            makeSectionCellExit.append(FiremanForLog(dayOnSection: d2, fireman: mansInADay))
        }
        print("新版ＬＯＧ頁面清單:\n進：-- \(makeSectionCellEnter)\n出：--\(makeSectionCellExit)")
    }
    

    
    // TODO: 沒資料庫狀態觸發會閃退
    // 要吐出兩種log 進去跟出來的(存在變數裡面比較省運算)
    func firemanForLog(){

        //先清空
        self.arrayEnter = []
        self.arrayExit = []
        
        // fm = fireman row
        for fm in (try! db.prepare(table_FIREMAN)){
            
            photoManager = PhotoManager()
            // 讀取一個fm的照片 讀取失敗就用預設圖
            let imageFromlocalPath = photoManager?.loadImageFromDocumentDirectory(filename: fm[table_FIREMAN_RFIDUUID]) ?? UIImage(named: "ImageInApp")!
            
            // 把人拼成一個 FiremanForBravoSquad 只是這次每個人都只有一筆，同一個人會有很多次
            // 把兩種時間戳做成矩陣
            let timeInArray = fm[table_FIREMAN_TIMESTAMP].split(separator: ",")
            let timeOutArray = fm[table_FIREMAN_TIMESTAMPOUT].split(separator: ",")
            // 分開生成進去跟出來的陣列 每個人會有多個時間不同的FiremanForBravoSquad
            // 此特殊陣列有進入時間的話 出來時間就填為空。反之亦然
            
            for oneFiremansInTimeLog in timeInArray{
                let oneFiremanEachEnterLog = FiremanForBravoSquad(
                    name: fm[table_FIREMAN_NAME],
                    uuid: fm[table_FIREMAN_RFIDUUID],
                    timestamp: String(oneFiremansInTimeLog),
                    timestampout: "",
                    image: imageFromlocalPath)
                arrayEnter.append(oneFiremanEachEnterLog)
            }
            print("arrayEnter!! \(arrayEnter)")
            
            for one in timeOutArray{
                let oneFiremanEachExitLog = FiremanForBravoSquad(
                    name: fm[table_FIREMAN_NAME],
                    uuid: fm[table_FIREMAN_RFIDUUID],
                    timestamp: "",
                    timestampout: String(one),
                    image: imageFromlocalPath)
                arrayExit.append(oneFiremanEachExitLog)
            }
            
        }
//        switch logType{
//        case .enter:
//            return arrayEnter
//        case .exit:
//            return arrayExit
//        }
    }
    
    // MARK : 更新時間戳（進入火場）
    // 用uuid抓出特定的消防員時間戳欄位
    func readFiremanForBravoSquadaTime(by uuid:String) -> String{
        var currentTimeStamp = ""
        for fm in try! db.prepare(table_FIREMAN.filter(table_FIREMAN_RFIDUUID == uuid)){
            //            print("讀取更新前資料庫中的時間戳\(fm[table_FIREMAN_TIMESTAMP])")
            currentTimeStamp.append(fm[table_FIREMAN_TIMESTAMP])
        }
        return currentTimeStamp
    }
    
    // 更新log in-- 每次消防員逼逼的時候要更新(插入現在時間戳到timeStamp 欄位）
    func updateFiremanForBravoSquadaTime(by uuid:String){
        let fireman = table_FIREMAN.filter(table_FIREMAN_RFIDUUID == uuid)
        // 當前時間
        let currentTimeStamp = Date().timeIntervalSince1970
        print("嗶嗶時間戳\(currentTimeStamp)")
        // 取出消防員的時間戳欄位準備更新
        var timeStampUpdate = readFiremanForBravoSquadaTime(by: uuid)
        //        print("更新前資料庫時間戳\(timeStampUpdate)")
        // 把時間戳轉成 data-> 再轉成 String 才能存入
        let currenttimeStampString = String(currentTimeStamp)
        print("轉成文字的嗶嗶時間戳\(currenttimeStampString)")
        timeStampUpdate.append(contentsOf: "\(currenttimeStampString),")
        //        print("DB更新之後的時間戳：\(timeStampUpdate)")
        print("要更新的隊員\(fireman[table_FIREMAN_NAME])")
        do{
            let updatedRows = try db.run(fireman.update(table_FIREMAN_TIMESTAMP <- timeStampUpdate))
            if updatedRows > 0 {
                print("插入進入時間戳成功")
            }else{
                print("沒有發現消防員\(uuid)")
            }
        }catch{
            print("插入消防員時間戳失敗:\(error)")
        }
    }
    
    //MARK: 更新時間戳（離開火場）(這邊很蠢 其實可以合併為一組func但是沒時間了先這樣複製大法)
    // 用uuid抓出特定的消防員時間戳欄位(會抓到此人全部時間戳)
    func readFiremanForBravoSquadaTimeOut(by uuid:String) -> String{
        var currentTimeStamp = ""
        for fm in try! db.prepare(table_FIREMAN.filter(table_FIREMAN_RFIDUUID == uuid)){
            currentTimeStamp.append(fm[table_FIREMAN_TIMESTAMPOUT])
        }
        return currentTimeStamp
    }
    
    // 更新logout-- 每次消防員逼逼的時候要更新(插入現在時間戳到timeStamp 欄位）
    func updateFiremanForBravoSquadaTimeOut(by uuid:String){
        let fireman = table_FIREMAN.filter(table_FIREMAN_RFIDUUID == uuid)
        // 當前時間
        let currentTimeStamp = Date().timeIntervalSince1970
        print("嗶嗶時間戳\(currentTimeStamp)")
        // 取出消防員的時間戳欄位準備更新
        var timeStampUpdate = readFiremanForBravoSquadaTimeOut(by: uuid)
        // 把時間戳轉成 data-> 再轉成 String 才能存入
        let currenttimeStampString = String(currentTimeStamp)
        print("轉成文字的嗶嗶時間戳\(currenttimeStampString)")
        timeStampUpdate.append(contentsOf: "\(currenttimeStampString),")
        print("要更新的隊員\(fireman[table_FIREMAN_NAME])")
        do{
            let updatedRows = try db.run(fireman.update(table_FIREMAN_TIMESTAMPOUT <- timeStampUpdate))
            if updatedRows > 0 {
                print("插入離開時間戳成功")
            }else{
                print("沒有發現消防員\(uuid)")
            }
        }catch{
            print("插入消防員時間戳失敗:\(error)")
        }
    }
    
    
    // 用 RFIDUUID 來找從資料庫撈安管頁面需要的部分消防員資料
    func getFiremanforBravoSquad(by uuid:String) -> FiremanForBravoSquad?{
        do{
            let fireman = Table("table_FIREMAN")
            // 先更新時間戳 再把資料傳給model
            updateFiremanForBravoSquadaTime(by: uuid)
            
            // 幾乎都是sqlite.swift提供的語法，目的是用UUID找出對應的消防員
            for fm in try db.prepare(fireman.where(table_FIREMAN_RFIDUUID == uuid)){
                photoManager = PhotoManager()
                let imageFromlocalPath = photoManager?.loadImageFromDocumentDirectory(filename: fm[table_FIREMAN_RFIDUUID]) ?? UIImage(named: "ImageInApp")!
                //            print("取出的BravoSquad人員:\(fm[table_FIREMAN_NAME]),\nRFID:\(fm[table_FIREMAN_RFIDUUID]),\n時間戳:\(fm[table_FIREMAN_TIMESTAMP]),\n照片路徑:\(fm[table_FIREMAN_PHOTO_PATH]),")
                
                return FiremanForBravoSquad(name: fm[table_FIREMAN_NAME], uuid: fm[table_FIREMAN_RFIDUUID], timestamp: fm[table_FIREMAN_TIMESTAMP], timestampout: fm[table_FIREMAN_TIMESTAMPOUT], image: imageFromlocalPath)
            }
        }catch{
            print("取出FiremanforBravoSquad錯誤\(error)")
        }
        return nil
    }
    
}
