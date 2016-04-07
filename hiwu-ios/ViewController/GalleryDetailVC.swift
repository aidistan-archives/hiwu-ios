//
//  GalleryDetailVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/30.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation

class GalleryDetailVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ServerContactorDelegates,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource,UIPopoverControllerDelegate{
    
    var superSelfVC:SelfMuseumVC?
    var superTodayVC:TodayVC?
    var isMine = false
    var gallery:JSON?
    var galleryId = 0
    let defaults = NSUserDefaults.standardUserDefaults()
    let contactor = ContactWithServer()
    let notification = NSNotificationCenter.defaultCenter()
    var scrollLocation = CGPoint(x: 0, y: 0)
    var tmpImage = UIImage(named: "头像")
    var weixinScene = 0
    var weiboScene = 1
    let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    var popoverVC:UIPopoverController?
    
    @IBOutlet weak var galleryDetails: UITableView!
    
    @IBAction func toAddItem(sender: UIButton)
    {
        let newAlert = LCActionSheet(title: "选择照片来源", buttonTitles: ["拍摄","从相册"], redButtonIndex: -1, clicked: { button in
            if(button == 0){
                self.callCamera()
            }else if(button == 1){
                self.callPhotoLibrary()
            }
            
        })
        newAlert.show()
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func shareButton(sender: UIButton) {
//        self.weixinShare()
        let desc = JMActionSheetDescription()
        let collectionItem = JMActionSheetCollectionItem()
        let item1 = JMCollectionItem()
        item1.actionName = "新浪微博"
        item1.actionImage = UIImage(named: "sina")
        item1.actionImageContentMode = UIViewContentMode.ScaleAspectFit
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
        item4.actionImage = UIImage(named: "iconfont-copy")
        item4.actionImageContentMode = UIViewContentMode.ScaleAspectFit
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
                pasteboard.string = "http://palace.server.hiwu.ren/galleries/" + String(self.gallery!["id"].int!)

                self.hud.textLabel.text = "复制成功"
                self.hud.position = JGProgressHUDPosition.BottomCenter
                self.hud.showInView(self.view)
                self.hud.dismissAfterDelay(0.3)
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
    
    
    @IBOutlet weak var addItemButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresh()
        self.hud.textLabel.text = "加载中"
        self.hud.showInView(self.view)
        self.galleryDetails.hidden = true
        self.contactor.delegate = self
        self.navigationController?.navigationBarHidden = false
        self.galleryDetails.estimatedRowHeight = 140
        self.galleryDetails.rowHeight = UITableViewAutomaticDimension
        if(isMine){
            self.addItemButton.hidden = false
            
        }else{
            self.galleryDetails.setEditing(false, animated: true)
            self.addItemButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
//        print("did appear")
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.scrollLocation = self.galleryDetails.contentOffset
        self.notification.removeObserver(self)
    }
    
    func refresh(){
        if(self.isMine == true){
            self.contactor.getSelfGallery(self.galleryId, complete:{selfGallery in
                if(selfGallery != nil){
                    self.gallery = selfGallery
                    self.galleryDetails.delegate = self
                    self.galleryDetails.dataSource = self
                    self.galleryDetails.reloadData()
                    self.galleryDetails.hidden = false
                    self.hud.dismiss()
                }
                
            })
        }else{
            self.contactor.getPublicGallery(self.galleryId, complete: {publicGallery in
                if(publicGallery != nil){
                    self.gallery = publicGallery
                    self.galleryDetails.delegate = self
                    self.galleryDetails.dataSource = self
                    self.galleryDetails.reloadData()
                    self.galleryDetails.hidden = false
                    self.hud.dismiss()
                }
                
            })
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.gallery!["items"].count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("GalleryTitle")! as UITableViewCell
            let ownerAvatar = cell.viewWithTag(1) as! UIImageView
            if(self.gallery!["hiwuUser"]["avatar"].string! != ""){
                ownerAvatar.kf_setImageWithURL(NSURL(string: self.gallery!["hiwuUser"]["avatar"].string!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: {(_) in
                    self.tmpImage = tools.resizeImage(ownerAvatar.image!, height: 200)
                })
            }else{
                ownerAvatar.image = UIImage(named: "头像")
                self.tmpImage = tools.resizeImage(ownerAvatar.image!, height: 200)
            }
            ownerAvatar.layer.cornerRadius = ownerAvatar.frame.size.width/2
            ownerAvatar.clipsToBounds = true
            let galleryName = cell.viewWithTag(2) as! UILabel
            galleryName.text = self.gallery!["hiwuUser"]["nickname"].string! + " ⎡" + self.gallery!["name"].string! + "⎦"
            let galleryDescription = cell.viewWithTag(3) as! UILabel
            galleryDescription.text = self.gallery!["description"].string
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemTitle")!
            let itemId = cell.viewWithTag(2) as! UILabel
            itemId.text = String(gallery!["items"][indexPath.row-1]["id"])
            let itemPic = cell.viewWithTag(10) as! UIImageView
            if(self.gallery!["items"][indexPath.row-1]["photos"][0]["url"] != nil){
                itemPic.kf_setImageWithURL(NSURL(string: self.gallery!["items"][indexPath.row-1]["photos"][0]["url"].string! + "@!200x200")!)}else{
                itemPic.image = UIImage(named: "nothing")
            }
            
            let itemName = cell.viewWithTag(20) as! UILabel
            itemName.text = gallery!["items"][indexPath.row-1]["name"].string
            let itemDescription = cell.viewWithTag(30) as! UILabel
            itemDescription.text = gallery!["items"][indexPath.row-1]["description"].string
            let itemTime = cell.viewWithTag(40) as! UILabel
            itemTime.text = String(gallery!["items"][indexPath.row-1]["date_y"].int!)
            let itemCity = cell.viewWithTag(50) as! UILabel
            itemCity.text = gallery!["items"][indexPath.row-1]["city"].string
            let itemOwner = cell.viewWithTag(60) as! UILabel
            itemOwner.text = self.gallery!["hiwuUser"]["nickname"].string!
            let gesture = UITapGestureRecognizer(target: self, action: #selector(GalleryDetailVC.getItemDetail(_:)))
            cell.addGestureRecognizer(gesture)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(isMine){
            return true
        }else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let alert = SCLAlertView()
        alert.addButton("删除", actionBlock: { () in
            self.deleteItem(self.gallery!["items"][indexPath.row-1]["id"].int!)
            
        })
        alert.showWarning(self, title: "删除物品", subTitle: "确定删除该物品吗？", closeButtonTitle: "取消", duration: 0)
        tableView.editing = false
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    func getItemDetail(sender:UITapGestureRecognizer){
        let contactor = ContactWithServer()
        contactor.delegate = self
        let itemIdLabel = sender.view?.viewWithTag(2) as! UILabel
        let itemId = Int(itemIdLabel.text!)
        if(isMine){
            contactor.getPublicItemInfo(itemId!)
        }else{
            contactor.getPublicItemInfo(itemId!)
        }
    }
    
    func getPublicItemInfoReady() {
        let itemDetail = self.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
//        itemDetail.item = globalHiwuUser.item
        itemDetail.isMine = self.isMine
        itemDetail.itemId = globalHiwuUser.item!["id"].int!
        self.navigationController?.pushViewController(itemDetail, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let toAdd = self.storyboard?.instantiateViewControllerWithIdentifier("AddItemVC") as! AddItemVC
        toAdd.galleryId = self.gallery!["id"].int!
        toAdd.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera){
            let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            UIImageWriteToSavedPhotosAlbum(originImage!, nil, nil, nil)
        }
        toAdd.superGallery = self
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.pushViewController(toAdd, animated: true)
    
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func callCamera(){
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = UIImagePickerControllerSourceType.Camera
        camera.showsCameraControls = true
        self.presentViewController(camera, animated: true, completion: nil)

        
    }
    
    func callPhotoLibrary(){
        let camera = UIImagePickerController()
        camera.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        camera.delegate = self
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone){
            self.presentViewController(camera, animated: true, completion: nil)
        }else{
            if(self.popoverVC != nil){
                self.popoverVC?.dismissPopoverAnimated(true)
                self.popoverVC = nil
            }
            let popover = UIPopoverController(contentViewController: camera)
            self.popoverVC = popover
            self.popoverVC!.presentPopoverFromRect(CGRectMake(-600,-600 , 1000, 1000), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        }
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
    func deleteItem(itemId:Int){
        let deleteUrl = ApiManager.deleteItem1 + String(itemId) + ApiManager.deleteItem2 + globalHiwuUser.hiwuToken
        Alamofire.request(.DELETE, NSURL(string: deleteUrl)!).responseJSON{response in
            if(response.result.value != nil){
                let value = JSON(response.result.value!)
                if(value["error"] == nil){
                    self.refresh()
                    self.superSelfVC?.needRefresh = true
                    self.superTodayVC?.needRefresh = true
                }
            }
        }
        
    }
    
    func weixinShare(){
        let message = WXMediaMessage()
        var nickname = ""
        var name = "物境未觉博物馆"
        var description = ""
        if(self.gallery!["hiwuUser"]["nickname"].string != nil){
            nickname = self.gallery!["hiwuUser"]["nickname"].string!
        }
        if(self.gallery!["name"].string != nil ){
            name = self.gallery!["name"].string!
        }
        if(self.gallery!["description"].string != nil){
            description = self.gallery!["description"].string!
        }
        message.title = nickname + " ⎡"  + name + " ⎦"
        message.description = description
        message.setThumbImage(tmpImage)
        let webPageObject = WXWebpageObject()
        webPageObject.webpageUrl = "http://palace.server.hiwu.ren/galleries/" + String(self.gallery!["id"].int!)
        message.mediaObject = webPageObject
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        if(weixinScene == 0){
            req.scene = Int32(WXSceneSession.rawValue)
        }else if(weixinScene == 1){
            req.scene = Int32(WXSceneTimeline.rawValue)
        }
        WXApi.sendReq(req)
    }
    
    func weiboShare(){
        var nickname = ""
        var name = "物境未觉博物馆"
        var description = ""
        if(self.gallery!["hiwuUser"]["nickname"].string != nil){
            nickname = self.gallery!["hiwuUser"]["nickname"].string!
        }
        if(self.gallery!["name"].string != nil ){
            name = self.gallery!["name"].string!
        }
        if(self.gallery!["description"].string != nil){
            description = self.gallery!["description"].string!
        }
        let message = WBMessageObject()
        let authreq = WBAuthorizeRequest()
        authreq.scope = "all"
        authreq.redirectURI = kRedirectURI
        let webpage = WBWebpageObject()
        webpage.webpageUrl = "http://palace.server.hiwu.ren/galleries/" + String(self.gallery!["id"].int!)
        message.text = "物境未觉 " + nickname + " ⎡"  + name + " ⎦"
        webpage.title = nickname + " ⎡"  + name + " ⎦"
        webpage.description = description
        webpage.thumbnailData = UIImageJPEGRepresentation(tmpImage!, 0.5)
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
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }
    
    

}
