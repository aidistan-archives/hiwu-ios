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
    
    var userId = globalHiwuUser.userId
    var userInfo:JSON?
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
            return 3
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
                userAvatar.kf_setImageWithURL(NSURL(string: self.userInfo!["avatar"].string!)!, placeholderImage: UIImage(named: "iconfont-like"))    
                userAvatar.layer.cornerRadius = userAvatar.frame.height/2
                userAvatar.clipsToBounds = true
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("Name")
                let name = cell?.viewWithTag(1) as! UILabel
                if(self.userInfo!["nickname"].string! != ""){
                    name.text = self.userInfo!["nickname"].string!
                }else{
                    name.text = "未命名"
                }
                
            default:
                cell = tableView.dequeueReusableCellWithIdentifier("Description")
                let description = cell?.viewWithTag(1) as! UILabel
                if(self.userInfo!["description"].string! != ""){
                    description.text = self.userInfo!["description"].string!
                }else{
                    description.text = "未添加描述"
                }
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
            print("call feed back")
        default:
            self.navigationController?.popToRootViewControllerAnimated(true)
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setDouble(0, forKey: "deadline")
            
        }
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setImage(){
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let tmpImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let originImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        UIImageWriteToSavedPhotosAlbum(originImage!, nil, nil, nil)
        let jpgUrl = NSHomeDirectory().stringByAppendingString("/tmp/").stringByAppendingString("tmp.jpg")
        UIImageJPEGRepresentation(tmpImage!, 0.7)?.writeToFile(jpgUrl, atomically: false)
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
                            print(response.result.value)
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
        self.navigationController?.pushViewController(editFeedback, animated: true)
    }

}
