//
//  ContactWithServer.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ContactWithServer{
    static func getNewTokenWithDefaults(){
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: nil, userInfo: nil, repeats: false)
        print("hello")
    }
    
    static func getTokenWithPassword(username:String,password:String){
        print(username)
        Alamofire.request(.POST, ApiManager.simpleLogin + "username=" + username).responseJSON{response in
            print(response.result.error)
            if(response.result.isSuccess)
            {
                if(response.result.error != nil){
                    let userInfo = JSON(response.result.value!)
                    if(userInfo != nil){
                        globalHiwuUser.hiwuToken = (userInfo["id"]).string!
                        globalHiwuUser.userId = (userInfo["userId"]).int!
                        let defaluts =  NSUserDefaults.standardUserDefaults()
                        defaluts.setValue((userInfo["id"]).string!, forKey: "token")
                        defaluts.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!).timeIntervalSince1970, forKey: "deadline")
                        defaluts.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!/2).timeIntervalSince1970, forKey: "freshline")
                        defaluts.setInteger((userInfo["userId"]).int!, forKey: "userId")
                        defaluts.synchronize()
                        print("defaultsInfo")
                        debugPrint(defaluts.valueForKey("token"))
                    }
                }else{
                    print(response.result.error)
                
                }
            }else{
                print("network error")
            }
            }
        }

}
