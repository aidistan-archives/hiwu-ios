//
//  GalleryDetailVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/30.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class GalleryDetailVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,GetItemInfoReadyProtocol{
    
    var gallery:JSON?
    var userAvatar:String?
    var userName:String?
    
    @IBOutlet weak var galleryDetails: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryDetails.delegate = self
        self.galleryDetails.dataSource = self
        self.galleryDetails.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func setInfo(gallery:JSON,userAvatar:String?,userName:String){
        self.gallery = gallery
        self.userAvatar = userAvatar
        self.userName = userName
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.gallery!["items"].count+1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 94
        
        }else{
        return 140
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("GalleryTitle")! as UITableViewCell
            let ownerAvatar = cell.viewWithTag(1) as! UIImageView
            if(self.userAvatar != nil){
            ownerAvatar.kf_setImageWithURL(NSURL(string: self.userAvatar!)!)
            }
            let galleryName = cell.viewWithTag(2) as! UITextField
            galleryName.text = self.gallery!["name"].string
            let galleryDescription = cell.viewWithTag(3) as! UITextField
            galleryDescription.text = self.gallery!["description"].string
            let itemNum = cell.viewWithTag(4) as! UILabel
            itemNum.text = String(self.gallery!["items"].count)
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemTitle")! as UITableViewCell
            let itemPic = cell.viewWithTag(1) as! UIImageView
            itemPic.kf_setImageWithURL(NSURL(string: self.gallery!["items"][indexPath.row-1]["photos"][0]["url"].string!)!)
            let itemName = cell.viewWithTag(2) as! UILabel
            itemName.text = gallery!["items"][indexPath.row-1]["name"].string
            let itemDescription = cell.viewWithTag(3) as! UILabel
            itemDescription.text = gallery!["items"][indexPath.row-1]["description"].string
            let itemTime = cell.viewWithTag(4) as! UILabel
            itemTime.text = String(gallery!["items"][indexPath.row-1]["date_y"].int!)
            let itemCity = cell.viewWithTag(5) as! UILabel
            itemCity.text = gallery!["items"][indexPath.row-1]["city"].string
            let itemOwner = cell.viewWithTag(6) as! UILabel
            itemOwner.text = self.userName!
            let gesture = UITapGestureRecognizer(target: self, action: "getItemDetail:")
            cell.tag = self.gallery!["items"][indexPath.row-1]["id"].int!
            print(cell.tag)
            cell.addGestureRecognizer(gesture)
            return cell
        }
    }
    
    func getItemDetail(sender:UITapGestureRecognizer){
        let contactor = ContactWithServer()
        contactor.itemInfoReady = self
        contactor.getItemInfo(sender.view!.tag)
    }
    
    func getItemInfoReady() {
        let itemDetail = self.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
        itemDetail.item = globalHiwuUser.item
        self.navigationController?.pushViewController(itemDetail, animated: true)
    }
    
    func getItemInfoFailed() {
        
    }

}
