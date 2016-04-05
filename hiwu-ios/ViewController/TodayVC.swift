//
//  TodayVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TodayVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,ServerContactorDelegates{
    
    var contactor = ContactWithServer()
    var isLoading = false
    let defaults = NSUserDefaults.standardUserDefaults()
    let notification = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var refreshing: UIActivityIndicatorView!
    @IBOutlet weak var todayGalleryDisplay: UITableView!

    @IBAction func getAllTodays(sender: UIButton) {
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("AllTodaysVC") as! AllTodaysVC
        self.navigationController?.pushViewController(next, animated: true)
    }
    @IBOutlet weak var selfmuseum: UIButton!
    
    override func viewWillAppear(animated: Bool) {
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
        self.notification.addObserver(self, selector: #selector(TodayVC.weixinValidationSuccess), name: "weixinValidationOK", object: nil)
        self.notification.addObserver(self, selector: #selector(TodayVC.weiboValidationSuccess), name: "weiboValidationOK", object: nil)
        self.contactor.delegate = self
    }
    

    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func enterToSelfMuseum(sender: UIButton) {
        print("enter to selfmuseum")
        let nowDate = NSDate(timeIntervalSinceNow: 0)
        let deadline = self.defaults.doubleForKey("deadline")
        let freshline = self.defaults.doubleForKey("freshline")
        if((deadline == 0)||(freshline == 0||nowDate.timeIntervalSince1970 > deadline)){
//            无缓存用户信息
//            let login = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
//            login.superVC = self
//            self.navigationController?.pushViewController(login, animated: true)
            let desc = JMActionSheetDescription()
            let collectionItem = JMActionSheetCollectionItem()
            let item1 = JMCollectionItem()
            item1.actionName = "微信登录"
            item1.actionImage = UIImage(named: "logwechat")
            item1.actionImageContentMode = UIViewContentMode.ScaleAspectFit
            let item2 = JMCollectionItem()
            item2.actionName = "微博登录"
            item2.actionImage = UIImage(named: "logsina")
            item2.actionImageContentMode = UIViewContentMode.ScaleAspectFit
            if(WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi()){
                collectionItem.elements = [item1,item2]
            }else{
                collectionItem.elements = [item2]
            }
            collectionItem.collectionActionBlock = {id in
                let actionName = id.actionName
                switch(actionName){
                case "微信登录":
                    self.weixin()
                default:
                    self.weibo()
                }
                
            }
            let cancel = JMActionSheetItem()
            cancel.title = "取消"
            cancel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            desc.cancelItem = cancel
            desc.items = [collectionItem]
            JMActionSheet.showActionSheetDescription(desc, inViewController: self)
        }else if(nowDate.timeIntervalSince1970 > freshline){
//            not fresh
            let selfMuseum = self.storyboard?.instantiateViewControllerWithIdentifier("SelfMuseum") as! SelfMuseumVC
            self.navigationController?.pushViewController(selfMuseum, animated: true)
            
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
            return globalHiwuUser.todayMuseum!.count + 2
        }else{
            return 8
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 130
        }else if(indexPath.row == tableView.numberOfRowsInSection(0) - 1){
            return 71
        }else{
            let num = globalHiwuUser.todayMuseum![indexPath.row-1]["gallery"]["items"].count
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
            
        }else if(indexPath.row == tableView.numberOfRowsInSection(0) - 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("seeMore")
            return cell!
            
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
            collection.location = indexPath.row - 1
            collection.superVC = self
            collection.delegate = collection
            collection.dataSource = collection
            collection.reloadData()
            return cell
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
    
    func getUserInfoFirstReady(){
        self.loginReady()
        
    }
    
    func getUserInfoFirstFailed(){
        print("get user info failed")
        }
    
    func weixin() {
        //微信的的登录状态码设为1，微博为2，默认为0
        globalHiwuUser.loginState = 1
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo";
        req.state = "123"
        WXApi.sendReq(req);
        
    }
    
    func weibo() {
        globalHiwuUser.loginState = 2
        let req = WBAuthorizeRequest()
        req.scope = "all"
        req.redirectURI = kRedirectURI
        WeiboSDK.sendRequest(req)
    }
    
    func weixinValidationSuccess(){
        contactor.weixinLogin()
        
    }
    
    func weiboValidationSuccess(){
        contactor.weiboLogin({() in
            self.loginReady()
        })
        
    }
    
    func weixinLoginReady() {
        self.loginReady()
    }
    
    func loginReady(){
        let selfMuseum = self.storyboard?.instantiateViewControllerWithIdentifier("SelfMuseum") as! SelfMuseumVC
        
        self.navigationController?.pushViewController(selfMuseum, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }


}
