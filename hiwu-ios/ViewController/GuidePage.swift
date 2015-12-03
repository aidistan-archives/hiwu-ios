//
//  GuidePage.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/12/2.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class GuidePage: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var pageTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
