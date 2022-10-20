//
//  OptionViewController.swift
//  WoundCare_iOS
//
//  Created by 蔡立人 on 2022/6/30.
//

import UIKit
import Photos

class OptionViewController: UIViewController {
    
    var bl_album_exit = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(globalVariable_account)
        
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
                
                print("\(assetCollection.localizedTitle)相册，共有照片数:\(assetsFetchResults.count)")
                
                if(assetCollection.localizedTitle == globalVariable_account)
                {
                    bl_album_exit = true
                }
            }
        }
        
        if(!bl_album_exit)
        {
            var assetAlbum: PHAssetCollection?
            
            let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                        
            list.enumerateObjects({ (album, index, stop) in
                let assetCollection = album
                if globalVariable_account ?? "account" == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    stop.initialize(to: true)
                }
            })
            
            //不存在的话则创建该相册
            if assetAlbum == nil {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest
                        .creationRequestForAssetCollection(withTitle: globalVariable_account ?? "account")
                })
            }
        }
        
    }
    
    @IBAction func logout(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
