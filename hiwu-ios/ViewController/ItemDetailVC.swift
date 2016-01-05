//
//  ItemDetailVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/31.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import Alamofire

class ItemDetailVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,GetItemInfoReadyProtocol,PutLikeReadyProtocol{
    
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    @IBOutlet weak var addComment: UITextView!
    @IBOutlet weak var itemDetailList: UITableView!
    var itemId:Int?
    var item:JSON?
    var isMine:Bool?
    let contactor = ContactWithServer()
    var cells = 0
    var toUserId:Int?
    var isCommment = false
    @IBOutlet weak var tipToAddComment: UILabel!

    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func ensureComment(sender: UIButton) {
        if(self.addComment.text == ""){
            let alert = UIAlertController(title: "请求失败", message: "内容为空", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "知道了", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            self.postComment(self.toUserId, itemId: self.itemId!, content: self.addComment.text)
            self.waiting.startAnimating()
        }
    }
    @IBOutlet weak var ensureCommentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getItemInfo()
        self.waiting.startAnimating()
        self.contactor.itemInfoReady = self
        self.contactor.putLikeReady = self
        self.navigationController?.fd_prefersNavigationBarHidden = true
        self.addComment.delegate = self
        self.itemDetailList.estimatedRowHeight = 60
        self.itemDetailList.rowHeight = UITableViewAutomaticDimension
        itemDetailList.dataSource = self
        itemDetailList.delegate = self
        itemDetailList.reloadData()
        let gest = UITapGestureRecognizer(target: self, action: "endTheEditingOfTextView")
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cells
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemImage")
                let itemImage = cell?.viewWithTag(1) as! UIImageView
                if(self.item!["photos"][0]["url"].string! == ""){
                    itemImage.image = UIImage(named: "add")
                }else{
                    itemImage.kf_setImageWithURL(NSURL(string: self.item!["photos"][0]["url"].string!)!)
                }
                let itemTime = cell?.viewWithTag(2) as! UILabel
                itemTime.text = String(self.item!["date_y"].int!)
                let itemCity = cell?.viewWithTag(3) as! UILabel
                itemCity.text = self.item!["city"].string
                let itemOwner = cell?.viewWithTag(4) as! UIImageView
                let userAvatar = self.item!["hiwuUser"]["avatar"].string!
                itemOwner.kf_setImageWithURL(NSURL(string:userAvatar)!)
            return cell!
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemDescription")
                let itemName = cell?.viewWithTag(1) as! UILabel
                itemName.text = self.item!["name"].string
                let itemDescription = cell?.viewWithTag(2) as! UILabel
                itemDescription.text = self.item!["description"].string
                let likeButton = cell?.viewWithTag(3) as! UIButton
                if(self.item!["liked"].boolValue){
                    likeButton.imageView?.image = UIImage(named: "iconfont-liked")
                    likeButton.addTarget(self, action: "deleteLike", forControlEvents: UIControlEvents.TouchUpInside)
                }else{
                    likeButton.imageView?.image = UIImage(named: "iconfont-like")
                    likeButton.addTarget(self, action: "putLike", forControlEvents: UIControlEvents.TouchUpInside)
                }
                let likeNum = cell?.viewWithTag(4) as! UILabel
                likeNum.text = String(self.item!["likes"].int!)
                let addComment = cell?.viewWithTag(5) as! UIButton
                addComment.addTarget(self, action: "toAddComment", forControlEvents: UIControlEvents.TouchUpInside)
                let commentNum = cell?.viewWithTag(6) as! UILabel
                commentNum.text = String(self.item!["comments"].count)
                return cell!
            default :
                let cell = tableView.dequeueReusableCellWithIdentifier("Comments")
                let comment = cell?.viewWithTag(2) as! UILabel
                var toWhom = ""
                if(self.item!["comments"][indexPath.row-2]["toId"].int != nil && self.item!["comments"][indexPath.row-2]["toId"].int != 0){
                    toWhom = " 回复 " + self.item!["comments"][indexPath.row-2]["toUser"]["nickname"].string!
                }
                comment.text = self.item!["comments"][indexPath.row-2]["hiwuUser"]["nickname"].string! + toWhom + " : " + self.item!["comments"][indexPath.row-2]["content"].string!
                return cell!
        }
    }
    
    func toAddComment(){
        self.addComment.becomeFirstResponder()
        UIView.animateWithDuration(1, animations: {void in
            self.addComment.alpha = 1
            self.ensureCommentButton.alpha = 1
            self.tipToAddComment.alpha = 1
            self.itemDetailList.userInteractionEnabled = false
            self.itemDetailList.alpha = 0.4
            self.view.backgroundColor = UIColor.blackColor()
        })
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        
    }
    
    func textViewDidEndEditing(textView: UITextView){
        textView.resignFirstResponder()
    }
    
    func endTheEditingOfTextView(){
        self.addComment.endEditing(true)
        UIView.animateWithDuration(0.6, animations: {void in
            
            self.tipToAddComment.alpha = 0
            self.itemDetailList.alpha = 1
            self.itemDetailList.userInteractionEnabled = true
            self.addComment.alpha = 0
            self.ensureCommentButton.alpha = 0
            self.view.backgroundColor = UIColor.whiteColor()
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func putLike(){
        contactor.putLike(globalHiwuUser.userId, itemId: self.itemId!)
        self.getItemInfo()
    }
    
    func deleteLike(){
        contactor.deleteLike(globalHiwuUser.userId, itemId: self.itemId!, beReady: self.getItemInfo(), beFailed:self.networkError())
    }
    
    func getItemInfo(){
        self.waiting.startAnimating()
        if(isMine!){
            contactor.getSelfItemInfo(self.itemId!)
        }else{
            contactor.getPublicItemInfo(self.itemId!)
        }
    }
    
    func getItemInfoFailed() {
         self.waiting.stopAnimating()
    }
    
    func getItemInfoReady() {
        self.item = globalHiwuUser.item
        cells = 2 + self.item!["comments"].count
        self.waiting.stopAnimating()
        self.itemDetailList.reloadData()
        if(isCommment == true){
            self.itemDetailList.scrollToRowAtIndexPath(NSIndexPath(forRow: self.cells - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }else{
             self.itemDetailList.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    func networkError(){
        self.waiting.stopAnimating()
        let alert = UIAlertController(title: "请求失败", message: "请检查你的网络", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "知道了", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func putLikeReady(){
        self.getItemInfo()
    }
    func putLikeFailed(){
        self.networkError()
    }
    func deleteLikeReady(){
        self.getItemInfo()
    }
    func deleteLikeFailed(){
        self.networkError()
    }
    
    func postComment(toUserId:Int?,itemId:Int,content:String){
        let url = ApiManager.postComment1 + String(itemId) + ApiManager.postComment2 + globalHiwuUser.hiwuToken
        self.tipToAddComment.text = "在这里添加评论"
        if(toUserId != nil){
            Alamofire.request(.POST, url, parameters: ["content": content,"toId": toUserId!]).responseJSON{response in
                self.waiting.stopAnimating()
                if(response.result.error != nil){
                    print(response.result.error)
                    self.networkError()
                }else{
                    self.addComment.text = ""
                    self.getItemInfo()
                    print(self.cells)
                    self.isCommment = true
                }
            }
        }else{
            Alamofire.request(.POST, url, parameters: ["content": content]).responseJSON{response in
                self.waiting.stopAnimating()
                if(response.result.error != nil){
                    print(response.result.error)
                    self.networkError()
                }else{
                    self.addComment.text = ""
                    self.getItemInfo()
                    self.itemDetailList.scrollToNearestSelectedRowAtScrollPosition(UITableViewScrollPosition.Bottom, animated: true)
                }
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row >= 2){
            self.toUserId = self.item!["comments"][indexPath.row - 2]["userId"].int!
            self.tipToAddComment.text = "回复给" + self.item!["comments"][indexPath.row - 2]["hiwuUser"]["nickname"].string! + " :"
            self.toAddComment()
            self.itemDetailList.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }

    
    

}
