//
//  UserModel.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserModel: AnyObject{
    var hiwuToken:String = ""
    var userId:Int = 0
    var userName = ""
    var selfMuseum :JSON?
    var todayMuseum :JSON?
    var item :JSON?
    init(){
        
    }
    

}
