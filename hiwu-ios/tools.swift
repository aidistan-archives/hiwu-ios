//
//  tools.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/4/5.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import Foundation

class tools{
    static func resizeImage(img:UIImage,height:CGFloat)->UIImage{
        let scale = height/img.size.height
        UIGraphicsBeginImageContext(CGSizeMake(img.size.width * scale, img.size.height * scale))
        img.drawInRect(CGRect(x: 0, y: 0, width: img.size.width * scale, height: img.size.height * scale))
        let scaledImg = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImg
    }
}