//
//  LaunchScreen.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController,GetTodayInfoReadyProtocol{
    
    var contactor:ContactWithServer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactor = ContactWithServer()
        self.contactor!.todayInfoReady = self
        self.contactor?.getUserInfoFirst()
        self.contactor?.getTodayInfo()
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            sleep(5)
            if(globalHiwuUser.todayMuseum == nil){
            let alert = UIAlertController(title: "无法获取初始化信息", message: "请检查你的网络", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.Default, handler: nil))
                dispatch_async(dispatch_get_main_queue(), {
                  self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
    }
    

    
    
    func getTodayReady() {
        if(globalHiwuUser.todayMuseum != nil){
            let main = self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController
            main.navigationBar.barTintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
            main.navigationBar.bounds = CGRect(x: 0, y: 0, width: 600, height: 48)
            self.presentViewController(main, animated: true, completion: {
            })
                  }
        else{
          
        }
    }
    
    func getTodayFailed() {
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
