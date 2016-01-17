//
//  ApiManager.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import Foundation

class ApiManager{
    static let simpleLogin = "http://hiwu.ren:3010/api/HiwuUsers/simpleLogin?"
    static let getSelfUserInfo1 = "http://hiwu.ren:3010/api/HiwuUsers/"
    static let getSelfUserInfo2 = "?access_token="
    static let getTodayPublicView = "http://hiwu.ren:3010/api/SelectedGalleries/publicView"
    static let getAllSelfGallery1_2 = "http://hiwu.ren:3010/api/HiwuUsers/"
    static let getAllSelfGallery2_2 = "?filter=%7B%22include%22%3A%7B%22galleries%22%3A%7B%22items%22%3A%5B%22photos%22%2C%22comments%22%5D%7D%7D%7D&access_token="
    static let getSelfItem1 = "http://hiwu.ren:3010/api/Items/"
    static let getSelfItem2 = "?filter=%7B%22include%22%3A%5B%22photos%22%2C%22likers%22%2C%22hiwuUser%22%2C%7B%22comments%22%3A%22hiwuUser%22%7D%5D%7D&access_token="
    static let getPublicItem1 = "http://hiwu.ren:3010/api/Items/"
    static let getPublicItem2 = "/publicView?access_token="
    static let postItem1 = "http://hiwu.ren:3010/api/Galleries/"
    static let postItem2 = "/items?access_token="
    static let postItemPhoto1 = "http://hiwu.ren:3010/api/Items/"
    static let postItemPhoto2 = "/photos?access_token="
    static let deleteItem1 = "http://hiwu.ren:3010/api/Items/"
    static let deleteItem2 = "?access_token="
    static let postGallery1 = "http://hiwu.ren:3010/api/HiwuUsers/"
    static let postGallery2 = "/galleries?access_token="
    static let getGalleryItems1 = "http://hiwu.ren:3010/api/Galleries/"
    static let getGalleryItems2 = "?filter=%7B%22include%22%3A%7B%22items%22%3A%5B%22photos%22%5D%7D%7D&access_token="
    static let putLike1 = "http://hiwu.ren:3010/api/HiwuUsers/"
    static let putLike2 = "/likes/rel/"
    static let putLike3 = "?access_token="
    static let postComment1 = "http://hiwu.ren:3010/api/Items/"
    static let postComment2 = "/comments?access_token="
    static let deleteComment1 = "http://hiwu.ren:3010/api/Comments/"
    static let deleteComment2 = "?access_token="
}
