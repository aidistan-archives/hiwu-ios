//
//  ContactWithServer.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//
//  先进行登录，如果成功便进行个人博物馆信息的申请，成功后进行跳转

import UIKit
import Alamofire
import SwiftyJSON

class ContactWithServer{
    var loginSuccess:LoginProtocol?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    static func getNewTokenWithDefaults(){
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: nil, userInfo: nil, repeats: false)
        print("hello")
    }
    
    func getTokenWithPassword(username:String,password:String){
        print(username)
        Alamofire.request(.POST, ApiManager.simpleLogin + "username=" + username).responseJSON{response in
            print(response.result.error)
            if(response.result.isSuccess)
            {
                if(response.result.error == nil){
                    let userInfo = JSON(response.result.value!)
                    if(userInfo != nil){
                        globalHiwuUser.hiwuToken = (userInfo["id"]).string!
                        globalHiwuUser.userId = (userInfo["userId"]).int!
                        globalHiwuUser.userName = username
                        self.defaults.setValue((userInfo["id"]).string!, forKey: "token")
                        self.defaults.setValue(username, forKey: "userName")
                        self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!).timeIntervalSince1970, forKey: "deadline")
                        self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!/2).timeIntervalSince1970, forKey: "freshline")
                        self.defaults.setInteger((userInfo["userId"]).int!, forKey: "userId")
                        self.defaults.synchronize()
                        self.getSelfMuseum()
                    }
                }else{
                    print("error")
                    print(response.result.error)
                
                }
            }else{
                print("network error")
            }
            }
        }
    
    func getUserInfoFirst(){
        globalHiwuUser.userId = self.defaults.integerForKey("userId")
        globalHiwuUser.hiwuToken = self.defaults.valueForKey("token") as! String
        globalHiwuUser.userName = self.defaults.valueForKey("userName")as! String
            print("getUserInfoFirst")
        self.getSelfMuseum()
    }
    
    func getSelfMuseum(){
        let url = ApiManager.getAllSelfGallery1_2 + String(globalHiwuUser.userId) + ApiManager.getAllSelfGallery2_2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{
        response in
            print(response.result.value)
            print(response.request)
            if(response.result.value != nil){
                globalHiwuUser.selfMuseum = JSON(response.result.value!)
                let tmpData:NSData = NSKeyedArchiver.archivedDataWithRootObject(response.result.value!)
                self.defaults.setObject(tmpData, forKey: "selfMuseum")
                self.defaults.synchronize()
                self.loginSuccess?.didGetSelfMuseum()
                
            }else{
                if(self.defaults.valueForKey("selfMuseum") != nil){
                    globalHiwuUser.selfMuseum = JSON(NSKeyedUnarchiver.unarchiveObjectWithData(self.defaults.objectForKey("selfMuseum") as! NSData)!)
                     self.loginSuccess?.didGetSelfMuseum()
                    
                }else{
                    self.loginSuccess?.getSelfMuseumFailed()
                }
            }
        }
    }
       
}
