//
//  AddItem.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/24.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher
import SwiftyJSON
import Alamofire

class AddItemVC: UIViewController,UITextViewDelegate,UITextFieldDelegate{
    var image:UIImage?
    var galleryId = 0
    var superGallery:GalleryDetailVC?
    let hud = JGProgressHUD(style:JGProgressHUDStyle.Dark)
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet weak var itemImage: UIImageView!

    @IBOutlet weak var time: UITextField!

    @IBOutlet weak var city: UITextField!
    
    @IBOutlet weak var museumName: UIButton!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var isPublic: UISwitch!
    
    @IBAction func ok(sender: UIButton) {
        if((galleryId == 0)||(itemName.text == ""||itemDescription.text == ""||city.text == ""||time.text == "")){
            let alert = UIAlertController(title: "错误", message: "请将信息补全", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            var year = Int(self.time.text!)
            if(year == nil){
                year = 0
            }
            NSUserDefaults.standardUserDefaults().setInteger(year!, forKey: "defaultYear")
            NSUserDefaults.standardUserDefaults().setValue(self.city.text, forKey: "defaultCity")
        let jpgUrl = NSHomeDirectory().stringByAppendingString("/tmp/").stringByAppendingString("tmp.jpg")
            var tmpHeight = CGFloat(500)
            if(itemImage.frame.size.height < 500){
                tmpHeight = itemImage.frame.size.height
            }
            let tmpImage = tools.resizeImage(itemImage.image!, height: tmpHeight)
            UIImageJPEGRepresentation(tmpImage, 0.9)?.writeToFile(jpgUrl, atomically: false)
            self.postItem(self.galleryId, itemName: itemName.text!, itemDescription: itemDescription.text, year: year!, city: self.city.text!, dataUrl: NSURL(fileURLWithPath: jpgUrl), isPublic: isPublic.on)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ttime = NSUserDefaults.standardUserDefaults().integerForKey("defaultYear")
        print(ttime)
        let tcity = NSUserDefaults.standardUserDefaults().stringForKey("defaultCity")
        print(tcity)
        if(ttime != 0){
            self.time.text = String(ttime)
        }
        if(tcity != nil){
            self.city.text = tcity
        }
        if(self.image != nil){
            self.itemImage.image = self.image
        }
        self.itemDescription.delegate = self
        self.itemName.delegate = self
        let gest = UITapGestureRecognizer(target: self, action: #selector(AddItemVC.endTheEditingOfTextView))
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        self.time.delegate = self
        self.city.delegate = self
        let gestureBack = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(AddItemVC.back))
        gestureBack.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(gestureBack)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        let location = textView.frame
        let size = self.view.frame
        let offset = size.height - location.maxY - 300
        if(offset<0){
            
            var newFrame = self.view.frame
            newFrame.origin.y = offset
            UIView.animateWithDuration(0.5, animations: {() in
            self.view.frame = newFrame
            })
            
        }
        if(textView.text == "在这里添加物品描述"){
            textView.text = ""
        }
    
    }
    
    func textViewDidEndEditing(textView: UITextView){
        if(textView.text == ""){
            textView.text = "在这里添加物品描述"
        }
        textView.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: {void in
            self.view.frame.origin.y = 0
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField){
        let location = textField.frame
        let size = self.view.frame
        let offset = size.height - location.maxY - 280
        if(offset<0){
            UIView.animateWithDuration(0.5, animations: {void in
                var newFrame = self.view.frame
                newFrame.origin.y = offset
                self.view.frame = newFrame})
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        textField.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: {void in
            self.view.frame.origin.y = 0
        })
    }
    
    func endTheEditingOfTextView(){
        self.itemDescription.endEditing(true)
        self.itemName.endEditing(true)
        self.city.endEditing(true)
        self.time.endEditing(true)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        galleryId = globalHiwuUser.selfMuseum!["galleries"][row]["id"].int!
    }
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func postItem(galleryId:Int,itemName:String,itemDescription:String,year:Int,city:String,dataUrl:NSURL,isPublic:Bool){
        let postItemUrl = ApiManager.postItem1 + String(galleryId) + ApiManager.postItem2 + globalHiwuUser.hiwuToken
        hud.showInView(self.view, animated: true)
        hud.textLabel.text = "上传中"
        Alamofire.request(.POST, postItemUrl, parameters: [
            "name": itemName,
            "description": itemDescription,
            "date_y": year,
            "date_m": 0,
            "date_d": 0,
            "city": city,
            "public": isPublic
            ]).responseJSON{response in
                if(response.result.value != nil){
                    self.postPhotoToItem(JSON(response.result.value!)["id"].int!, dataUrl: dataUrl)
                }
        }
        
    }
    
    func postPhotoToItem(itemId:Int,dataUrl:NSURL){
        let postPhotoUrl = ApiManager.postItemPhoto1 + String(itemId) + ApiManager.postItemPhoto2 + globalHiwuUser.hiwuToken
        Alamofire.upload(.POST, postPhotoUrl,multipartFormData: { multipartFormData in
            multipartFormData.appendBodyPart(fileURL: dataUrl, name: "data")
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        if(response.result.value != nil){
                            let value = JSON(response.result.value!)
                            if(value["error"] == nil){
                                self.navigationController?.popViewControllerAnimated(true)
                                self.superGallery?.superSelfVC?.needRefresh = true
                                self.superGallery?.refresh()
                            }else{
                                let contactor = ContactWithServer()
                                contactor.deleteItem(itemId, complete: nil)
                                self.hud.dismiss()
                                let alert1 = SCLAlertView()
                                alert1.showError(self, title: "错误", subTitle: "", closeButtonTitle: "知道了", duration: 0)
                            }
                            
                        }else{
                            
                        }
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }

}
