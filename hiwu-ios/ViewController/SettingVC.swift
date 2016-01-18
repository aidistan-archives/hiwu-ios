//
//  SettingVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/1/16.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher


class SettingVC: UITableViewController {
    
    var userId = globalHiwuUser.userId
    var userInfo:JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.userInfo)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 3
        default:
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell?
        switch indexPath.section{
        case 0:
            print(indexPath.section)
            switch indexPath.row{
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("Avatar")
                let userAvatar = cell?.viewWithTag(1) as! UIImageView
                userAvatar.kf_setImageWithURL(NSURL(string: self.userInfo!["avatar"].string!)!, placeholderImage: UIImage(named: "iconfont-like"))    
                userAvatar.layer.cornerRadius = userAvatar.frame.height/2
                userAvatar.clipsToBounds = true
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("Name")
                let name = cell?.viewWithTag(1) as! UILabel
                if(self.userInfo!["nickname"].string! != ""){
                    name.text = self.userInfo!["nickname"].string!
                }else{
                    name.text = "未命名"
                }
                
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("Description")
                let description = cell?.viewWithTag(1) as! UILabel
                if(self.userInfo!["description"].string! != ""){
                    description.text = self.userInfo!["description"].string!
                }else{
                    description.text = "未添加描述"
                }
            }
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("Account")
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("Feedback")
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Logout")
            
        }

        return cell!
    }
    
    func getUserInfo(){
        let url = ApiManager.getSelfUserInfo1 + String(self.userId) + ApiManager.getSelfUserInfo2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, url).responseJSON{response in
            if(response.result.error == nil){
                self.userInfo  = JSON(response.result.value!)
            }else{
                let alert = UIAlertController(title: "网络错误", message: String(response.result.error), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                print("hello")
            case 1:
                print("call edit name")
            default:
                print("call edit description")
            }
        case 1:
            print("call account")
        case 2:
            print("call feed back")
        default:
            self.navigationController?.popToRootViewControllerAnimated(true)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setDouble(0, forKey: "deadline")
            
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                return 100
            case 1:
                return 50
            default:
                return 50
            }
        case 1:
            return 50
        case 2:
            return 50
        default:
            return 50
            
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
