//
//  SelfMuseumVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import  UIKit

class SelfMuseumVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var selfGalleryDisplay: UITableView!
    var tableCellLocation = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.selfGallaryNums = self.selfGallaryNames!.count
        selfGalleryDisplay.delegate = self
        selfGalleryDisplay.dataSource = self
        selfGalleryDisplay.reloadData()
        if(globalHiwuUser.userName == ""){
            if(NSUserDefaults.standardUserDefaults().valueForKey("userName") != nil){
                    globalHiwuUser.userName = NSUserDefaults.standardUserDefaults().valueForKey("userName") as! String}
            else{
                globalHiwuUser.userName = "Unknown"
            }
        }
        let backGesture = UISwipeGestureRecognizer(target: self, action: "backButton:")
        backGesture.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backGesture)

        //TODO 每次启动是否需要进行头像更新，怎么避免不必要的流量消耗，并能及时和服务器上的头像保持一致
        //TODO 获取博物馆数目，博物馆名字，藏品数目，缩略图等信息
        
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return globalHiwuUser.selfMuseum!.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        self.tableCellLocation = indexPath.row - 1
        if(indexPath.row == 0){
            return tableView.dequeueReusableCellWithIdentifier("SelfTitle")! as UITableViewCell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("SelfGalleryCell")! as UITableViewCell
            let collection = (cell.viewWithTag(4)) as! SelfGalleryCT
            collection.location =  indexPath.row
            collection.reuseIdentifier = "SelfGalleryTitle"
            collection.delegate = collection
            collection.dataSource = collection
            collection.reloadData()
            return cell
            
        }
            }


}
