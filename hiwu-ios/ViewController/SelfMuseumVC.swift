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
    @IBOutlet weak var selfGalleryDisplay: UITableView!
    var tableCellLocation = 0
    var itemSum = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print("selfmuseum")
        print(globalHiwuUser.selfMuseum)
        for(var i=0 ;i < globalHiwuUser.selfMuseum!["galleries"].count;i++ ){
            itemSum += globalHiwuUser.selfMuseum!["galleries"][i]["items"].count
        }
        selfGalleryDisplay.delegate = self
        selfGalleryDisplay.dataSource = self
        selfGalleryDisplay.reloadData()
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: "back")
        gesture.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(gesture)
    }
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return globalHiwuUser.selfMuseum!["galleries"].count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.row == 0){
            return 100
        }else{
            return 400
            
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
            let userAvatar = cell.viewWithTag(1) as! UIImageView
            let userNickname = cell.viewWithTag(2) as! UILabel
            let museumInfo = cell.viewWithTag(3) as! UILabel
            let selfMuseum = globalHiwuUser.selfMuseum
            print(globalHiwuUser.hiwuToken)
            print(selfMuseum)
            userAvatar.kf_setImageWithURL(NSURL(string: selfMuseum!["avatar"].string!)!)
            userAvatar.layer.cornerRadius = userAvatar.frame.height/2
            userAvatar.clipsToBounds = true
            userNickname.text = selfMuseum!["nickname"].string!
            museumInfo.text = String(selfMuseum!["galleries"].count) + "  长廊 | " + String(self.itemSum) + " 物品  "
            museumInfo.layer.cornerRadius = museumInfo.frame.height/2
            museumInfo.clipsToBounds = true
            let setting = cell.viewWithTag(5) as! UIButton
            setting.addTarget(self, action: "toSetting", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfGalleryCell")! as UITableViewCell
            let collection = (cell.viewWithTag(4)) as! SelfGalleryCT
            collection.location =  indexPath.row - 1
            collection.superVC = self
            collection.delegate = collection
            collection.dataSource = collection
            collection.reloadData()
            return cell
            
        }
            }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func toSetting(){
        print("to setting")
        print(globalHiwuUser.userId)
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
    


}
