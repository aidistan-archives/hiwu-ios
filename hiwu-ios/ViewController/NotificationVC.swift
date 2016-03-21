//
//  NotificationVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/3/17.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//


import UIKit
import SwiftyJSON
import Kingfisher

class NotificationVC: UITableViewController {
    
    var notifications:JSON?
    var cellNum = 0
    let contactor = ContactWithServer()
    var toDetail = false
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func clearMessage(sender: UIButton) {
        self.contactor.deleteNotification(globalHiwuUser.userId, complete: {() in
            print("get")
            self.getNotificationInfo()
        })
    }
    
    override func viewDidLoad() {
        getNotificationInfo()
        super.viewDidLoad()
        
    }
    
    func getNotificationInfo(){
        self.contactor.getNotification(globalHiwuUser.userId, complete: { note in
            self.notifications = note

            self.cellNum = (self.notifications?.count)!
            self.tableView.reloadData()
            print(note)
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        if( !toDetail ){
        }
        self.toDetail = false
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellNum
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("note")
        let avatar = cell?.viewWithTag(1) as! UIImageView
        let avatarUrl = self.notifications![indexPath.row]["fromUser"]["avatar"].string
        if(avatarUrl != nil){
            avatar.kf_setImageWithURL(NSURL(string: avatarUrl!)!, placeholderImage: nil, optionsInfo: nil)
        }
        avatar.layer.cornerRadius = avatar.frame.size.width/2
        avatar.clipsToBounds = true
        let fromUserName = cell?.viewWithTag(2) as! UILabel
        let nickname = self.notifications![indexPath.row]["fromUser"]["nickname"]
        if(nickname != nil){
            fromUserName.text = nickname.string!
        }else{
            fromUserName.text = "未命名用户"
        }
        
        let comments = cell?.viewWithTag(4) as! UILabel
        if(self.notifications![indexPath.row]["type"].string! == "ITEM_LIKE"){
            comments.text = "给你点了一个赞"
        }else if(self.notifications![indexPath.row]["type"].string! == "COMMENT_REPLY" && self.notifications![indexPath.row]["comment"]["content"] != nil){
            comments.text = self.notifications![indexPath.row]["comment"]["content"].string!
        }
        
        let itemImage = cell?.viewWithTag(5) as! UIImageView
        if(self.notifications![indexPath.row]["item"]["photos"][0]["url"] != nil){
            itemImage.kf_setImageWithURL(NSURL(string: self.notifications![indexPath.row]["item"]["photos"][0]["url"].string!)!, placeholderImage: nil, optionsInfo: nil)
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let itemDetail = self.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
        itemDetail.itemId = self.notifications![indexPath.row]["item"]["id"].int!
        itemDetail.isMine = true
        self.toDetail = true
        self.navigationController?.pushViewController(itemDetail, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    
}
