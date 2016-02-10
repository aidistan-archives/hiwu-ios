//
//  TodayVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class TodayVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,LoginProtocol,GetUserInfoReadyProtocol{
    
    var contactor = ContactWithServer()
    let notification = NSNotificationCenter.defaultCenter()
    var isLoading = false
    
    @IBOutlet weak var refreshing: UIActivityIndicatorView!
    @IBOutlet weak var todayGalleryDisplay: UITableView!

    @IBAction func getAllTodays(sender: UIButton) {
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("AllTodaysVC") as! AllTodaysVC
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bg = UIImage(named: "bg")
        bg?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: UIImageResizingMode.Tile)
        self.view.backgroundColor = UIColor(patternImage: bg!)
        todayGalleryDisplay.dataSource = self
        todayGalleryDisplay.delegate = self
        todayGalleryDisplay.estimatedRowHeight = 100
        todayGalleryDisplay.rowHeight = UITableViewAutomaticDimension
        todayGalleryDisplay.reloadData()
        self.contactor.userInfoReady = self
        self.contactor.loginSuccess = self
    }
    
    @IBOutlet weak var selfmuseum: UIButton!
    
    override  func viewWillAppear(animated: Bool) {
        self.notification.addObserver(self, selector: "getSelfMuseumReady", name: "getSelfMuseumReady", object: nil)
        self.notification.addObserver(self, selector: "getSelfMuseumFailed", name: "getSelfMuseumFailed", object: nil)
        self.selfmuseum.enabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.notification.removeObserver(self)
    }
    
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func enterToSelfMuseum(sender: UIButton) {
        sender.enabled = false
        print("enter to selfmuseum")
        let nowDate = NSDate(timeIntervalSinceNow: 0)
        let defaults = NSUserDefaults.standardUserDefaults()
        let deadline = defaults.doubleForKey("deadline")
        let freshline = defaults.doubleForKey("freshline")
        if((deadline == 0)||(freshline == 0||nowDate.timeIntervalSince1970 > deadline)){
            let login = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
            login.superVC = self
            self.navigationController?.pushViewController(login, animated: true)
            
        }else if(nowDate.timeIntervalSince1970 > freshline){
            let selfMuseum = self.storyboard?.instantiateViewControllerWithIdentifier("SelfMuseum") as! SelfMuseumVC
            
            self.navigationController?.pushViewController(selfMuseum, animated: true)
            
//                self.contactor.getNewTokenWithDefaults()
            }else{
            self.contactor.getUserInfoFirst()
            }
        
    }
    
    func timeOut(){
        let alert1 = UIAlertController(title: "timeout", message: "请检查网络", preferredStyle: UIAlertControllerStyle.Alert)
        alert1.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.navigationController?.presentViewController(alert1, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(globalHiwuUser.todayMuseum!.count <= 6){
            return globalHiwuUser.todayMuseum!.count + 1
        }else{
            return 7
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 130
        }else{
            let num = globalHiwuUser.todayMuseum![indexPath.row]["gallery"]["items"].count
            if(num>=7){
                return ((tableView.frame.width * 7/6) + 20)
            }else if(num>=4 && num<=6){
                return 380
            }else if(num>=1 && num<=3 ){
                return 320
            }else{
                return 160
            }

        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("TodayTitle")! as UITableViewCell
            let museumSum = cell.viewWithTag(3) as! UITextField
            museumSum.text = "共有 " + String(globalHiwuUser.todayMuseum!.count) + " 个精品博物馆"
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("TodayGalleryCell")! as UITableViewCell
            let collection = cell.viewWithTag(1) as! TodayGalleryCT
            let width = tableView.frame.width
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSizeMake((width - 16)/3, (width - 16)/3)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            layout.headerReferenceSize = CGSizeMake(width, width/6)
            layout.footerReferenceSize = CGSizeMake(0, 0)
            collection.collectionViewLayout = layout
            collection.location = indexPath.row
            collection.superVC = self
            collection.delegate = collection
            collection.dataSource = collection
            collection.reloadData()
            return cell
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("sender")
        if(((-scrollView.contentOffset.y > 100))&&(self.isLoading == false)){
            self.isLoading = true
            self.refreshing.startAnimating()
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue,{() in
                sleep(2)
                let mainQueue = dispatch_get_main_queue()
                dispatch_async(mainQueue, {
                    self.isLoading = false
                    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    self.refreshing.stopAnimating()
                
                })
            })
        }
    }

    
    func skipToNextAfterSuccess(){
        
    
    }
    
    func loginFailed(){}
    
    func didGetSelfMuseum(){
        
    }
    
    func getUserInfoReady(){
        print("ok")
        self.contactor.getSelfMuseum()
        
    }
    func getUserInfoFailed(){
        print("get user info failed")
        }
    
    func getSelfMuseumReady() {
        print("get self museum ready in today")
        self.notification.removeObserver(self, name: "getSelfMuseumReady", object: nil)
        let selfMuseum = self.storyboard?.instantiateViewControllerWithIdentifier("SelfMuseum") as! SelfMuseumVC
        
        self.navigationController?.pushViewController(selfMuseum, animated: true)
    }
    
    func getSelfMuseumFailed() {
        print("get self museum failed")
        self.notification.removeObserver(self, name: "getSelfMuseumFailed", object: nil)
    }
    


}
