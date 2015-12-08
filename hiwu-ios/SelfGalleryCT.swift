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


class SelfGalleryCT: UICollectionView,UICollectionViewDataSource,UICollectionViewDelegate,GetItemInfoReadyProtocol {
    var superVC:UIViewController?
    var location = 0
    var gallery:JSON?
    
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
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SelfGalleryTitle", forIndexPath: indexPath)
        let galleryNameLabel = cell.viewWithTag(1) as! UILabel
        galleryNameLabel.text = (globalHiwuUser.selfMuseum!)["galleries"][self.location]["name"].string
        let galleryItemNumLabel = cell.viewWithTag(2)as! UILabel
        galleryItemNumLabel.text = String((globalHiwuUser.selfMuseum!)["galleries"][self.location]["items"].count)
        let gesture = UITapGestureRecognizer(target: self, action: "getGalleryDetail:")
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let id = globalHiwuUser.selfMuseum!["galleries"][self.location]["items"][indexPath.row]["id"].int!
        let contactor = ContactWithServer()
        contactor.getSelfItemInfo(id)
        contactor.itemInfoReady = self
        
    }
    
    func getGalleryDetail(sender:AnyObject){
        let galleryDetail = self.superVC?.storyboard?.instantiateViewControllerWithIdentifier("GalleryDetailVC") as! GalleryDetailVC
        galleryDetail.isMine = true
        galleryDetail.setInfo(globalHiwuUser.selfMuseum!["galleries"][self.location], userAvatar: globalHiwuUser.selfMuseum!["avatar"].string!, userName: globalHiwuUser.selfMuseum!["nickname"].string!)
        galleryDetail.location = self.location
        self.superVC?.showViewController(galleryDetail, sender: self)
    }
    
    func getItemInfoFailed() {
        
    }
    
    func getItemInfoReady() {
        let itemDetail = superVC?.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
        itemDetail.isMine = true
        itemDetail.itemId = globalHiwuUser.item!["id"].int!
        self.superVC?.navigationController?.pushViewController(itemDetail, animated: true)
    }
    
    
    
}

