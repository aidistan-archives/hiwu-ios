//
//  TodayVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class TodayVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var todayGalleryDisplay: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func enterToSelfMuseum(sender: UIButton) {
        let nowDate = NSDate(timeIntervalSinceNow: 0)
        let defaults = NSUserDefaults.standardUserDefaults()
        let deadline = defaults.integerForKey("deadline")
        let freshline = defaults.integerForKey("freshline")
        if((deadline == 0)||(freshline == 0||nowDate.timeIntervalSince1970 > Double(deadline))){
            self.navigationController!.performSegueWithIdentifier("ToLoginSegue", sender: self)
            NSLog("Invalid")
            
        }else if(nowDate.timeIntervalSince1970 > Double(freshline)){
                debugPrint("not fresh")
                self.navigationController!.performSegueWithIdentifier("ToSelfMuseumSegue", sender: self)
                ContactWithServer.getNewTokenWithDefaults()
                print("i'm here")
            
            }else{
            self.navigationController!.performSegueWithIdentifier("ToSelfMuseumSegue", sender: self)
                
            }
            }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        return UITableViewCell()
    }

}
