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
    static let getTodayPublicView = "http://hiwu.ren:3010/api/Today/publicView"
    static let getAllSelfGallery1_2 = "http://hiwu.ren:3010/api/HiwuUsers/"
    static let getAllSelfGallery2_2 = "?filter=%7B%22include%22%3A%7B%22galleries%22%3A%7B%22items%22%3A%5B%22photos%22%5D%7D%7D%7D&access_token="
    static let getItemPublic1 = "http://hiwu.ren:3010/api/Items/"
    static let getItemPublic2 = "/publicView?access_token="
}
