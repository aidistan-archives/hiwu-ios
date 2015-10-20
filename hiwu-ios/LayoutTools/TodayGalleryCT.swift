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
    var superVC:UIViewController?
    var myTableCell:UITableViewCell?
    var location = 0
    var tmpImage = UIImageView()
    var todayGallery:JSON?
    var reuseIdentifier = ""
    var imageStringToResize = ""
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        let num = self.todayGallery![self.location]["items"].count
        if(num <= 9){
            return num
        }else{
            return 9
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        //取collectionview的可重复使用cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TodayItemCell", forIndexPath: indexPath)
        //取imageview
        let imgaes:UIImageView = cell.viewWithTag(2) as! UIImageView
        //“photos”里面不只一个图片,这里作为博物馆展示，只展示第一张
        let urlString = (self.todayGallery!)[self.location]["items"][indexPath.row]["photos"][0]["url"].string!
        
        //TODO:优化进行改进，先进行缓存
        //设置imgaeview图片
        imgaes.kf_setImageWithURL(NSURL(string: urlString)!)
        tmpImage.image = imgaes.image
        //点击放大手势
        let gesture = UITapGestureRecognizer(target: self, action: "display:")
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TodayGalleryHeader", forIndexPath: indexPath)
            //设置拥有者头像
            let galleryOwnerAvatar =  cell.viewWithTag(1) as! UIImageView
            galleryOwnerAvatar.layer.cornerRadius = galleryOwnerAvatar.frame.size.width/2
        
            let avatarUrlString = (self.todayGallery!)[self.location]["hiwuUser"]["avatar"].string!
            galleryOwnerAvatar.kf_setImageWithURL(NSURL(string: avatarUrlString)!)
        
            //设置长廊的名字标签
            let galleryNameLabel = cell.viewWithTag(2) as! UILabel
            galleryNameLabel.text = (self.todayGallery!)[self.location]["name"].string
            
            let galleryDiscriptionLabel = cell.viewWithTag(3) as! UILabel
            galleryDiscriptionLabel.text = (self.todayGallery!)[self.location]["description"].string
            let galleryItemNumLabel = cell.viewWithTag(4)as! UILabel
            galleryItemNumLabel.text = String((self.todayGallery!)[self.location]["items"].count)
        return cell
    }
    
    func display(){
        let alert1 = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        alert1.addAction(UIAlertAction(title: "close", style: UIAlertActionStyle.Default, handler: nil))
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        image.image = self.tmpImage.image
        alert1.view.addSubview(image)
        self.superVC?.navigationController?.presentViewController(alert1, animated: true, completion: nil)
    }
    

    
}
