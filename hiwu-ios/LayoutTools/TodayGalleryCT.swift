//
//  TodayGalleryCT.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher


class TodayGalleryCT: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate {
    var superVC:UIViewController?
    var location = 0
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let nums = globalHiwuUser.todayMuseum![self.location]["gallery"]["items"].count as Int
        if(nums <= 9){
            return nums
        }else{
            return 9
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        //取collectionview的可重复使用cell
        let items = globalHiwuUser.todayMuseum![self.location]["gallery"]["items"]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TodayItemCell", forIndexPath: indexPath)
        //取imageview
        let images:UIImageView = cell.viewWithTag(6) as! UIImageView
        //“photos”里面不只一个图片,这里作为博物馆展示，只展示第一张
        let urlString = (items)[indexPath.row]["photos"][0]["url"].string!
        //设置imgaeview图片
        images.kf_setImageWithURL(NSURL(string: urlString)!)
//        images.image = UIImage(named: "add")
        //点击放大手势  实现了，但是小哦过比较捉急
        let gesture = UITapGestureRecognizer(target: self, action: "display:")
        gesture.view?.tag = indexPath.row
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TodayGalleryTitle", forIndexPath: indexPath)
        let galleryImage = cell.viewWithTag(1) as! UIImageView
        galleryImage.layer.cornerRadius = galleryImage.frame.size.width/2
        galleryImage.clipsToBounds = true
        galleryImage.kf_setImageWithURL(NSURL(string: globalHiwuUser.todayMuseum![self.location]["gallery"]["hiwuUser"]["avatar"].string!)!)
        let galleryNameLabel = cell.viewWithTag(2) as! UILabel
        galleryNameLabel.text = globalHiwuUser.todayMuseum![self.location]["gallery"]["name"].string!
        let gallerDescription = cell.viewWithTag(3) as! UILabel
        gallerDescription.text = globalHiwuUser.todayMuseum![self.location]["gallery"]["description"].string!
        let galleryItemNumLabel = cell.viewWithTag(4) as! UILabel
        galleryItemNumLabel.text = String(globalHiwuUser.todayMuseum![self.location]["gallery"]["items"].count)
        let gesture = UITapGestureRecognizer(target: self, action: "getGalleryDetail:")
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    func getGalleryDetail(sender:AnyObject){
        let galleryDetail = self.superVC?.storyboard?.instantiateViewControllerWithIdentifier("GalleryDetailVC") as! GalleryDetailVC
        print("today")
        print(globalHiwuUser.todayMuseum![self.location]["gallery"]["items"].count)
        galleryDetail.setInfo(globalHiwuUser.todayMuseum![self.location]["gallery"], userAvatar: globalHiwuUser.todayMuseum![self.location]["gallery"]["hiwuUser"]["avatar"].string!, userName: globalHiwuUser.todayMuseum![self.location]["gallery"]["hiwuUser"]["nickname"].string!)
        self.superVC?.showViewController(galleryDetail, sender: self)
    }
    
    
    func display(sender:UITapGestureRecognizer){
        let imager = sender.view?.viewWithTag(6) as! UIImageView
        let alert1 = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert1.addAction(UIAlertAction(title: "close", style: UIAlertActionStyle.Cancel, handler: nil))
        let image = UIImageView(frame: CGRect(x: 8, y: 10, width: 340, height: 460))
        image.contentMode = UIViewContentMode.ScaleAspectFit
        image.image = imager.image
        alert1.view.addSubview(image)
        self.superVC?.navigationController?.presentViewController(alert1, animated: true, completion: nil)
    }
    
    
    
}

