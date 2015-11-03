//
//  LaunchScreen.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController,ReadyProtocol {
    var contactor:ContactWithServer?

    @IBOutlet weak var launchImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactor = ContactWithServer()
        self.contactor!.prepareReady = self
        self.contactor?.getUserInfoFirst()
    }
    
    func getReady(){
        if(globalHiwuUser.todayMuseum != nil){
            self.navigationController?.presentViewController((self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigation"))!, animated: true, completion: nil)
            print("get ready")
        }
            
        else{
            let alert = UIAlertController(title: "无法获取初始化信息", message: "请检查你的网络", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.Default, handler: nil))
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func failedToReady() {
        print("failed")
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
