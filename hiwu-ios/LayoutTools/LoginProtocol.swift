//
//  LoginProtocol.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/21.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

//  登录回调函数，登陆成功后进行跳转，失败进行提示

import Foundation

public protocol LoginProtocol{

    func skipToNextAfterSuccess()
    
    func loginFailed()
    
    func didGetSelfMuseum()
    
    func getSelfMuseumFailed()
    
}
