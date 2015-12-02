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

class GalleryDetailVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,GetItemInfoReadyProtocol,GetSelfMuseumReadyProtocol{
    
    var gallery:JSON?
    var userAvatar:String?
    var userName:String?
    let defaults = NSUserDefaults.standardUserDefaults()
    let contactor = ContactWithServer()
    var location = -1
    
    @IBOutlet weak var galleryDetails: UITableView!
    
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryDetails.delegate = self
        self.galleryDetails.dataSource = self
        self.galleryDetails.reloadData()
        print(gallery)

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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("GalleryTitle")! as UITableViewCell
            let ownerAvatar = cell.viewWithTag(1) as! UIImageView
            if(self.userAvatar != nil){
            ownerAvatar.kf_setImageWithURL(NSURL(string: self.userAvatar!)!)
                ownerAvatar.layer.cornerRadius = ownerAvatar.frame.size.width/2
                ownerAvatar.clipsToBounds = true
            }
            let galleryName = cell.viewWithTag(2) as! UITextField
            galleryName.text = self.gallery!["name"].string
            let galleryDescription = cell.viewWithTag(3) as! UITextField
            galleryDescription.text = self.gallery!["description"].string
            let itemNum = cell.viewWithTag(4) as! UILabel
            itemNum.text = String(self.gallery!["items"].count)
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemTitle")!
            let itemId = cell.viewWithTag(2) as! UILabel
            itemId.text = String(gallery!["items"][indexPath.row-1]["id"])
            let itemPic = cell.viewWithTag(10) as! UIImageView
            if(self.gallery!["items"][indexPath.row-1]["photos"][0]["url"].string != nil){
                itemPic.kf_setImageWithURL(NSURL(string: self.gallery!["items"][indexPath.row-1]["photos"][0]["url"].string!)!)}else{
                itemPic.image = UIImage(named: "add")
            }
            
            let itemName = cell.viewWithTag(20) as! UILabel
            itemName.text = gallery!["items"][indexPath.row-1]["name"].string
            let itemDescription = cell.viewWithTag(30) as! UILabel
            itemDescription.text = gallery!["items"][indexPath.row-1]["description"].string
            let itemTime = cell.viewWithTag(40) as! UILabel
            itemTime.text = String(gallery!["items"][indexPath.row-1]["date_y"].int!)
            let itemCity = cell.viewWithTag(50) as! UILabel
            itemCity.text = gallery!["items"][indexPath.row-1]["city"].string
            let itemOwner = cell.viewWithTag(60) as! UILabel
            itemOwner.text = self.userName!
            let gesture = UITapGestureRecognizer(target: self, action: "getItemDetail:")
            cell.addGestureRecognizer(gesture)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        contactor.superGalleryDetailVC = self
//        contactor.deleteItem(self.gallery!["items"][indexPath.row-1]["id"].int!)
        print("delete")
    }
    
    func didDeleteItem(){
        
        
    }
    
    func getItemDetail(sender:UITapGestureRecognizer){
        let contactor = ContactWithServer()
        contactor.itemInfoReady = self
        let itemIdLabel = sender.view?.viewWithTag(2) as! UILabel
        let itemId = Int(itemIdLabel.text!)
        print("prepare")
        print(NSDate(timeIntervalSinceNow: 0))
        let itemIdTextLabel = sender.view?.viewWithTag(2) as! UILabel
        if(self.defaults.objectForKey("item_" + itemIdTextLabel.text!) != nil){
                    globalHiwuUser.item = JSON(NSKeyedUnarchiver.unarchiveObjectWithData(self.defaults.objectForKey("item_" + itemIdTextLabel.text!) as! NSData)!)
            let itemDetail = self.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
            itemDetail.item = globalHiwuUser.item
            print("prepare for jump")
            print(NSDate(timeIntervalSinceNow: 0))
            self.navigationController?.pushViewController(itemDetail, animated: true)
            
        }else{
            print("ask server")
            contactor.getItemInfo(itemId!)
        }
    }
    
    func getItemInfoReady() {
        print(NSDate(timeIntervalSinceNow: 0))
        let itemDetail = self.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
        itemDetail.item = globalHiwuUser.item
        print(NSDate(timeIntervalSinceNow: 0))
        self.navigationController?.pushViewController(itemDetail, animated: true)
    }
    
    func getItemInfoFailed() {
        
    }
    
    func getSelfMuseunReady() {
    }
    
    func getSelfMuseunFailed() {
        
    }

}
