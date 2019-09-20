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
    
    // 遍歷
    func allFireman(){

        for item in (try! db.prepare(table_FIREMAN)){
            print("消防員in table_FIREMAN\n id:\(item[table_FIREMAN_ID])\n,SN:\(item[table_FIREMAN_SN])\n,NAME:\(item[table_FIREMAN_NAME])\n,PhotoPaht:\(item[table_FIREMAN_PHOTO_PATH])\n,CALL SIGN:\(item[table_FIREMAN_CALLSIGN])\n,RFID:\(item[table_FIREMAN_RFIDUUID])\n,DEPARTMENT:\(item[table_FIREMAN_DEPARTMENT]),時間戳進入:\(item[table_FIREMAN_TIMESTAMP]),時間戳出:\(item[table_FIREMAN_TIMESTAMPOUT])")
        }
    }
    
    
    enum logType {
        case enter
        case exit
    }
    
    func firemanForLog(logType: logType)->Array<FiremanForBravoSquad>{
//        var firemanArrayForLog:Array<FiremanForBravoSquad> = []
        
        
        var arrayEnter:Array<FiremanForBravoSquad> = []
        var arrayExit:Array<FiremanForBravoSquad> = []
        
        // fm = fireman row
        for fm in (try! db.prepare(table_FIREMAN)){
            
            photoManager = PhotoManager()
            // 讀取一個fm的照片 讀取失敗就用預設圖
            let imageFromlocalPath = photoManager?.loadImageFromDocumentDirectory(filename: fm[table_FIREMAN_RFIDUUID]) ?? UIImage(named: "ImageInApp")!
            
            // 把人拼成一個 FiremanForBravoSquad 只是這次一個人要有很多個
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
        switch logType{
            case .enter:
                return arrayEnter
            case .exit:
                return arrayExit
        }
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
    // 用uuid抓出特定的消防員時間戳欄位
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

// 提供給安管系統的簡易版名單
public struct FiremanForBravoSquad {
    let name:String
    let uuid:String
    let timestamp:String
    let timestampout:String
    let image:UIImage
}

// 取出最新一筆進入火場時間
public func getLatestedTimeStamp(fireman:FiremanForBravoSquad) -> String{
    
    // 從資料庫取出並轉成陣列
    let dateStringArray = fireman.timestamp.split(separator: ",")
    print("getLatestedTimeStamp!!!!\(dateStringArray)")
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
public func getLatestedTimeStampOut(fireman:FiremanForBravoSquad) -> String{
    
    // 從資料庫取出並轉成陣列
    let dateStringArray = fireman.timestampout.split(separator: ",")
    print("getLatestedTimeStampOut!!!!\(dateStringArray)")
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
