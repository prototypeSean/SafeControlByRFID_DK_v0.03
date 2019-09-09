//
//  AddNewFiremanViewController.swift
//  SafeControlByRFID_DK_v0.01
//
//  Created by DennisKao on 2019/9/2.
//  Copyright © 2019 DennisKao. All rights reserved.
//

import UIKit


// 一直忘記資料庫格式先貼來這裡方便看而已
//Table("table_fireman")
//table_FIREMAN_ID = Expression<Int64>("id")
//table_FIREMAN_SN = Expression<Int64>("serialNumber")
//table_FIREMAN_NAME = Expression<String>("firemanName")
//table_FIREMAN_PHOTO_PATH = Expression<String>("firemanPhotoPath")
//table_FIREMAN_CALLSIGN = Expression<String>("firemanCallsign")
//table_FIREMAN_RFIDUUID = Expression<String>("firemanRFID")
//table_FIREMAN_DEPARTMENT = Expression<String>("firemanDepartment")

// TODO: 寫進資料庫的錯誤處理還沒做
// 這邊是由SafeComtrolelr轉跳而來的 要怎麼不跟他搶model的delegate ?


class AddNewFiremanViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    var fireCommandDB: FirecommandDatabase?
    // 遷就而已 這邊之後應該要改掉 只是不想直接用藍芽model
    private var model: SafeControllModel?
    
    // MARK: IBOutlet區域
    @IBOutlet weak var fireManRFID: UILabel!
    @IBOutlet weak var fireManName: UILabel!
    @IBOutlet weak var firemanAvatar: UIImageView!
    @IBOutlet weak var serialNumber: UITextField!
    @IBOutlet weak var firemanCallSign: UITextField!
    @IBOutlet weak var firemanDepartment: UITextField!
    
    var firemanTimeStamp:String?
    
    @IBAction func saveToDB(_ sender: Any) {
        fireCommandDB!.addNewFireman(
            serialNumber: serialNumber.text!,
            firemanName: fireManName.text!,
            firemanPhoto: self.firemanAvatar.image!,
            firemanCallsign: firemanCallSign.text!,
            firemanRFID: fireManRFID.text!,
            firemanTimeStamp: firemanTimeStamp!,
            firemanDepartment: firemanDepartment.text!)
    }
    @IBAction func printDB(_ sender: Any) {
        fireCommandDB?.allFireman()
    }
    
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    var recievedRFID:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        BluetoothModel.singletion.delegate = self
//        model.delegateForAddFireman = self
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        // 這邊把資料庫實體化（連線）用來把資料存進 DB
        fireCommandDB = FirecommandDatabase()
        
        // 暫時的 之後要做鍵盤跟ＲＦＩＤ
        fireManName.text = "這是姓名"
        serialNumber.text = "序號AA2234"
        firemanCallSign.text = "隊員呼號222"
        firemanDepartment.text = "隊員所屬分隊"
        firemanTimeStamp = "16:05:44"
    }
    
    func setupModel(model:SafeControllModel){
        self.model = model
        model.delegateForAddFireman = self
    }
    
    // 收到 RFID 之後顯示在 label.text
//    func didReciveRFIDDate(uuid: String) {
//        DispatchQueue.main.async {
//            self.fireManRFID.text=uuid
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// 吃下 ImagePickerDelegate 來顯示它拍攝或選擇的照片
extension AddNewFiremanViewController: CustomImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.firemanAvatar.image = image
    }
}

extension AddNewFiremanViewController: PhotoPathJustSaved{
    func getPhotoPath(photoPath: URL) {

    }
}

//extension AddNewFiremanViewController: BluetoothModelDelegate{
//
//}

extension AddNewFiremanViewController:SafeControldelegateforAddNewFireman{
    func newFiremanRFID(uuid: String) {
        DispatchQueue.main.async{
            print("新增消防人員頁面的dataDidUpdate")
            self.fireManRFID.text = uuid
        }
    }
}
