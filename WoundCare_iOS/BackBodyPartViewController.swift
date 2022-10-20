//
//  BackBodyPartViewController.swift
//  WoundCare_iOS
//
//  Created by 蔡立人 on 2022/7/7.
//

import UIKit

class BackBodyPartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func selectpart_back(_ sender: UIButton){
        let myS = UIStoryboard(name: "Main", bundle: nil)
        let vc = myS.instantiateViewController(identifier: "ExamVC") as! ExamViewController
        vc.modalPresentationStyle = .fullScreen
        globalVariable_bodypart = sender.currentTitle
        present(vc, animated: true, completion: nil)
    }

}
