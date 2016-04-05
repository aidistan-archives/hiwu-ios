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

class ItemDetailVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,ServerContactorDelegates{
    
    var itemId:Int?
    var item:JSON?
    var isMine:Bool?
    let contactor = ContactWithServer()
    var cells = 0
    var toUserId:Int?
    var isCommment = false
    var liked = false
    var weixinScene = 0
    var weiboScene = 0
    var tmpImage = UIImage()
    
    @IBAction func more(sender: UIButton) {
        
        let desc = JMActionSheetDescription()
        let collectionItem = JMActionSheetCollectionItem()
        let item1 = JMCollectionItem()
        item1.actionName = "新浪微博"
        item1.actionImage = UIImage(named: "sina")
        item1.actionImageContentMode = UIViewContentMode.Center
        let item2 = JMCollectionItem()
        item2.actionName = "微信好友"
        item2.actionImage = UIImage(named: "wechat")
        item2.actionImageContentMode = UIViewContentMode.ScaleAspectFit
        let item3 = JMCollectionItem()
        item3.actionName = "微信朋友圈"
        item3.actionImage = UIImage(named: "moment")
        item3.actionImageContentMode = UIViewContentMode.ScaleAspectFit
        let item4 = JMCollectionItem()
        item4.actionName = "复制链接"
        item4.actionImage = UIImage(named: "edit")
        item4.actionImageContentMode = UIViewContentMode.ScaleAspectFit
        let item5 = JMCollectionItem()
        item5.actionName = "编辑"
        item5.actionImage = UIImage(named: "edit")
        item5.actionImageContentMode = UIViewContentMode.ScaleAspectFit
        let item6 = JMCollectionItem()
        item6.actionName = "删除"
        item6.actionImage = UIImage(named: "delete")
        item6.actionImageContentMode = UIViewContentMode.ScaleAspectFit
        if(WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() && WeiboSDK.isWeiboAppInstalled()){
            collectionItem.elements = [item1,item2,item3,item4]
        }else if(WeiboSDK.isWeiboAppInstalled()){
            collectionItem.elements = [item1,item4]
        }else if(WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi()){
            collectionItem.elements = [item2,item3,item4]
        }else{
            collectionItem.elements = [item4]
        }
        collectionItem.collectionActionBlock = {id in
            let actionName = id.actionName
            switch(actionName){
            case "新浪微博":
                self.weiboShare()
            case "微信好友":
                self.weixinScene = 0
                self.weixinShare()
            case "微信朋友圈":
                self.weixinScene = 1
                self.weixinShare()
            case "复制链接":
                let pasteboard = UIPasteboard.generalPasteboard()
                pasteboard.string = "http://palace.server.hiwu.ren/items/" + String(self.item!["id"].int!)
                let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
                hud.textLabel.text = "复制成功"
                hud.position = JGProgressHUDPosition.BottomCenter
                hud.showInView(self.view)
                hud.dismissAfterDelay(0.3)
            case "编辑":
                self.weixinScene = 1
                self.weixinShare()
            default:
                self.weixinShare()
            }
            
        }
        let cancel = JMActionSheetItem()
        cancel.title = "取消"
        cancel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        desc.cancelItem = cancel
        desc.items = [collectionItem]
        JMActionSheet.showActionSheetDescription(desc, inViewController: self)
    }
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    @IBOutlet weak var addComment: UITextView!
    @IBOutlet weak var itemDetailList: UITableView!
    @IBOutlet weak var tipToAddComment: UILabel!

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
        print(self.itemId)
        self.getItemInfo()
        self.waiting.startAnimating()
        self.contactor.delegate = self
        self.addComment.delegate = self
        self.itemDetailList.dataSource = self
        self.itemDetailList.delegate = self
        self.itemDetailList.estimatedRowHeight = 60
        self.itemDetailList.rowHeight = UITableViewAutomaticDimension
        let gest = UITapGestureRecognizer(target: self, action: #selector(ItemDetailVC.endTheEditingOfTextView))
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        print("item info")
        print(self.item)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cells
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemImage")
                let itemImage = cell?.viewWithTag(1) as! UIImageView
                if(self.item!["photos"][0]["url"] == nil){
                    itemImage.image = UIImage(named: "bg")
                     self.waiting.stopAnimating()
                }else{
//                    itemImage.kf_setImageWithURL(NSURL(string: self.item!["photos"][0]["url"].string!)!)
                    itemImage.kf_setImageWithURL(NSURL(string: self.item!["photos"][0]["url"].string!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (_) in
                            self.waiting.stopAnimating()
                        })
                }
                let itemOwner = cell?.viewWithTag(4) as! UIImageView
                let userAvatar = self.item!["hiwuUser"]["avatar"].string!
                itemOwner.kf_setImageWithURL(NSURL(string:userAvatar)!)
                itemOwner.kf_setImageWithURL(NSURL(string:userAvatar)!, placeholderImage: UIImage(named: "头像"), optionsInfo: nil, completionHandler: {(_) in
                    self.tmpImage = self.resizeImage(itemOwner.image!, height: 200)
                })
                itemOwner.layer.cornerRadius = itemOwner.frame.size.width/2
                itemOwner.clipsToBounds = true
            return cell!
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemDescription")
                let itemName = cell?.viewWithTag(1) as! UILabel
                itemName.text = self.item!["name"].string
                let itemDescription = cell?.viewWithTag(2) as! UILabel
                itemDescription.text = self.item!["description"].string
                let likeButton = cell?.viewWithTag(3) as! UIButton
                if(self.item!["liked"].boolValue){
                    likeButton.setImage(UIImage(named: "iconfont-liked"), forState: UIControlState.Normal)
                    likeButton.addTarget(self, action: #selector(ItemDetailVC.deleteLike), forControlEvents: UIControlEvents.TouchUpInside)
                }else{
                    likeButton.setImage(UIImage(named: "iconfont-like"), forState: UIControlState.Normal)
                    likeButton.addTarget(self, action: #selector(ItemDetailVC.putLike), forControlEvents: UIControlEvents.TouchUpInside)
                }
                
                let likeNum = cell?.viewWithTag(4) as! UILabel
                var likes = 0
                if(self.item!["likes"].int != nil){
                    likes = self.item!["likes"].int!
                }else{
                    likes = self.item!["likers"].count
                }
                likeNum.text = String(likes)
                let addComment = cell?.viewWithTag(5) as! UIButton
                addComment.addTarget(self, action: #selector(ItemDetailVC.toAddComment), forControlEvents: UIControlEvents.TouchUpInside)
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
    

    
    func putLike(){
        let url = ApiManager.putLike1 + String(globalHiwuUser.userId) + ApiManager.putLike2 + String(self.itemId!) + ApiManager.putLike3 + globalHiwuUser.hiwuToken
        Alamofire.request(.PUT,url).responseJSON{response in
            print(response.result.value)
            if(response.result.value != nil){
                self.getItemInfo()
            }else{
                print(response.result.error)
            }
        }
    }
    
    func deleteLike(){
        let url = ApiManager.putLike1 + String(globalHiwuUser.userId) + ApiManager.putLike2 + String(self.itemId!) + ApiManager.putLike3 + globalHiwuUser.hiwuToken
        Alamofire.request(.DELETE,url).responseJSON{response in
            if(response.result.value != nil){
                self.getItemInfo()
            }else{
                
            }
        }
    }
    
    
    
    func getItemInfo(){
        if(isMine!){
//            self.getSelfItemInfo(self.itemId!)
            self.getPublicItemInfo(self.itemId!)
            
        }else{
            self.getPublicItemInfo(self.itemId!)
        }
    }
    
    func getItemInfoFailed() {
         self.waiting.stopAnimating()
    }
    
    func getItemInfoReady() {
        
    }
    
    func networkError(){
        self.waiting.stopAnimating()
        let alert = UIAlertController(title: "请求失败", message: "请检查你的网络", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "知道了", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func postComment(toUserId:Int?,itemId:Int,content:String){
        let url = ApiManager.postComment1 + String(itemId) + ApiManager.postComment2 + globalHiwuUser.hiwuToken
        self.tipToAddComment.text = "在这里添加评论"
        if(toUserId != nil){
            Alamofire.request(.POST, url, parameters: ["content": content,"toId": toUserId!]).responseJSON{response in
                self.waiting.stopAnimating()
                if(response.result.error != nil){
                }else{
                    self.addComment.text = ""
                    self.getItemInfo()
                    self.isCommment = true
                }
            }
        }else{
            Alamofire.request(.POST, url, parameters: ["content": content]).responseJSON{response in
                self.waiting.stopAnimating()
                if(response.result.error != nil){
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
    
//    func getSelfItemInfo(itemId: Int){
//        let url = ApiManager.getSelfItem1 + String(itemId) + ApiManager.getSelfItem2 + globalHiwuUser.hiwuToken
//        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
//            if(response.result.value != nil){
//                self.item = JSON(response.result.value!)
//                self.cells = 2 + self.item!["comments"].count
//                self.waiting.stopAnimating()
//                self.itemDetailList.reloadData()
//                
//            }else{
//                
//            }
//        }
//        
//    }
    
    func getPublicItemInfo(itemId: Int){
        let url = ApiManager.getPublicItem1 + String(itemId) + ApiManager.getPublicItem2 + globalHiwuUser.hiwuToken
        print(url)
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
            if(response.result.value != nil){
                self.item = JSON(response.result.value!)
                self.cells = 2 + self.item!["comments"].count
//                self.waiting.stopAnimating()

                self.itemDetailList.reloadData()
                
            }else{
                
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        itemDetailList.reloadData()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }
    
    func weixinShare(){
        let message = WXMediaMessage()
        var nickname = ""
        var name = "物境未觉博物馆"
        var description = ""
        if(self.item!["hiwuUser"]["nickname"].string != nil){
            nickname = self.item!["hiwuUser"]["nickname"].string!
        }
        if(self.item!["name"].string != nil ){
            name = self.item!["name"].string!
        }
        if(self.item!["description"].string != nil){
            description = self.item!["description"].string!
        }
        message.title = nickname + " ⎡"  + name + " ⎦"
        message.description = description
        message.setThumbImage(tmpImage)
        let webPageObject = WXWebpageObject()
        webPageObject.webpageUrl = "http://palace.server.hiwu.ren/galleries/" + String(self.item!["id"].int!)
        print(webPageObject.webpageUrl)
        message.mediaObject = webPageObject
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        if(weixinScene == 0){
            req.scene = Int32(WXSceneSession.rawValue)
        }else if(weixinScene == 1){
            req.scene = Int32(WXSceneTimeline.rawValue)
        }
    }
    
    func weiboShare(){
        var nickname = ""
        var name = "物境未觉博物馆"
        var description = ""
        if(self.item!["hiwuUser"]["nickname"].string != nil){
            nickname = self.item!["hiwuUser"]["nickname"].string!
        }
        if(self.item!["name"].string != nil ){
            name = self.item!["name"].string!
        }
        if(self.item!["description"].string != nil){
            description = self.item!["description"].string!
        }
        let message = WBMessageObject()
        let authreq = WBAuthorizeRequest()
        authreq.scope = "all"
        authreq.redirectURI = kRedirectURI
        let webpage = WBWebpageObject()
        webpage.webpageUrl = "http://palace.server.hiwu.ren/galleries/" + String(self.item!["id"].int!)
        message.text = "物境未觉 " + nickname + " ⎡"  + name + " ⎦"
        webpage.title = nickname + " ⎡"  + name + " ⎦"
        webpage.description = description
        webpage.thumbnailData = UIImageJPEGRepresentation(tmpImage, 0.5)
        webpage.objectID = webpage.webpageUrl
        message.mediaObject = webpage
        if(weiboScene == 0){
            let req = WBShareMessageToContactRequest()
            req.shouldOpenWeiboAppInstallPageIfNotInstalled = false
            req.message = message
            WeiboSDK.sendRequest(req)
        }else if(weiboScene == 1){
            let req = WBSendMessageToWeiboRequest()
            req.message = message
            WeiboSDK.sendRequest(req)
        }
    }
    
    func resizeImage(img:UIImage,height:CGFloat)->UIImage{
        let scale = 200/img.size.height
        UIGraphicsBeginImageContext(CGSizeMake(img.size.width * scale, img.size.height * scale))
        img.drawInRect(CGRect(x: 0, y: 0, width: img.size.width * scale, height: img.size.height * scale))
        let scaledImg = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImg
    }

    
    

}
