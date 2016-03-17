//
//  ServerContactorDelegates.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/3/3.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

@objc public protocol ServerContactorDelegates{
    optional func getUserInfoReady()
    optional func getUserInfoFailed()
    optional func getUserInfoFirstReady()
    optional func getUserInfoFirstFailed()
    optional func getTodayInfoReady()
    optional func getTodayInfoFailed()
    optional func getSelfItemInfoReady()
    optional func getSelfItemInfoFailed()
    optional func getPublicItemInfoReady()
    optional func getPublicItemInfoFailed()
    optional func postItemReady()
    optional func postItemFailed()
    optional func postPhotoToItemReady()
    optional func postPhotoToItemFailed()
    optional func deleteItemReady()
    optional func deleteItemFailed()
    optional func postGalleryReady()
    optional func postGalleryFailed()
    optional func getGalleryItemsReady()
    optional func getGalleryItemsFailed()
    optional func putLikeReady()
    optional func putLikeFailed()
    optional func deleteLikeReady()
    optional func deleteLikeFailed()
    optional func postCommentReady()
    optional func postCommentFailed()
    optional func deleteCommentReady()
    optional func deleteCommentFailed()
    optional func getSelfMuseumReady()
    optional func getSelfMuseumFailed()
    optional func weixinLoginReady()
    optional func weixinLoginFailed()
//    optional func Ready()
//    optional func Failed()
}
