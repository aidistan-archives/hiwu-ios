//
//  FeedbackVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/2/4.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedbackVC: UIViewController {
    
    @IBAction func cancel(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func ok(sender: UIButton) {
        self.feedbackInput.endEditing(true)
        self.postFeedback()
    }
    @IBOutlet weak var feedbackInput: BRPlaceholderTextView!
    var userId = 0
    var userNickname = "物境未觉"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedbackInput.text! = ""
        self.feedbackInput.placeholder = "在这里输入您的意见"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    func postFeedback(){
        let url = ApiManager.postFeedback
        
        Alamofire.request(.POST, url, parameters: ["description":self.feedbackInput.text!,"title":self.userNickname + "(" + String(self.userId) + ")" + "从iOS客户端发来反馈" ]).responseJSON{response in
            let result = JSON(response.result.value!)
//            print(result)
            if(result["errorInfo"] == nil){
                let alert = SCLAlertView()
                alert.addButton("好的", actionBlock: {() in
                    self.navigationController?.popViewControllerAnimated(true)})
                alert.showInfo(self, title: "感谢您的反馈", subTitle: "您的帮助将是我们前进的动力！", closeButtonTitle: nil, duration: 0)
            }else{
//                print("no")
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }
    

}
