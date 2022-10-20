//
//  ExamViewController.swift
//  WoundCare_iOS
//
//  Created by 蔡立人 on 2022/7/6.
//

import UIKit
import Photos
import SQLite3

class ExamViewController: UIViewController {

    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet fileprivate var photoModeButton: UIButton!
    @IBOutlet fileprivate var videoModeButton: UIButton!
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet weak var gobackButton: UIButton!
    @IBOutlet weak var bodypartButton: UIButton!
    
    @IBOutlet fileprivate var flashButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var flashStackView: UIStackView!
    @IBOutlet weak var previewButton: UIButton!
    
    var localId:String!
    
    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }
    
    var db :SQLiteConnect? = nil

    let sqliteURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
        } catch {
            fatalError("Error getting file URL from document directory.")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 資料庫檔案的路徑
        let sqlitePath = sqliteURL.path
        
        // 印出儲存檔案的位置
        print(sqlitePath)
        
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        
        if let mydb = db {
            // create table
            let _ = mydb.createTable("\""+(globalVariable_account ?? "account")+"\"", columnsInfo: [
                "id integer primary key autoincrement",
                "account text",
                "bodypart text",
                "imagepath text",
                "imagepath_gai text",
                "width text",
                "height text",
                "area text"])
            
            if(mydb.lastrow("\""+(globalVariable_account ?? "account")+"\"", order: nil) != "0")
            {
                var imagepath = ""
                let statement = mydb.fetch("\""+(globalVariable_account ?? "account")+"\"", cond: "id == "+mydb.lastrow("\""+(globalVariable_account ?? "account")+"\"", order: nil), order: nil)
                while sqlite3_step(statement) == SQLITE_ROW{
                    let id = sqlite3_column_int(statement, 0)
                    let account = String(cString: sqlite3_column_text(statement, 1))
                    let bodypart = String(cString: sqlite3_column_text(statement, 2))
                    imagepath = String(cString: sqlite3_column_text(statement, 3))
                    let imagepath_gai = String(cString: sqlite3_column_text(statement, 4))
                    let width = String(cString: sqlite3_column_text(statement, 5))
                    let height = String(cString: sqlite3_column_text(statement, 6))
                    let area = String(cString: sqlite3_column_text(statement, 7))
                    print("\(id). \(account)  \(bodypart) \(imagepath) \(imagepath_gai) \(width) \(height) \(area)")
                }
                sqlite3_finalize(statement)
                
                print("count---->",mydb.lastrow("\""+(globalVariable_account ?? "account")+"\"", order: nil))
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                    let filePath = imagepath
                    let getImg = UIImage(contentsOfFile: filePath)
                    if (getImg != nil) {
                        let smallImage = self.resizeImage(image: getImg!, width: 54)
                        self.previewButton.setImage(smallImage, for: .normal)
                     }
                }
            }
        }
        
        if globalVariable_bodypart != nil {
            print(globalVariable_bodypart)
            bodypartButton.setTitle(globalVariable_bodypart, for: .normal)
            accountLabel.text = globalVariable_account
        }
        
        self.styleCaptureButton()
        self.configureCameraController()
        
    }

    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: .normal)
            flashStackView.backgroundColor = UIColor.placeholderText
            
        }
            
        else {
            cameraController.flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "no-flash"), for: .normal)
            flashStackView.backgroundColor = UIColor(named: "transparent_yellow")
        }
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            let momentAlbum:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .moment, subtype: .albumRegular, options: nil)

            let topLevelUserCollections:PHFetchResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            //topLevelUserCollections中保存的是各個用戶創建的相冊對應的PHAssetCollection
            
            for i in 0..<topLevelUserCollections.count {
                //獲取一個相冊
                let collection = topLevelUserCollections[i]
                if collection.isKind(of: PHAssetCollection.classForCoder()) {
                    //赋值
                    let assetCollection = collection
                    
                    //從每一個智能相冊中獲取到的PHFetchResult中包含的才是真正的資源(PHAsset)
                    let assetsFetchResults:PHFetchResult = PHAsset.fetchAssets(in: assetCollection as! PHAssetCollection, options: nil)
                    
                    //print("\(assetCollection.localizedTitle)相册，共有照片数:\(assetsFetchResults.count)")
                    //遍歷自定義相冊，存儲相片
                    if assetCollection.localizedTitle == globalVariable_account ?? "account" {
                        self.savePhoto(image: image, album: assetCollection as! PHAssetCollection)
                    }

                    assetsFetchResults.enumerateObjects({ (asset, i, nil) in
                        print("\(asset)")
                    })
                }
            }
        }
    }
    
    @IBAction func finish(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    func styleCaptureButton() {
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 2
        
        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
    }
    
    func savePhoto(image: UIImage, album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            // Request editing the album.
            guard let addAssetRequest = PHAssetCollectionChangeRequest(for: album) else { return }
            let assetPlaceholder = creationRequest.placeholderForCreatedAsset
            self.localId = assetPlaceholder?.localIdentifier
            // Get a placeholder for the new asset and add it to the album editing request.
            addAssetRequest.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
        }, completionHandler: { success, error in
            if !success
            {
                print("error creating asset: \(error)")
            }
            else {
                print("Add to custom album successfully")
                let assetResult = PHAsset.fetchAssets(
                    withLocalIdentifiers: [self.localId], options: nil)
                let asset = assetResult[0]
                let options = PHContentEditingInputRequestOptions()
                options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
                    -> Bool in
                    return true
                }
                //获取保存的图片路径
                asset.requestContentEditingInput(with: options, completionHandler: {
                    (contentEditingInput:PHContentEditingInput?, info: [AnyHashable : Any]) in
                    print("地址：","\"",contentEditingInput!.fullSizeImageURL!.path,"\"")
                    
                    let smallImage = self.resizeImage(image: image, width: 54)
                    
                    self.previewButton.setImage(smallImage, for: .normal)
                    
                    if let mydb = self.db {
                        
                        // insert
                        let _ = mydb.insert("\""+(globalVariable_account ?? "account")+"\"",
                                            rowInfo: ["account":"\""+(globalVariable_account ?? "account")+"\"",
                                                      "bodypart":"\""+(globalVariable_bodypart ?? "bodypart")+"\"",
                                                      "imagepath":"\""+contentEditingInput!.fullSizeImageURL!.path+"\"",
                                                      "imagepath_gai":"'--'",
                                                      "width":"'--'",
                                                      "height":"'--'",
                                                      "area":"'--'"])
                    }
                })
            }
        })
    }
    
    func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
            let size = CGSize(width: width, height:
                image.size.height * width / image.size.width)
            let renderer = UIGraphicsImageRenderer(size: size)
            let newImage = renderer.image { (context) in
                image.draw(in: renderer.format.bounds)
            }
            return newImage
    }

    
}
