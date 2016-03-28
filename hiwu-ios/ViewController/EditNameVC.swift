//
//  EditNameVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/1/31.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EditNameVC: UIViewController {
    var name = ""
    var userId = 0
    @IBOutlet weak var nameInput: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameInput.text = self.name
    }
    @IBAction func ok(sender: UIButton) {
        self.putNickname()
    }
    @IBAction func cancel(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let gest = UITapGestureRecognizer(target: self, action: #selector(EditNameVC.endEditing))
        self.view.addGestureRecognizer(gest)
    }
    

    
    func endEditing(){
        self.nameInput.endEditing(true)
    }
    
    func putNickname(){
        let url = ApiManager.putNickname1 + String(self.userId) + ApiManager.putNickname2 + globalHiwuUser.hiwuToken
        
        Alamofire.request(.PUT, url, parameters: ["nickname":self.nameInput.text!,"id":self.userId]).responseJSON{response in
            let result = JSON(response.result.value!)
            if(result["error"].string == ""){
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }
    

}
