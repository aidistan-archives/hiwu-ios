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
    var myTableCell:UITableViewCell?
    var location = 0
    var tmpImage = UIImageView()
    var selfGallery:JSON?
    var imageStringToResize = ""
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        let nums = globalHiwuUser.selfMuseum!["galleries"][self.location]["items"].count as Int
        print(nums)
        print("num")
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
        print(urlString)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        //设置imgaeview图片
        imgaes.kf_setImageWithURL(NSURL(string: urlString)!)
        tmpImage.image = imgaes.image
        //点击放大手势
        let gesture = UITapGestureRecognizer(target: self, action: "display:")
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SelfGalleryTitle", forIndexPath: indexPath)
        
        //设置长廊的名字标签
        let galleryNameLabel = cell.viewWithTag(1) as! UILabel
        galleryNameLabel.text = (globalHiwuUser.selfMuseum!)[self.location]["name"].string
        let galleryItemNumLabel = cell.viewWithTag(2)as! UILabel
        galleryItemNumLabel.text = String((globalHiwuUser.selfMuseum!)[self.location]["galleries"]["items"].count)
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

