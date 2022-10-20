//
//  SelectBodyPartViewController.swift
//  WoundCare_iOS
//
//  Created by 蔡立人 on 2022/7/4.
//

import UIKit

class SelectBodyPartViewController: UIViewController {
    @IBOutlet weak var Labelright: UILabel!
    @IBOutlet weak var Labelleft: UILabel!
    
    @IBOutlet weak var bodyfontView: UIView!
    @IBOutlet weak var bodybackView: UIView!
    @IBOutlet weak var bodyleftView: UIView!
    @IBOutlet weak var bodyrightView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyfontView.alpha = 1
        bodybackView.alpha = 0
        bodyleftView.alpha = 0
        bodyrightView.alpha = 0
        
        
        Labelright.layer.cornerRadius = Labelright.frame.width / 2
        Labelright.layer.masksToBounds = true
        
        Labelleft.layer.cornerRadius = Labelleft.frame.width / 2
        Labelleft.layer.masksToBounds = true
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

    }
    
    @IBAction func switchViews( sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            bodyfontView.alpha = 1
            bodybackView.alpha = 0
            bodyleftView.alpha = 0
            bodyrightView.alpha = 0
        }
        else if (sender.selectedSegmentIndex == 1){
            bodyfontView.alpha = 0
            bodybackView.alpha = 1
            bodyleftView.alpha = 0
            bodyrightView.alpha = 0
        }
        else if (sender.selectedSegmentIndex == 2){
            bodyfontView.alpha = 0
            bodybackView.alpha = 0
            bodyleftView.alpha = 1
            bodyrightView.alpha = 0
        }
        else if (sender.selectedSegmentIndex == 3){
            bodyfontView.alpha = 0
            bodybackView.alpha = 0
            bodyleftView.alpha = 0
            bodyrightView.alpha = 1
        }
        
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
