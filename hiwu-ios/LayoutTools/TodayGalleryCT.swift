//
//  TodayGalleryCT.swift
//  TodayGalleryCollectionTableView
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher


class TodayGalleryCT: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate {
    
    var myTableCell:UITableViewCell?
    var location = 0
    var items:JSON?
    var reuseIdentifier = ""
    var imageStringToResize = ""
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if(globleTodayModel.todayGallery![self.location]["items"].count) <= 9{
            return (globleTodayModel.todayGallery!)[self.location]["items"].count
        }else{
            return 9
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("picCell", forIndexPath: indexPath)
        let imgaes:UIImageView = cell.viewWithTag(2) as! UIImageView
        imgaes.image = UIImage(named: picNames[self.location][indexPath.row as Int])
        print("\n\n\n_____________")
        let urlString = (globleTodayModel.todayGallery!)[self.location]["items"][indexPath.row]["photos"][0]["url"].string!
        //“photos”里面不只一个图片
        imgaes.kf_setImageWithURL(NSURL(string: urlString)!)
        let gesture = UITapGestureRecognizer(target: self, action: "display")
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: self.reuseIdentifier, forIndexPath: indexPath)
        //如果是我的博物馆
        if(self.reuseIdentifier=="SelfGalleryHeader"){
            let galleryNameLabel = cell.viewWithTag(1) as! UILabel
            galleryNameLabel.text = (globleUserGalleryModel.userGallery!)[self.location]["name"].string
            //此处换成indexpath试试
            let galleryItemNumLabel = cell.viewWithTag(2) as! UILabel
            galleryItemNumLabel.text = String((globleUserGalleryModel.userGallery!)[self.location]["items"].count)
            
        //如果是今日博物展
        }else if(self.reuseIdentifier=="TodayGalleryHeader"){
            let galleryOwnerAvatar =  cell.viewWithTag(1) as! UIImageView
            galleryOwnerAvatar.layer.cornerRadius = galleryOwnerAvatar.frame.size.width/2
            let avatarUrlString = (globleTodayModel.todayGallery!)[self.location]["hiwuUser"]["avatar"].string!
            galleryOwnerAvatar.kf_setImageWithURL(NSURL(string: avatarUrlString)!)
            
            let galleryNameLabel = cell.viewWithTag(2) as! UILabel
            galleryNameLabel.text = (globleTodayModel.todayGallery!)[self.location]["name"].string
            
            let galleryDiscriptionLabel = cell.viewWithTag(3) as! UILabel
            galleryDiscriptionLabel.text = (globleTodayModel.todayGallery!)[self.location]["description"].string
            let galleryItemNumLabel = cell.viewWithTag(4)as! UILabel
            galleryItemNumLabel.text = String((globleTodayModel.todayGallery!)[self.location]["items"].count)
            
        
        }
        return cell
    }
    
    func display(){
        print("tap")
//        let alert1 = UIAlertController(title: "", message: "\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.Alert)
//        alert1.addAction(UIAlertAction(title: "close", style: UIAlertActionStyle.Default, handler: nil))
//        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        image.kf_setImageWithURL(NSURL(string: string)!)
//        alert1.view.addSubview(image)
    }
    

    
}
