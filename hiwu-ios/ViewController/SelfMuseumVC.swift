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

class SelfMuseumVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet weak var selfGalleryDisplay: UITableView!
    var tableCellLocation = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.selfGalleryDisplay)
        selfGalleryDisplay.delegate = self
        selfGalleryDisplay.dataSource = self
        selfGalleryDisplay.reloadData()
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("museum count")
        debugPrint(globalHiwuUser.selfMuseum!["galleries"].count)
        return globalHiwuUser.selfMuseum!["galleries"].count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.row == 0){
            return 100
        }else{
            return 400
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        self.tableCellLocation = indexPath.row - 1
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfTitle")! as UITableViewCell
            let userAvatar = cell.viewWithTag(1) as! UIImageView
            let userNickname = cell.viewWithTag(2) as! UILabel
            let galleryNum = cell.viewWithTag(3) as! UILabel
            let itemNum = cell.viewWithTag(4) as! UILabel
            let selfMuseum = globalHiwuUser.selfMuseum
            userAvatar.kf_setImageWithURL(NSURL(string: selfMuseum!["avatar"].string!)!)
            userNickname.text = selfMuseum!["nickname"].string!
            galleryNum.text = String(selfMuseum!["galleries"].count)
            var sum = 0
            for(var i=0;i<selfMuseum!["galleries"].count;i++ ){
                sum += selfMuseum!["galleries"][i]["items"].count
            }
            itemNum.text = String(sum)
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


}
