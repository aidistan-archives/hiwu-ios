//
//  LoginVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginVC: UIViewController,LoginProtocol {
    
    let superVC = UIViewController()
    let tmpContactor = ContactWithServer()
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func loginButton(sender: UIButton) {
        
        self.tmpContactor.loginSuccess = self
        self.tmpContactor.getTokenWithPassword(usernameText.text!, password: passwordText.text!)
       
    }
    
    
    func skipToNextAfterSuccess() {
        //self.navigationController?.popViewControllerAnimated(false)
        self.dismissViewControllerAnimated(false, completion: nil)
//        self.navigationController?.performSegueWithIdentifier("ToSelfMuseumSegue", sender: self)
        print("hello")
        print(self.navigationController?.viewControllers)
    }
    
    func loginFailed() {
        print("loginFailed")
    }
    
    func didGetSelfMuseum(){
        self.skipToNextAfterSuccess()
    }
    
    func getSelfMuseumFailed(){
        print("getSelfMuseumFailed")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("stack")
        print(self.navigationController?.viewControllers)
        registerButton.layer.cornerRadius = registerButton.frame.height/2
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
