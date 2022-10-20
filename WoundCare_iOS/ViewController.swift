//
//  ViewController.swift
//  WoundCare_iOS
//
//  Created by 蔡立人 on 2022/6/29.
//

import UIKit
import Photos

var globalVariable_account: String?
var globalVariable_bodypart: String?

class ViewController: UIViewController {

    @IBOutlet weak var accountTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordCheckbox: UIButton!
    
    var iconClick = false
    let imageicon = UIImageView()
    
    let userDefault = UserDefaults();
    
    var result = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if authorize(){
            print("開始使用相機相簿")
        }
        
        if (userDefault.value(forKey: "remember") != nil) {
            if ((userDefault.value(forKey: "remember") as! String) == "false"){
                passwordCheckbox.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            }
            else {
                passwordCheckbox.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
                accountTxt.text = userDefault.value(forKey: "account") as! String
                passwordTxt.text = userDefault.value(forKey: "password") as! String
            }
        }
        else {
            userDefault.setValue("false", forKey: "remember")
            userDefault.setValue("", forKey: "account")
            userDefault.setValue("", forKey: "password")
        }

            
        
        accountTxt.setupLeftSideImage(ImageViewNamed: "user")
        passwordTxt.setupLeftSideImage(ImageViewNamed: "key")
        
        imageicon.image = UIImage(named: "eye_off")
        
        let contentView = UIView()
        contentView.addSubview(imageicon)
        
        contentView.frame = CGRect(x: 0, y: 0, width: UIImage(named: "eye_off")!.size.width,
                                   height: UIImage(named: "eye_off")!.size.height)

        imageicon.frame = CGRect(x: -10, y: 0, width: UIImage(named: "eye_off")!.size.width,
                                   height: UIImage(named: "eye_off")!.size.height)

        passwordTxt.rightView = contentView
        passwordTxt.rightViewMode = .always
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped(tapGestureRecognizer:)))
        imageicon.isUserInteractionEnabled = true
        imageicon.addGestureRecognizer(tapGestureRecognizer)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let bottomSpace = self.view.frame.height - (loginButton.frame.origin.y + loginButton.frame.height)
            self.view.frame.origin.y = keyboardHeight - bottomSpace + 10
        }
    }
    
    @objc private func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    @objc func imageTapped(tapGestureRecognizer:UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        if iconClick
        {
            iconClick = false
            tappedImage.image = UIImage(named: "eye_on")
            passwordTxt.isSecureTextEntry = false
        }
        else
        {
            iconClick = true
            tappedImage.image = UIImage(named: "eye_off")
            passwordTxt.isSecureTextEntry = true
            
        }
    }

    
    @IBAction func login(_ sender: UIButton) {
        
        if accountTxt.text!.count == 0 || passwordTxt.text!.count == 0
        {
            let controller = UIAlertController(title: "提醒通知", message: "帳號或密碼未填寫完畢，無法登入", preferredStyle: .alert)
               let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
               controller.addAction(okAction)
            self.present(controller, animated: true, completion: nil)
        }

        let session = URLSession(configuration: .default)
        let url = "http://52.10.24.93:8080/woundcare/connect/v3/api/userLogin?location=YLT"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postData = ["uid":accountTxt.text ?? "","pwd":passwordTxt.text ?? ""]
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        let task = session.dataTask(with: request) {(data, response, error) in
            do {
                let r = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                if (!JSONSerialization.isValidJSONObject(r))
                {
                    print("无法解析出JSONString")
                }
                let data : NSData! = try? JSONSerialization.data(withJSONObject: r, options: []) as NSData
                self.result = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue) as! String
            } catch {
                print(error)
                return
            }
        }
        task.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { // Change `2.0` to the desired number of seconds.
            if (self.result.contains("true"))
            {
                if ((self.userDefault.value(forKey: "remember") as! String) == "true"){
                    self.userDefault.setValue(self.accountTxt.text, forKey: "account")
                    self.userDefault.setValue(self.passwordTxt.text, forKey: "password")
                }
                let myS = UIStoryboard(name: "Main", bundle: nil)
                let vc = myS.instantiateViewController(identifier: "OptionVC") as! OptionViewController
                vc.modalPresentationStyle = .fullScreen
                globalVariable_account = self.accountTxt.text
                self.present(vc, animated: true, completion: nil)
            }
            else {
                let controller = UIAlertController(title: "提醒通知", message: "帳號或密碼輸入錯誤，無法登入", preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                   controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        if ((userDefault.value(forKey: "remember") as! String) == "false"){
            passwordCheckbox.setImage(#imageLiteral(resourceName: "tick"), for: .normal)
            userDefault.setValue("true", forKey: "remember")
            userDefault.setValue(accountTxt.text, forKey: "account")
            userDefault.setValue(passwordTxt.text, forKey: "password")
            
        }
        else {
            passwordCheckbox.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            userDefault.setValue("false", forKey: "remember")
            userDefault.setValue("", forKey: "account")
            userDefault.setValue("", forKey: "password")
        }
    }
    
    func authorize() -> Bool {
        let photoLibraryStatus = PHPhotoLibrary.authorizationStatus() //相簿請求
        let camStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) //相機請求
        switch (camStatus, photoLibraryStatus){ //判斷狀態
        case (.authorized,.authorized): //兩個都允許
            return true
        case (.notDetermined,.notDetermined): //兩個都還未決定,就請求授權
            AVCaptureDevice.requestAccess(for: AVMediaType.video,  completionHandler: { (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
        case (.authorized,.notDetermined): //相機允許，相簿未決定，相簿請求授權
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async(execute: {
                    _ = self.authorize()
                })
            })
        case (.authorized,.denied): //相機允許，相簿拒絕，做出提醒
            DispatchQueue.main.async(execute: {
                let alertController = UIAlertController(title: "提醒", message: "您目前拍攝的照片並不會儲存至相簿，要前往設定嗎?", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: {(status) in})
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                self.present(alertController, animated: true, completion: nil)
            })
        default: //預設，如都不是以上狀態
            DispatchQueue.main.async(execute: {
                let alertController = UIAlertController(title: "提醒", message: "請點擊允許才可於APP內開啟相機及儲存至相簿", preferredStyle: .alert)
                let canceAlertion = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let settingAction = UIAlertAction(title: "設定", style: .default, handler: { (action) in
                    let url = URL(string: UIApplication.openSettingsURLString)
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                print("跳至設定")
                            })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                })
                alertController.addAction(canceAlertion)
                alertController.addAction(settingAction)
                self.present(alertController, animated: true, completion: nil)
            })
        }
        return false
    }


}


extension UITextField {
    func setupLeftSideImage(ImageViewNamed:String){
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20));
        imageView.image = UIImage(named: ImageViewNamed)
        let imageViewContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageViewContainerView.addSubview(imageView)
        leftView = imageViewContainerView
        leftViewMode = .always
        self.tintColor = .lightGray
    }
}


