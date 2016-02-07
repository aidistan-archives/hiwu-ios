//
//  LoginVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LoginVC: UIViewController,LoginProtocol {
    
    var superVC:UIViewController?
    let tmpContactor = ContactWithServer()
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBAction func cancel(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBAction func loginButton(sender: UIButton) {
        
        self.tmpContactor.loginSuccess = self
        self.tmpContactor.getTokenWithPassword(usernameText.text!, password: passwordText.text!)
       
    }
    @IBOutlet weak var wxLoginButton: UIButton!
    @IBAction func weixin(sender: UIButton) {
        //微信的的登录状态码设为1，微博为2，默认为0
        globalHiwuUser.loginState = 1
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo";
        req.state = "123"
        WXApi.sendReq(req);

    }
    
    @IBAction func weiboLoginButton(sender: UIButton) {
        globalHiwuUser.loginState = 2
        let req = WBAuthorizeRequest()
        req.scope = "all"
        req.redirectURI = kRedirectURI
        print(WeiboSDK.sendRequest(req))
    }
    
    
    func skipToNextAfterSuccess() {
        //self.navigationController?.popViewControllerAnimated(false)
        self.navigationController?.popViewControllerAnimated(false)
        let selfMuseum = self.storyboard?.instantiateViewControllerWithIdentifier("SelfMuseum") as! SelfMuseumVC
        self.superVC?.navigationController?.pushViewController(selfMuseum, animated: true)
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
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            self.wxLoginButton.hidden = false
        }
        registerButton.layer.cornerRadius = registerButton.frame.height/2
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weixinSuccess", name: "weixinLoginOK", object: nil)
        
    }
    
    func weixinSuccess(){
        globalHiwuUser.loginState = 0
        if(globalHiwuUser.wxcode != ""){
            let url = ApiManager.wxLogin1 + wxAPPID + ApiManager.wxLogin2 + globalHiwuUser.wxcode
            Alamofire.request(.POST, url).responseJSON{response in
                if(response.result.error == nil){
                    if(response.result.value != nil){
                        let userInfo = JSON(response.result.value!)
                        if(userInfo["error"] == nil){
                            globalHiwuUser.hiwuToken = userInfo["id"].string!
                            self.defaults.setValue((userInfo["id"]).string!,
                                forKey: "token")
                            self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!).timeIntervalSince1970, forKey: "deadline")
                            self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!/2).timeIntervalSince1970, forKey: "freshline")
                            self.defaults.setInteger((userInfo["userId"]).int!, forKey: "userId")
                            
                            print(globalHiwuUser.userId)
                            self.defaults.synchronize()

                            self.getSelfMuseum()
                        }
                    }
                }
            }
        }
    }
    
    func weiboSuccess(){
        globalHiwuUser.loginState = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func getSelfMuseum(){
        let url = ApiManager.getAllSelfGallery1_2 + String(globalHiwuUser.userId) + ApiManager.getAllSelfGallery2_2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, url).responseJSON{response in
            if(response.result.value != nil){
                globalHiwuUser.selfMuseum = JSON(response.result.value!)
                let tmpData:NSData = NSKeyedArchiver.archivedDataWithRootObject(response.result.value!)
                self.defaults.setObject(tmpData, forKey: "selfMuseum")
                self.defaults.synchronize()
                self.skipToNextAfterSuccess()
            }else{
                if(self.defaults.valueForKey("selfMuseum") != nil){
                    globalHiwuUser.selfMuseum = JSON(NSKeyedUnarchiver.unarchiveObjectWithData(self.defaults.objectForKey("selfMuseum") as! NSData)!)
                    print("selfMuseumReady local")
                    self.skipToNextAfterSuccess()
                }else{
                }
            }
        }
    }

    

}
