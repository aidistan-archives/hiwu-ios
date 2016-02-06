//
//  TodayVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class TodayVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,LoginProtocol,GetUserInfoReadyProtocol,GetSelfMuseumReadyProtocol {
    
    var contactor = ContactWithServer()
    var isLoading = false
    
    @IBOutlet weak var refreshing: UIActivityIndicatorView!
    @IBOutlet weak var todayGalleryDisplay: UITableView!

    @IBAction func getAllTodays(sender: UIButton) {
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("AllTodaysVC") as! AllTodaysVC
        self.navigationController?.pushViewController(next, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        todayGalleryDisplay.dataSource = self
        todayGalleryDisplay.delegate = self
        todayGalleryDisplay.estimatedRowHeight = 100
        todayGalleryDisplay.rowHeight = UITableViewAutomaticDimension
        todayGalleryDisplay.reloadData()
        self.contactor.selfMuseumReady = self
        self.contactor.userInfoReady = self
        self.contactor.loginSuccess = self
    }
    @IBOutlet weak var selfmuseum: UIButton!
    override  func viewWillAppear(animated: Bool) {
        self.selfmuseum.enabled = true
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
                debugPrint("not fresh")
                self.navigationController!.performSegueWithIdentifier("ToSelfMuseumSegue", sender: self)
                self.contactor.getNewTokenWithDefaults()
                print("i'm here")
            }else{
            self.contactor.getUserInfoFirst()
            print("fresh")
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
            layout.itemSize = CGSizeMake((width - 20)/3-1, (width - 20)/3-1)
            layout.minimumLineSpacing = 1
            layout.minimumInteritemSpacing = 1
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
    
    func getSelfMuseumFailed(){
    }
    
    func getUserInfoReady(){
        
        self.contactor.getSelfMuseum(nil)
    }
    func getUserInfoFailed(){
        print("get user info failed")
        }
    
    func getSelfMuseunReady() {
        print("get self museum ready in today")
        let selfMuseum = self.storyboard?.instantiateViewControllerWithIdentifier("SelfMuseum") as! SelfMuseumVC
        
        self.navigationController?.pushViewController(selfMuseum, animated: true)
    }
    
    func getSelfMuseunFailed() {
        print("get self museum failed")
    }
    


}
