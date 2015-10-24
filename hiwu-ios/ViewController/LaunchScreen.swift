//
//  LaunchScreen.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class LaunchScreen: UIViewController,ReadyProtocol {

    @IBOutlet weak var launchImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let contactor = ContactWithServer()
        contactor.prepareReady = self
        contactor.getTodayInfo()

    }
    
    func getReady(){
        self.navigationController?.presentViewController((self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigation"))!, animated: true, completion: nil)
    }
    
    func failedToReady() {
        print("failed")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
