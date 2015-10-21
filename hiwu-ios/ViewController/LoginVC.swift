//
//  LoginVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func loginButton(sender: UIButton) {
        ContactWithServer.getTokenWithPassword(usernameText.text!, password: passwordText.text!)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = registerButton.frame.height/2
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
