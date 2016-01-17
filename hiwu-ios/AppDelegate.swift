//
//  AppDelegate.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/16.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Kingfisher

var globalHiwuUser = UserModel()

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,WXApiDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let cache = KingfisherManager.sharedManager.cache
        cache.maxDiskCacheSize = 100 * 1024 * 1024
        WXApi.registerApp("wxe0b3b148c706525")
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() {
            print("已经安装微信")
//            let req = SendAuthReq()
//            req.scope = "snsapi_userinfo"
//            req.state = "123"
//            WXApi.sendReq(req)
        }
        
        // Override point for customization after application launch.
//        NSThread.sleepForTimeInterval(3)
        //设置这句设置停留时间
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
//        
//        
//        return WXApi.handleOpenURL(url, delegate: self)
//        
//    }
//    
//    func onReq(req: BaseReq!) {
//        print("onReq")
//    }
//    
//    func onResp(resp: BaseResp!) {
//        print("onResp")
//    }
//    
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
//        
//        return WXApi.handleOpenURL(url, delegate: self)
//        
//    }


}

