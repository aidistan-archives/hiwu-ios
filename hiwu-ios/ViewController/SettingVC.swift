//
//  SettingVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/1/16.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation


class SettingVC: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBAction func cancel(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    var superVC:SelfMuseumVC?
    var userId = globalHiwuUser.userId
    var userInfo:JSON?
    var popoverVC:UIPopoverController?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        self.getUserInfo()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2
        default:
            return 1
        }
    }
    
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell?
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("Avatar")
                let userAvatar = cell?.viewWithTag(1) as! UIImageView
                userAvatar.kf_setImageWithURL(NSURL(string: self.userInfo!["avatar"].string!)!, placeholderImage: UIImage(named: "头像"))
                userAvatar.layer.cornerRadius = userAvatar.frame.width/2
                userAvatar.clipsToBounds = true
                
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("Name")
                let name = cell?.viewWithTag(1) as! UILabel
                if(self.userInfo!["nickname"].string! != ""){
                    name.text = self.userInfo!["nickname"].string!
                }else{
                    name.text = "未命名"
                }
//                cell = tableView.dequeueReusableCellWithIdentifier("Description")
//                let description = cell?.viewWithTag(1) as! UILabel
//                if(self.userInfo!["description"].string! != ""){
//                    description.text = self.userInfo!["description"].string!
//                }else{
//                    description.text = "未添加描述"
//                }
            }
//        case 1:
//            cell = tableView.dequeueReusableCellWithIdentifier("Account")
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("Feedback")
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("Logout")
            
        }

        return cell!
    }
    
    func getUserInfo(){
        self.refreshControl?.beginRefreshing()
        let url = ApiManager.getSelfUserInfo1 + String(self.userId) + ApiManager.getSelfUserInfo2 + globalHiwuUser.hiwuToken
        Alamofire.request(.GET, url).responseJSON{response in
            if(response.result.error == nil){
                self.userInfo  = JSON(response.result.value!)
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }else{
                let alert = UIAlertController(title: "网络错误", message: String(response.result.error), preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                self.setImage()
            case 1:
                self.toEditName()
            default:
                self.toEditDescription()
            }
//        case 1:
//            print("call account")
        case 1:
            self.toEditFeedback()
        default:
            self.navigationController?.popToRootViewControllerAnimated(true)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setDouble(0, forKey: "deadline")
            
        }
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                return 100
            case 1:
                return 50
            default:
                return 50
            }
        case 1:
            return 50
        case 2:
            return 50
        default:
            return 50
            
        }
        
    }
    
    func setImage(){
        let newAlert = LCActionSheet(title: "选择照片来源", buttonTitles: ["拍摄","从相册"], redButtonIndex: -1, clicked: { button in
            if(button == 0){
                self.callCamera()
            }else if(button == 1){
                self.callPhotoLibrary()
            }
            
        })
        newAlert.show()
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
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone){
            self.presentViewController(camera, animated: true, completion: nil)
        }else{
            if(self.popoverVC != nil){
                self.popoverVC?.dismissPopoverAnimated(true)
                self.popoverVC = nil
            }
            let popover = UIPopoverController(contentViewController: camera)
            self.popoverVC = popover
            self.popoverVC!.presentPopoverFromRect(CGRectMake(-600,-600, 1000, 1000), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let tmpImage = info[UIImagePickerControllerEditedImage] as? UIImage
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera){
            let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            UIImageWriteToSavedPhotosAlbum(originImage!, nil, nil, nil)
        }
        var tmpImage1 = UIImage(named: "头像")
        if(tmpImage != nil){
            tmpImage1 = tools.resizeImage(tmpImage!, height: 200)
        }
        let jpgUrl = NSHomeDirectory().stringByAppendingString("/tmp/").stringByAppendingString("tmp.jpg")
        UIImageJPEGRepresentation(tmpImage1!, 0.7)?.writeToFile(jpgUrl, atomically: false)
        self.updateAvatar(jpgUrl)
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func updateAvatar(jpgUrl:String){
        let url = ApiManager.putAvatar1 + String(globalHiwuUser.userId) + ApiManager.putAvatar2 + globalHiwuUser.hiwuToken
        Alamofire.upload(.PUT, url,multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: jpgUrl), name: "data")
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if(response.result.value != nil){
                            self.getUserInfo()
                            self.superVC?.needRefresh = true
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    func toEditName(){
        let editName = self.storyboard?.instantiateViewControllerWithIdentifier("EditNameVC") as! EditNameVC
        editName.name = self.userInfo!["nickname"].string!
        editName.userId = self.userInfo!["id"].int!
        editName.superVC = self
    self.navigationController?.pushViewController(editName, animated: true)
    }
    
    func toEditDescription(){
        let editDescription = self.storyboard?.instantiateViewControllerWithIdentifier("EditDescriptionVC") as! EditDescriptionVC
        editDescription.userDescription = self.userInfo!["description"].string!
        editDescription.userId = self.userInfo!["id"].int!
        self.navigationController?.pushViewController(editDescription, animated: true)
    }
    
    func toEditFeedback(){
        let editFeedback = self.storyboard?.instantiateViewControllerWithIdentifier("FeedbackVC") as! FeedbackVC
        editFeedback.userId = self.userInfo!["id"].int!
        editFeedback.userNickname  = self.userInfo!["nickname"].string!
        self.navigationController?.pushViewController(editFeedback, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }

}
