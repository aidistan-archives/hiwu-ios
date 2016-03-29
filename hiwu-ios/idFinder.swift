//
//  galleryFinder.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/12/3.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import Foundation
import SwiftyJSON

class idFinder{
    static func findFromGallery(id:Int,gallery:JSON) -> JSON?{
        for(var i = 0;i<gallery.count;i += 1){
            if(gallery[i]["id"].int! == id){
                return gallery[i]
            }
        }
        return nil
    }

    
}
