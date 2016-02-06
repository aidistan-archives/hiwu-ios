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
    
    var userId = 0

    @IBOutlet weak var feedbackInput: BRPlaceholderTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedbackInput.text! = ""
        self.feedbackInput.placeholder = "在这里输入您的意见"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func putFeedback(){
        let url = ApiManager.putNickname1 + String(self.userId) + ApiManager.putNickname2 + globalHiwuUser.hiwuToken
        
        Alamofire.request(.PUT, url, parameters: ["description":self.feedbackInput.text!,"id":self.userId]).responseJSON{response in
            let result = JSON(response.result.value!)
            if(result["error"].string == ""){
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    

}
