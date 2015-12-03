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
            museumInfo.text = String(selfMuseum!["galleries"].count) + "长廊 |"
            var sum = 0
            for(var i=0;i<selfMuseum!["galleries"].count;i++ ){
                sum += selfMuseum!["galleries"][i]["items"].count
            }
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

}
