//
//  FireCommandDB.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/8/30.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import Foundation
import SQLite

class FirecommandDatabase:PhotoPathJustSaved {
    
    var firemanPhotoPath:URL?
    var photoManager:PhotoManager?

    var  db: Connection!
    init() {
        connectDatabase()
    }
    
    // delegate 來的 func
    // TODO: 暫時沒用，待修
    func getPhotoPath(photoPath: URL) {
        firemanPhotoPath = photoPath
    }
    
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
                table.column(table_FIREMAN_TIMESTAMP, defaultValue: "CreateDefaultValue")
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
                       firemanDepartment:String){
        // 讓PhotoManager介入把照片存入檔案
        photoManager = PhotoManager()
        // 要生成資料庫的時候才把照片存入本地
        let path = photoManager!.saveImageToDocumentDirectory(image: firemanPhoto, filename: firemanRFID)
        
        // 有空再處理TODO:-- 這行對應上面的暫時沒用,有空再處理（存好之後把 URL 傳入此處變數）
        photoManager?.delegate=self
        
        
        // table_FIREMAN_PHOTO_PATH 要把 URL 轉成純文字
        let insert = table_FIREMAN.insert(
            table_FIREMAN_SN <- serialNumber,
            table_FIREMAN_NAME <- firemanName,
            table_FIREMAN_PHOTO_PATH <- path!.absoluteString,
            table_FIREMAN_CALLSIGN <- firemanCallsign,
            table_FIREMAN_RFIDUUID <- firemanRFID,
            table_FIREMAN_TIMESTAMP <- firemanTimeStamp,
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
            print("全部的消防員in table_FIREMAN\n id:\(item[table_FIREMAN_ID])\n,SN:\(item[table_FIREMAN_SN])\n,NAME:\(item[table_FIREMAN_NAME])\n,PhotoPaht:\(item[table_FIREMAN_PHOTO_PATH])\n,CALL SIGN:\(item[table_FIREMAN_CALLSIGN])\n,RFID:\(item[table_FIREMAN_RFIDUUID])\n,DEPARTMENT:\(item[table_FIREMAN_DEPARTMENT]),時間戳:\(item[table_FIREMAN_TIMESTAMP])")
        }
    }
    // 讀取
    
    // 更新
    
    
    

    // 用 RFIDUUID 來找從資料庫撈取消防員
    func getFiremanforBravoSquad(by uuid:String) -> FiremanForBravoSquad?{
        do{
            let fireman = Table("table_FIREMAN")
            // 幾乎都是sqlite.swift提供的語法，目的是用UUID找出對應的消防員
            for fm in try db.prepare(fireman.where(table_FIREMAN_RFIDUUID == uuid)){
                print("取出的人員\(fm[table_FIREMAN_NAME])\n,RFID:\(fm[table_FIREMAN_RFIDUUID])\n,時間戳:\(fm[table_FIREMAN_TIMESTAMP])")
                return FiremanForBravoSquad(name: fm[table_FIREMAN_NAME], uuid: fm[table_FIREMAN_RFIDUUID], timestamp: fm[table_FIREMAN_TIMESTAMP])
            }
        }catch{
            print("取出FiremanforBravoSquad錯誤\(error)")
        }
        return nil
    }
    
}

// 提供給安管系統的簡易版名單
struct FiremanForBravoSquad {
    let name:String
    let uuid:String
    let timestamp:String
}
