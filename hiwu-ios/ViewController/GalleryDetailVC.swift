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

class GalleryDetailVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ServerContactorDelegates,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource{
    
    var isMine = false
    var gallery:JSON?
    let defaults = NSUserDefaults.standardUserDefaults()
    let contactor = ContactWithServer()
    let notification = NSNotificationCenter.defaultCenter()
    var location = -1
    var scrollLocation = CGPoint(x: 0, y: 0)
    
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
        
        
    }
    
    
    @IBOutlet weak var addItemButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactor.delegate = self
        self.navigationController?.navigationBarHidden = false
        self.galleryDetails.delegate = self
        self.galleryDetails.dataSource = self
        self.galleryDetails.estimatedRowHeight = 140
        self.galleryDetails.rowHeight = UITableViewAutomaticDimension
        self.galleryDetails.reloadData()
        if(isMine){
            self.addItemButton.hidden = false
            
        }else{
            self.galleryDetails.setEditing(false, animated: true)
            self.addItemButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print("did appear")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.galleryDetails.reloadData()

    }
    override func viewWillDisappear(animated: Bool) {
        self.scrollLocation = self.galleryDetails.contentOffset
        self.notification.removeObserver(self)
    }
    
    func refresh(){
        if(self.isMine == true){
            self.contactor.getSelfMuseum()
        }else{
            self.contactor.getTodayInfo()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.gallery!["items"].count+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("GalleryTitle")! as UITableViewCell
            print(self.gallery!["hiwuUser"])
            let ownerAvatar = cell.viewWithTag(1) as! UIImageView
            if(self.gallery!["hiwuUser"]["avatar"].string != ""){
            ownerAvatar.kf_setImageWithURL(NSURL(string: self.gallery!["hiwuUser"]["avatar"].string!)!, placeholderImage: UIImage(named: "头像"))
                ownerAvatar.layer.cornerRadius = ownerAvatar.frame.size.width/2
                ownerAvatar.clipsToBounds = true
            }else{
                ownerAvatar.image = UIImage(named: "头像")
            }
            let galleryName = cell.viewWithTag(2) as! UILabel
            galleryName.text = self.gallery!["hiwuUser"]["nickname"].string! + " ⎡" + self.gallery!["name"].string! + " ⎦"
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
                itemPic.image = UIImage(named: "add")
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
            let gesture = UITapGestureRecognizer(target: self, action: "getItemDetail:")
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
//            contactor.getSelfItemInfo(itemId!)
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
    
    
    func getSelfMuseumFailed() {
        
        
    }
    func getTodayFailed() {
        
    }
    func getTodayReady() {
        let ga = idFinder.findFromGallery(self.gallery!["id"].int!, gallery: globalHiwuUser.todayMuseum!["gallery"])
        if(ga != nil){
            self.gallery = ga
        }
        self.galleryDetails.reloadData()
        self.galleryDetails.hidden = false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let toAdd = self.storyboard?.instantiateViewControllerWithIdentifier("AddItemVC") as! AddItemVC
        toAdd.galleryId = self.gallery!["id"].int!
        toAdd.image = info[UIImagePickerControllerEditedImage] as? UIImage
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
        camera.allowsEditing = true
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
    func callPhotoLibrary(){
        let camera = UIImagePickerController()
        camera.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        camera.delegate = self
        camera.allowsEditing = true
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
    func deleteItem(itemId:Int){
        let deleteUrl = ApiManager.deleteItem1 + String(itemId) + ApiManager.deleteItem2 + globalHiwuUser.hiwuToken
        Alamofire.request(.DELETE, NSURL(string: deleteUrl)!).responseJSON{response in
            if(response.result.value != nil){
                let value = JSON(response.result.value!)
                if(value["error"] == nil){
                    print("delete success")
                }
            }
        }
        
    }

}
