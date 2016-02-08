//
//  SelfMuseumVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import Alamofire

class SelfMuseumVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let defaults = NSUserDefaults.standardUserDefaults()
    let contactor = ContactWithServer()
    let notification = NSNotificationCenter.defaultCenter()
    var tableCellLocation = 0
    var itemSum = 0
    let bg = UIImage(named: "bg")
    
    
    
    @IBOutlet weak var selfGalleryDisplay: UITableView!
    @IBAction func toSettingButton(sender: UIButton) {
        let setting = self.storyboard?.instantiateViewControllerWithIdentifier("SettingVC") as! SettingVC
        setting.userId = globalHiwuUser.userId
        let url = ApiManager.getSelfUserInfo1 + String(setting.userId) + ApiManager.getSelfUserInfo2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, url).responseJSON{response in
            if(response.result.error == nil){
                if(response.result.value != nil){
                    setting.userInfo = JSON(response.result.value!)
                    self.navigationController?.pushViewController(setting, animated: true)
                }
            }else{
                let alert = UIAlertController(title: "网络错误", message: String(response.result.error), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            }
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfGalleryDisplay.delegate = self
        selfGalleryDisplay.dataSource = self
        bg?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: UIImageResizingMode.Tile)
        selfGalleryDisplay.backgroundColor = UIColor(patternImage: self.bg!)
    }
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.notification.removeObserver(self)
    }
    

    override func viewWillAppear(animated: Bool) {
        self.notification.addObserver(self, selector: "getSelfMuseumOk", name: "getSelfMuseumReady", object: nil)
        self.notification.addObserver(self, selector: "getSelfMuseumFailed", name: "getSelfMuseumFailed", object: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return globalHiwuUser.selfMuseum!["galleries"].count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.row == 0){
            return 170
        }else{
            let num = globalHiwuUser.selfMuseum!["galleries"][indexPath.row-1]["items"].count
            if(num>=7){
                return 410
            }else if(num>=4){
                return 300
            }else if(num>=1){
                return 200
            }else{
                return 100
            }
        }
    }
    
    @IBAction func addGallery(sender: UIButton) {
        let addGallery = self.storyboard?.instantiateViewControllerWithIdentifier("AddGalleryVC") as! AddGalleryVC
        self.navigationController?.pushViewController(addGallery, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        self.tableCellLocation = indexPath.row - 1
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfTitle")! as UITableViewCell
            cell.backgroundColor = UIColor(patternImage: self.bg!)
            let userAvatar = cell.viewWithTag(1) as! UIImageView
            let userNickname = cell.viewWithTag(2) as! UILabel
            let museumInfo = cell.viewWithTag(3) as! UILabel
            let description = cell.viewWithTag(10) as! UILabel
            let selfMuseum = globalHiwuUser.selfMuseum
            userAvatar.kf_setImageWithURL(NSURL(string: selfMuseum!["avatar"].string!)!, placeholderImage: UIImage(named: "头像"))
            userAvatar.layer.cornerRadius = userAvatar.frame.height/2
            userAvatar.clipsToBounds = true
            userNickname.text = selfMuseum!["nickname"].string!
            museumInfo.text = "  " + String(selfMuseum!["galleries"].count) + "  长廊 | " + String(self.itemSum) + " 物品  "
            museumInfo.layer.cornerRadius = museumInfo.frame.height/2
            museumInfo.clipsToBounds = true
            if(selfMuseum!["description"].string != nil){
                description.text = selfMuseum!["description"].string!
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfGalleryCell")! as UITableViewCell
            let collection = (cell.viewWithTag(4)) as! SelfGalleryCT
            let width = tableView.frame.width
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSizeMake((width - 16)/3, (width - 16)/3)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            layout.headerReferenceSize = CGSizeMake(width, width/6)
            layout.footerReferenceSize = CGSizeMake(0, 0)
            collection.collectionViewLayout = layout
            collection.location =  indexPath.row - 1
            collection.superVC = self
            collection.delegate = collection
            collection.dataSource = collection
            collection.reloadData()
            return cell
            
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let alert = SCLAlertView()
        alert.addButton("删除", actionBlock: { () in
            self.deleteGallery(globalHiwuUser.selfMuseum!["galleries"][indexPath.row-1]["id"].int!)
            
        })
        alert.showWarning(self, title: "删除长廊", subTitle: "删除长廊后，会同时删除里面所有的物品。确定删除吗？", closeButtonTitle: "取消", duration: 0)
        tableView.editing = false
        
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(indexPath.row >= 1){
            return true
        }else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    
    func networkError(){
        let alert = UIAlertController(title: "请求失败", message: "请检查你的网络", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "知道了", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteGallery(galleryId:Int){
        let deleteUrl = ApiManager.deleteGallery1 + String(galleryId) + ApiManager.deleteGallery2 + globalHiwuUser.hiwuToken
        Alamofire.request(.DELETE, NSURL(string: deleteUrl)!).responseJSON{response in
            if(response.result.value != nil){
                let value = JSON(response.result.value!)
                if(value["error"] == nil){
                    print("delete success")
                    self.refresh()
                }
            }
        }
        
    }
    
    func refresh(){
        contactor.getSelfMuseum()
    }
    
    func getSelfMuseumOk(){
        self.selfGalleryDisplay.reloadData()
    }
    
    func getSelfMuseumFailed(){
        
    }


}
