//
//  LaunchScreen.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController,GetUserInfoReadyProtocol,GetTodayInfoReadyProtocol{
    
    var contactor:ContactWithServer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactor = ContactWithServer()
        self.contactor!.todayInfoReady = self
        self.contactor!.userInfoReady = self
        self.contactor!.getUserInfoFirst()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            sleep(5)
            if(globalHiwuUser.todayMuseum == nil){
            let alert = UIAlertController(title: "无法获取初始化信息", message: "请检查你的网络", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func getTodayReady() {
        if(globalHiwuUser.todayMuseum != nil){
            let main = self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController
            print("get ready in push")
            self.presentViewController(main, animated: true, completion: {
//                let today = self.storyboard?.instantiateViewControllerWithIdentifier("TodayVC") as! TodayVC
//                main.pushViewController(today, animated: true)
            })        }
        else{
          
        }
    }
    
    func getTodayFailed() {
        
    }
    
    func getUserInfoFailed() {
        
    }
    
    func getUserInfoReady() {
        print("getUserinfoready in launch")
        self.contactor?.getTodayInfo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
