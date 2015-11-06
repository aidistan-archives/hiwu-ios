//
//  ContactWithServer.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//
//  和服务器交互，交互得到的信息进行缓存

import UIKit
import Alamofire
import SwiftyJSON

class ContactWithServer{
    var loginSuccess:LoginProtocol?
    var userInfoReady:GetUserInfoReadyProtocol?
    var selfMuseumReady:GetSelfMuseumReadyProtocol?
    var todayInfoReady:GetTodayInfoReadyProtocol?
    var itemInfoReady:GetItemInfoReadyProtocol?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    static func getNewTokenWithDefaults(){
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: nil, userInfo: nil, repeats: false)
    }
    
    func getTokenWithPassword(username:String,password:String){
        Alamofire.request(.POST, ApiManager.simpleLogin + "username=" + username).responseJSON{response in
            if(response.result.isSuccess)
            {
                print("gettoken")
                print(response.request)
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
                
                }
            }else{
                print("network error")
            }
            }
        }
    
    func getUserInfoFirst(){
        globalHiwuUser.userId = self.defaults.integerForKey("userId")
        let tmpToken = self.defaults.valueForKey("token") as? String
        
        let tmpUserName = self.defaults.valueForKey("userName") as? String
        self.userInfoReady?.getUserInfoReady()
        if(tmpToken != nil && tmpUserName != nil){
            globalHiwuUser.hiwuToken = tmpToken!
            globalHiwuUser.userName = tmpUserName!
        }
        userInfoReady?.getUserInfoReady()
        
    }
    
    func getSelfMuseum(){
        let url = ApiManager.getAllSelfGallery1_2 + String(globalHiwuUser.userId) + ApiManager.getAllSelfGallery2_2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{
        response in
            if(response.result.value != nil){
                print("get selfMuseum")
                print(response.request)
                globalHiwuUser.selfMuseum = JSON(response.result.value!)
                let tmpData:NSData = NSKeyedArchiver.archivedDataWithRootObject(response.result.value!)
                self.defaults.setObject(tmpData, forKey: "selfMuseum")
                self.defaults.synchronize()
                self.loginSuccess?.didGetSelfMuseum()
                self.selfMuseumReady?.getSelfMuseunReady()
                
            }else{
                if(self.defaults.valueForKey("selfMuseum") != nil){
                    globalHiwuUser.selfMuseum = JSON(NSKeyedUnarchiver.unarchiveObjectWithData(self.defaults.objectForKey("selfMuseum") as! NSData)!)
                     self.loginSuccess?.didGetSelfMuseum()
                    self.selfMuseumReady?.getSelfMuseunReady()
                    
                }else{
                    self.loginSuccess?.getSelfMuseumFailed()
                }
            }
        }
    }
    
    func getTodayInfo(){
        let url = ApiManager.getTodayPublicView
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
            if(response.result.value != nil){
                print("getTodayInfo")
                print(response.request)
                globalHiwuUser.todayMuseum = JSON(response.result.value!)
                let tmpData:NSData = NSKeyedArchiver.archivedDataWithRootObject(response.result.value!)
                self.defaults.setObject(tmpData, forKey: "todayMuseum")
                self.defaults.synchronize()
                self.todayInfoReady?.getTodayReady()
            }else{
                if(self.defaults.valueForKey("todayMuseum") != nil){
                    globalHiwuUser.todayMuseum = JSON(NSKeyedUnarchiver.unarchiveObjectWithData(self.defaults.objectForKey("todayMuseum") as! NSData)!)
                    self.todayInfoReady?.getTodayReady()
                    
                }else{
                    self.todayInfoReady?.getTodayFailed()
                }
            }
        
        }
        
    }
    
    func getItemInfo(itemId: Int){
        let url = ApiManager.getItemPublic1 + String(itemId) + ApiManager.getItemPublic2
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
            if(response.result.value != nil){
                print("get item info")
                print(response.request)
                globalHiwuUser.item = JSON(response.result.value!)
                self.itemInfoReady?.getItemInfoReady()
            }else{
                if(self.defaults.valueForKey("todayMuseum") != nil){
                    print("in default")
                    
                }else{
                    print("none")
                }
            }
        }
        NSThread.sleepForTimeInterval(4)
        print("failed")
        
    }
       
}
