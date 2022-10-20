//
//  PreviewViewController.swift
//  WoundCare_iOS
//
//  Created by 蔡立人 on 2022/7/15.
//

import SQLite3
import UIKit
import Photos

class PreviewViewController: UIViewController {

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
            // select
            let statement = mydb.fetch("\""+(globalVariable_account ?? "account")+"\"", cond: "1 == 1", order: nil)
            while sqlite3_step(statement) == SQLITE_ROW{
                let id = sqlite3_column_int(statement, 0)
                let account = String(cString: sqlite3_column_text(statement, 1))
                let bodypart = String(cString: sqlite3_column_text(statement, 2))
                let imagepath = String(cString: sqlite3_column_text(statement, 3))
                let imagepath_gai = String(cString: sqlite3_column_text(statement, 4))
                let width = String(cString: sqlite3_column_text(statement, 5))
                let height = String(cString: sqlite3_column_text(statement, 6))
                let area = String(cString: sqlite3_column_text(statement, 7))
                print("\(id). \(account)  \(bodypart) \(imagepath) \(imagepath_gai) \(width) \(height) \(area)")
            }
            sqlite3_finalize(statement)

        
        }
        
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    @objc func swipeFunc(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            self.dismiss(animated: true, completion: nil)
        }
        else if gesture.direction == .left {
            print("swiped right")
        }
    }
    
    
    
}
