//
//  ItemDetailVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/31.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ItemDetailVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var itemDetailList: UITableView!
    var item:JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        itemDetailList.dataSource = self
        itemDetailList.delegate = self
        itemDetailList.reloadData()
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 3 + self.item!["comments"].count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemImage")
                let itemImage = cell?.viewWithTag(1) as! UIImageView
                itemImage.kf_setImageWithURL(NSURL(string: self.item!["photos"][0]["url"].string!)!)
                let itemTime = cell?.viewWithTag(2) as! UILabel
                itemTime.text = String(self.item!["date_y"].int)
                let itemCity = cell?.viewWithTag(3) as! UILabel
                itemCity.text = self.item!["city"].string
                let itemOwner = cell?.viewWithTag(4) as! UIImageView
                let userAvatar = self.item!["hiwuUser"]["avatar"].string!
                itemOwner.kf_setImageWithURL(NSURL(string:userAvatar)!)
            return cell!
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemDescription")
                let itemName = cell?.viewWithTag(1) as! UILabel
                itemName.text = self.item!["name"].string
                let itemDescription = cell?.viewWithTag(2) as! UILabel
                itemDescription.text = self.item!["description"].string
                return cell!
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("Like")
                let addLike = cell?.viewWithTag(1) as! UIButton
                let likeLabel = cell?.viewWithTag(2) as! UILabel
                let addComment = cell?.viewWithTag(3) as! UIButton
                let commentLabel = cell?.viewWithTag(4) as! UILabel
                likeLabel.text = String(self.item!["likes"].int!) + "人喜欢"
                commentLabel.text = String(self.item!["comments"].count) + "人评论"
                return cell!
            default :
                let cell = tableView.dequeueReusableCellWithIdentifier("Comments")
                let userName = cell?.viewWithTag(1) as! UILabel
                let comment = cell?.viewWithTag(2) as! UILabel
                userName.text = self.item!["nickname"].string! + "："
                comment.text = self.item!["comments"][indexPath.row - 3].string!
                return cell!
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
