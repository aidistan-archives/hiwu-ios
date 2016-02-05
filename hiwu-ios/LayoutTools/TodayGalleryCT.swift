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


class TodayGalleryCT: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate,GetItemInfoReadyProtocol{
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
        print(collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath))
        //取imageview
        let images:UIImageView = cell.viewWithTag(6) as! UIImageView
        //“photos”里面不只一个图片,这里作为博物馆展示，只展示第一张
        let urlString = (items)[indexPath.row]["photos"][0]["url"].string!
        //设置imgaeview图片
        
        images.kf_setImageWithURL(NSURL(string: urlString + "@!200x200")!)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TodayGalleryTitle", forIndexPath: indexPath)
        let galleryImage = cell.viewWithTag(1) as! UIImageView
        galleryImage.layer.cornerRadius = (cell.frame.height - 17)/2
        galleryImage.clipsToBounds = true
        galleryImage.kf_setImageWithURL(NSURL(string: globalHiwuUser.todayMuseum![self.location]["gallery"]["hiwuUser"]["avatar"].string! + "@!200x200")!)
        let galleryNameLabel = cell.viewWithTag(2) as! UILabel
        let nickName = globalHiwuUser.todayMuseum![self.location]["gallery"]["hiwuUser"]["nickname"].string!
        galleryNameLabel.text = nickName + " ⎡" + globalHiwuUser.todayMuseum![self.location]["gallery"]["name"].string! + " ⎦"
        let galleryItemNumLabel = cell.viewWithTag(4) as! UILabel
        galleryItemNumLabel.text = String(globalHiwuUser.todayMuseum![self.location]["gallery"]["items"].count)
        let gesture = UITapGestureRecognizer(target: self, action: "getGalleryDetail:")
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    func getGalleryDetail(sender:AnyObject){
        let galleryDetail = self.superVC?.storyboard?.instantiateViewControllerWithIdentifier("GalleryDetailVC") as! GalleryDetailVC
        galleryDetail.gallery = globalHiwuUser.todayMuseum![self.location]["gallery"]
        galleryDetail.isMine = false
        self.superVC?.showViewController(galleryDetail, sender: self)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let id = globalHiwuUser.todayMuseum![self.location]["gallery"]["items"][indexPath.row]["id"].int!
        let itemDetail = superVC?.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
        itemDetail.isMine = false
        itemDetail.itemId = id
        self.superVC?.navigationController?.pushViewController(itemDetail, animated: true)
    }
    
    func getItemInfoReady() {

        
    }
    
    func getItemInfoFailed() {
        
    }
    
    
    
    
}

