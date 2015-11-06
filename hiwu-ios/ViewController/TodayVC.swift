//
//  TodayVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/20.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class TodayVC: UIViewController,UITableViewDataSource,UITableViewDelegate,LoginProtocol,GetUserInfoReadyProtocol,GetSelfMuseumReadyProtocol {
    var contactor:ContactWithServer?
    
    @IBOutlet weak var todayGalleryDisplay: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        todayGalleryDisplay.dataSource = self
        todayGalleryDisplay.delegate = self
        todayGalleryDisplay.reloadData()
    }
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func clear(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(0, forKey: "deadline")
    }
    
    @IBAction func enterToSelfMuseum(sender: UIButton) {
        self.contactor = ContactWithServer()
        self.contactor!.loginSuccess = self
        self.contactor!.selfMuseumReady = self
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
                ContactWithServer.getNewTokenWithDefaults()
                print("i'm here")
            
            }else{
                self.contactor?.getUserInfoFirst()
            }
        
            }
    
    func timeOut(){
        let alert1 = UIAlertController(title: "timeout", message: "请检查网络", preferredStyle: UIAlertControllerStyle.Alert)
        alert1.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.navigationController?.presentViewController(alert1, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return globalHiwuUser.todayMuseum!.count+1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.row == 0){
            return 50
        }else{
            return 450
            
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("TodayTitle")! as UITableViewCell
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("TodayGalleryCell")! as UITableViewCell
            let collection = cell.viewWithTag(1) as! TodayGalleryCT
            collection.location = indexPath.row-1
            collection.superVC = self
            collection.delegate = collection
            collection.dataSource = collection
            collection.reloadData()
            return cell
        }
        
    }
    
    func skipToNextAfterSuccess(){
        
    
    }
    
    func loginFailed(){}
    
    func didGetSelfMuseum(){
        self.navigationController!.performSegueWithIdentifier("ToSelfMuseumSegue", sender: self)
    }
    
    func getSelfMuseumFailed(){
    }
    func getUserInfoReady(){
        self.contactor?.getSelfMuseum()
    }
    func getUserInfoFailed(){}
    func getSelfMuseunReady() {
        
    }
    func getSelfMuseunFailed() {
        
    }

}
