//
//  GalleryDetailVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/30.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import AVFoundation

class GalleryDetailVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GetItemInfoReadyProtocol,GetSelfMuseumReadyProtocol,GetTodayInfoReadyProtocol{
    
    var isMine = false
    var gallery:JSON?
    var userAvatar:String?
    var userName:String?
    let defaults = NSUserDefaults.standardUserDefaults()
    let contactor = ContactWithServer()
    var location = -1
    var selfDelete = 0
    
    @IBOutlet weak var galleryDetails: UITableView!
    
    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func toAddItem(sender: UIButton)
    {
        
        let alert = UIAlertController(title: "选择照片来源", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "从相机", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) in
            self.callCamera()
        }))
        alert.addAction(UIAlertAction(title: "从相册", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) in
            self.callPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var addItemButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")
        self.galleryDetails.delegate = self
        self.galleryDetails.dataSource = self
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
        self.contactor.todayInfoReady = self
        self.contactor.selfMuseumReady = self
        self.refresh()
        print("will appear")

    }
    
    func refresh(){
        if(self.isMine == true){
            self.contactor.getSelfMuseum(nil)
        }else{
            self.contactor.getTodayInfo()
        }
        self.galleryDetails.reloadData()
    }
    
    func setInfo(gallery:JSON,userAvatar:String?,userName:String){
        self.gallery = gallery
        self.userAvatar = userAvatar
        self.userName = userName
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.gallery!["items"].count+1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 94
        
        }else{
        return 140
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("GalleryTitle")! as UITableViewCell
            let ownerAvatar = cell.viewWithTag(1) as! UIImageView
            if(self.userAvatar != nil){
            ownerAvatar.kf_setImageWithURL(NSURL(string: self.userAvatar!)!)
                ownerAvatar.layer.cornerRadius = ownerAvatar.frame.size.width/2
                ownerAvatar.clipsToBounds = true
            }
            let galleryName = cell.viewWithTag(2) as! UITextField
            galleryName.text = self.gallery!["name"].string
            let galleryDescription = cell.viewWithTag(3) as! UITextField
            galleryDescription.text = self.gallery!["description"].string
            let itemNum = cell.viewWithTag(4) as! UILabel
            itemNum.text = String(self.gallery!["items"].count)
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("ItemTitle")!
            let itemId = cell.viewWithTag(2) as! UILabel
            itemId.text = String(gallery!["items"][indexPath.row-1]["id"])
            let itemPic = cell.viewWithTag(10) as! UIImageView
            if(self.gallery!["items"][indexPath.row-1]["photos"][0]["url"].string != nil){
                itemPic.kf_setImageWithURL(NSURL(string: self.gallery!["items"][indexPath.row-1]["photos"][0]["url"].string!)!)}else{
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
            itemOwner.text = self.userName!
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
        contactor.superGalleryDetailVC = self
        contactor.deleteItem(self.gallery!["items"][indexPath.row-1]["id"].int!,complete: nil)
        print("delete")
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    func getItemDetail(sender:UITapGestureRecognizer){
        let contactor = ContactWithServer()
        contactor.itemInfoReady = self
        let itemIdLabel = sender.view?.viewWithTag(2) as! UILabel
        let itemId = Int(itemIdLabel.text!)
        print("prepare")
        print(NSDate(timeIntervalSinceNow: 0))
        print("ask server")
        if(isMine){
            contactor.getSelfItemInfo(itemId!)
        }else{
            contactor.getPublicItemInfo(itemId!)
        }
    }
    
    func getItemInfoReady() {
        print(NSDate(timeIntervalSinceNow: 0))
        let itemDetail = self.storyboard?.instantiateViewControllerWithIdentifier("ItemDetailVC") as! ItemDetailVC
        itemDetail.item = globalHiwuUser.item
        self.navigationController?.pushViewController(itemDetail, animated: true)
    }
    
    func getItemInfoFailed() {
    }
    
    func getSelfMuseunReady() {
        let ga = idFinder.findFromGallery(self.gallery!["id"].int!, gallery: globalHiwuUser.selfMuseum!["galleries"])
        if(ga != nil){
            self.gallery = ga
        }
        self.galleryDetails.reloadData()
    }
    
    func getSelfMuseunFailed() {
        
    }
    func getTodayFailed() {
        
    }
    func getTodayReady() {
        let ga = idFinder.findFromGallery(self.gallery!["id"].int!, gallery: globalHiwuUser.todayMuseum!["gallery"])
        if(ga != nil){
            self.gallery = ga
        }
        print("get today ready ga")
        self.galleryDetails.reloadData()
        self.galleryDetails.hidden = false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let toAdd = self.storyboard?.instantiateViewControllerWithIdentifier("AddItemVC") as! AddItemVC
        toAdd.galleryId = self.gallery!["id"].int!
        print(toAdd.galleryId)
        toAdd.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
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
        camera.allowsEditing = true
        self.presentViewController(camera, animated: true, completion: nil)
    }
}
