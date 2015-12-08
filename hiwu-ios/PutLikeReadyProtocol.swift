//
//  PutLikeReadyProtocol.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/12/7.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import Foundation
public protocol PutLikeReadyProtocol{
    func putLikeReady()
    func putLikeFailed()
    func deleteLikeReady()
    func deleteLikeFailed()
}