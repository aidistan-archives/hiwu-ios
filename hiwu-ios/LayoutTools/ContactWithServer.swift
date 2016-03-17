//
//  ContactWithServer.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ContactWithServer{
    var superGalleryDetailVC:GalleryDetailVC?
    var delegate:ServerContactorDelegates?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
//    func getTokenWithPassword(username:String,password:String){
//        Alamofire.request(.POST, ApiManager.simpleLogin + "username=" + username).responseJSON{response in
//            if(response.result.isSuccess)
//            {
//                if(response.result.error == nil){
//                    let userInfo = JSON(response.result.value!)
//                    if(userInfo != nil){
//                        globalHiwuUser.hiwuToken = (userInfo["id"]).string!
//                        globalHiwuUser.userId = (userInfo["userId"]).int!
//                        globalHiwuUser.userName = username
//                        self.defaults.setValue((userInfo["id"]).string!, forKey: "token")
//                        self.defaults.setValue(username, forKey: "userName")
//                        self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!).timeIntervalSince1970, forKey: "deadline")
//                        self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!/2).timeIntervalSince1970, forKey: "freshline")
//                        self.defaults.setInteger((userInfo["userId"]).int!, forKey: "userId")
//                        self.defaults.synchronize()
//                    }
//                }else{
//                    print("error")
//                
//                }
//            }else{
//                print("network error")
//            }
//            }
//        }
    
    func getUserInfoFirst(){
        globalHiwuUser.userId = self.defaults.integerForKey("userId")
        let tmpToken = self.defaults.valueForKey("token") as? String
        print(tmpToken)
        if(tmpToken != nil){
            globalHiwuUser.hiwuToken = tmpToken!
            self.delegate?.getUserInfoFirstReady!()
        }else{
            self.delegate?.getUserInfoFirstFailed!()
        }
        
    }
    
    func getSelfMuseum(){
        let url = ApiManager.getAllSelfGallery1_2 + String(globalHiwuUser.userId) + ApiManager.getAllSelfGallery2_2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, url).responseJSON{response in
            if(response.result.value != nil && response.result.error == nil){
                globalHiwuUser.selfMuseum = JSON(response.result.value!)
                let tmpData:NSData = NSKeyedArchiver.archivedDataWithRootObject(response.result.value!)
                self.defaults.setObject(tmpData, forKey: "selfMuseum")
                self.defaults.synchronize()
                self.delegate?.getSelfMuseumReady!()
            }else{
                if(self.defaults.valueForKey("selfMuseum") != nil){
                    globalHiwuUser.selfMuseum = JSON(NSKeyedUnarchiver.unarchiveObjectWithData(self.defaults.objectForKey("selfMuseum") as! NSData)!)
                    print(self.delegate?.getSelfMuseumReady!())
                     self.delegate?.getSelfMuseumReady!()
                }else{
                    self.delegate?.getSelfMuseumFailed!()
                }
            }
        }
    }
    
    func getTodayInfo(){
        let url = ApiManager.getTodayPublicView
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
            if(response.result.error == nil){
                globalHiwuUser.todayMuseum = JSON(response.result.value!)
                let tmpData:NSData = NSKeyedArchiver.archivedDataWithRootObject(response.result.value!)
                self.defaults.setObject(tmpData, forKey: "todayMuseum")
                self.defaults.synchronize()
                self.delegate?.getTodayInfoReady!()
            }else{
                if(self.defaults.valueForKey("todayMuseum") != nil){
                    globalHiwuUser.todayMuseum = JSON(NSKeyedUnarchiver.unarchiveObjectWithData(self.defaults.objectForKey("todayMuseum") as! NSData)!)
                    self.delegate?.getTodayInfoReady!()
                    
                }else{
                    self.delegate?.getTodayInfoFailed!()
                }
            }
        
        }
        
    }
    
    func getSelfItemInfo(itemId: Int){
        let url = ApiManager.getSelfItem1 + String(itemId) + ApiManager.getSelfItem2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
            if(response.result.value != nil){
                globalHiwuUser.item = JSON(response.result.value!)
                self.delegate?.getSelfItemInfoReady!()
            }else{
                self.delegate?.getSelfItemInfoFailed!()
            }
        }
        
    }
    
    func getPublicItemInfo(itemId: Int){
        let url = ApiManager.getPublicItem1 + String(itemId) + ApiManager.getPublicItem2 + globalHiwuUser.hiwuToken
        print(url)
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
            if(response.result.value != nil){
                globalHiwuUser.item = JSON(response.result.value!)
                self.delegate?.getPublicItemInfoReady!()
            }else{
                self.delegate?.getPublicItemInfoFailed!()
            }
        }
        
    }
    
    func postItem(galleryId:Int,itemName:String,itemDescription:String,year:Int,city:String,dataUrl:NSURL,isPublic:Bool){
        let postItemUrl = ApiManager.postItem1 + String(galleryId) + ApiManager.postItem2 + globalHiwuUser.hiwuToken
        Alamofire.request(.POST, postItemUrl, parameters: [
            "name": itemName,
            "description": itemDescription,
            "date_y": year,
            "date_m": 0,
            "date_d": 0,
            "city": city,
            "public": isPublic
            ]).responseJSON{response in
            if(response.result.value != nil){
                self.postPhotoToItem(JSON(response.result.value!)["id"].int!, dataUrl: dataUrl)
            }
        }
        
    }
    
    func postPhotoToItem(itemId:Int,dataUrl:NSURL){
        let postPhotoUrl = ApiManager.postItemPhoto1 + String(itemId) + ApiManager.postItemPhoto2 + globalHiwuUser.hiwuToken
        Alamofire.upload(.POST, postPhotoUrl,multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(fileURL: dataUrl, name: "data")
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if(response.result.value != nil){
                            self.delegate?.postItemReady!()
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    func deleteItem(itemId:Int,complete:()?){
        let deleteUrl = ApiManager.deleteItem1 + String(itemId) + ApiManager.deleteItem2 + globalHiwuUser.hiwuToken
        Alamofire.request(.DELETE, NSURL(string: deleteUrl)!).responseJSON{response in
            if(response.result.value != nil){
                self.delegate?.deleteItemReady!()
            }else{
                self.delegate?.deleteItemFailed!()
            }
        }
        
    }
    
    func postGallery(name:String!,despcription:String!,isPublic:Bool!,userId:Int!){
        let url = ApiManager.postGallery1 + String(userId) + ApiManager.postGallery2 + globalHiwuUser.hiwuToken
        Alamofire.request(.POST, url, parameters: ["name":name,"description":despcription,"public":isPublic]).responseJSON{response in
            if(response.result.value != nil)
            {
                self.delegate?.postGalleryReady!()
                
            }else{
                self.delegate?.postGalleryFailed!()
            }
        }
        
    }
    
    func getGalleryItems(id:Int){
        let url = ApiManager.getGalleryItems1 + String(id) + ApiManager.getGalleryItems2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, url).responseJSON{response in
            if(response.result.value != nil){
                self.delegate?.getGalleryItemsReady!()
            }else{
                self.delegate?.getGalleryItemsFailed!()
            }
        }
    }
    
    func putLike(userId: Int,itemId: Int){
        let url = ApiManager.putLike1 + String(userId) + ApiManager.putLike2 + String(itemId) + ApiManager.putLike3 + globalHiwuUser.hiwuToken
        print("put like")
        Alamofire.request(.PUT,url).responseJSON{response in
            if(response.result.value != nil && response.result.error == nil){
                self.delegate?.putLikeReady!()
            }else{
                print(response.result.error)
                self.delegate?.putLikeFailed!()
            }
        }
    }
    
    func deleteLike(userId: Int,itemId: Int,beReady:()?,beFailed:()?){
        let url = ApiManager.putLike1 + String(userId) + ApiManager.putLike2 + String(itemId) + ApiManager.putLike3 + globalHiwuUser.hiwuToken
        Alamofire.request(.DELETE,url).responseJSON{response in
            if(response.result.value != nil){
                self.delegate?.deleteLikeReady!()
            }else{
                self.delegate?.deleteLikeFailed!()
            }
        }
    }
    
    func postComment(toUserId:Int,itemId:Int,content:String,ready:()){
        let url = ApiManager.postComment1 + String(itemId) + ApiManager.postComment2 + globalHiwuUser.hiwuToken
        Alamofire.request(.POST, url, parameters: ["content": content,
            "toId": toUserId]).responseJSON{response in
                if(response.result.value != nil){
                    self.delegate?.postCommentReady!()
                }else{
                    self.delegate?.postCommentFailed!()
                }
        }
        
    }
    
    func deleteComment(commentId:Int,beReady:()?,beFailed:()?){
        let url = ApiManager.deleteComment1 + String(commentId) + ApiManager.deleteComment2 + globalHiwuUser.hiwuToken
        Alamofire.request(.DELETE, url).responseJSON{response in
            if(response.result.value != nil){
                self.delegate?.deleteCommentReady!()
            }else{
                self.delegate?.deleteCommentFailed!()
            }
        }
    }
    
    func weixinLogin(){
        globalHiwuUser.loginState = 0
        if(globalHiwuUser.wxcode != ""){
            let url = ApiManager.wxLogin1 + wxAPPID + ApiManager.wxLogin2 + globalHiwuUser.wxcode
            Alamofire.request(.POST, url).responseJSON{response in
                if(response.result.error == nil){
                    if(response.result.value != nil){
                        let userInfo = JSON(response.result.value!)
                        if(userInfo["error"] == nil){
                            globalHiwuUser.hiwuToken = userInfo["id"].string!
                            self.defaults.setValue((userInfo["id"]).string!,
                                forKey: "token")
                            self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!).timeIntervalSince1970, forKey: "deadline")
                            self.defaults.setDouble(NSDate(timeIntervalSinceNow: (userInfo["ttl"]).double!/2).timeIntervalSince1970, forKey: "freshline")
                            self.defaults.setInteger((userInfo["userId"]).int!, forKey: "userId")
                            self.defaults.synchronize()
                            self.delegate?.weixinLoginReady!()
                        }
                    }
                }
            }
        }
    }

    
}

    

