//
//  LaunchScreen.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController,ServerContactorDelegates{
    
    var contactor = ContactWithServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactor.delegate = self
        self.contactor.getUserInfoFirst()
        self.contactor.getTodayInfo()
    }
    
    func getTodayInfoReady() {
        if(globalHiwuUser.todayMuseum != nil){
            let main = self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController
            main.navigationBar.barTintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
            main.navigationBar.bounds = CGRect(x: 0, y: 0, width: 600, height: 48)
//            main.fd_interactivePopDisabled = true
            self.presentViewController(main, animated: true, completion: {
            })
                  }
        else{
          
        }
    }
    
    func getTodayInfoFailed() {
        let alert = SCLAlertView()
        alert.showWarning(self, title: "初始化失败", subTitle: "请检查你的网络", closeButtonTitle: "确定", duration: 0)
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }
    
    func getUserInfoFirstReady() {
        
    }
    
    func getUserInfoFirstFailed() {
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
   
    }
    

}
