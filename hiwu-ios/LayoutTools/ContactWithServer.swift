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
                        let defaluts =  NSUserDefaults.standardUserDefaults()
                        defaluts.setValue((userInfo["id"]).string!, forKey: "token")
                        defaluts.setValue(username, forKey: "userName")
                        defaluts.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!).timeIntervalSince1970, forKey: "deadline")
                        defaluts.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!/2).timeIntervalSince1970, forKey: "freshline")
                        defaluts.setInteger((userInfo["userId"]).int!, forKey: "userId")
                        defaluts.synchronize()
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
    
    func getSelfMuseum(){
        let url = ApiManager.getSelfGallery1_2 + String(globalHiwuUser.userId) + ApiManager.getSelfGallery2_2
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{
        response in
            if(response.result.value != nil){
                globalHiwuUser.selfMuseum = JSON(response.result.value!)
                self.loginSuccess?.didGetSelfMuseum()
            }else{
                self.loginSuccess?.getSelfMuseumFailed()
            }
        }
    }
    

}
