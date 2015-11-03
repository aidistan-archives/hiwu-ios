//
//  SelfGalleryCT.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher


class SelfGalleryCT: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate {
    var superVC:UIViewController?
    var location = 0
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let nums = globalHiwuUser.selfMuseum!["galleries"][self.location]["items"].count as Int
        if(nums <= 9){
            return nums
        }else{
            return 9
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        //取collectionview的可重复使用cell
        let items = globalHiwuUser.selfMuseum!["galleries"][self.location]["items"]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SelfItemCell", forIndexPath: indexPath)
        //取imageview
        let imgaes:UIImageView = cell.viewWithTag(2) as! UIImageView
        //“photos”里面不只一个图片,这里作为博物馆展示，只展示第一张
        let urlString = (items)[indexPath.row]["photos"][0]["url"].string!
        //设置imgaeview图片
        imgaes.kf_setImageWithURL(NSURL(string: urlString)!)
        //点击放大手势  实现了，但是小哦过比较捉急
        let gesture = UITapGestureRecognizer(target: self, action: "display:")
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SelfGalleryTitle", forIndexPath: indexPath)
        let galleryNameLabel = cell.viewWithTag(1) as! UILabel
        galleryNameLabel.text = (globalHiwuUser.selfMuseum!)["galleries"][self.location]["name"].string
        let galleryItemNumLabel = cell.viewWithTag(2)as! UILabel
        galleryItemNumLabel.text = String((globalHiwuUser.selfMuseum!)["galleries"][self.location]["items"].count)
        return cell
    }
    
    
    func display(sender:UITapGestureRecognizer){
        let imager = sender.view?.viewWithTag(2) as! UIImageView
        let alert1 = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert1.addAction(UIAlertAction(title: "close", style: UIAlertActionStyle.Cancel, handler: nil))
        let image = UIImageView(frame: CGRect(x: 8, y: 10, width: 340, height: 460))
        image.contentMode = UIViewContentMode.ScaleAspectFit
        image.image = imager.image
        alert1.view.addSubview(image)
        self.superVC?.navigationController?.presentViewController(alert1, animated: true, completion: nil)
    }
    
    
    
}

