//
//  EditDescriptionVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/2/4.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EditDescriptionVC: UIViewController {
    
    var userId = 0
    var userDescription = ""

    @IBOutlet weak var descriptionInput: UITextField!
    @IBAction func cancel(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func ok(sender: UIButton) {
        self.putDescription()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionInput.text = self.userDescription

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func putDescription(){
        let url = ApiManager.putNickname1 + String(self.userId) + ApiManager.putNickname2 + globalHiwuUser.hiwuToken
        Alamofire.request(.PUT, url, parameters: ["description":self.descriptionInput.text!,"id":self.userId]).responseJSON{response in
            let result = JSON(response.result.value!)
            if(result["error"].string == nil){
                self.navigationController?.popViewControllerAnimated(true)
            }
            
        }
    }


}
