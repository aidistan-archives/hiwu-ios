//
//  NotificationVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/3/17.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class NotificationVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
}
