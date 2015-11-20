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

class AddItemVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITextFieldDelegate{
    var galleryId = 0
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBAction func timeSelect(sender: UIButton) {
    }

    @IBAction func locationSelect(sender: UIButton) {
    }

    @IBOutlet weak var time: UITextField!

    @IBOutlet weak var city: UITextField!
    
    func takePicture(sender: UITapGestureRecognizer) {
        print("takepicture")
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
    
    @IBOutlet weak var museumName: UIButton!
    @IBAction func museumSelector(sender: UIButton) {
        let alert = UIAlertController(title: "选择博物馆", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "添加博物馆", style: UIAlertActionStyle.Default, handler: {sender in
            let alert1 = UIAlertController(title: "添加博物馆", message: "请输入博物馆的名字", preferredStyle: UIAlertControllerStyle.Alert)
            alert1.addTextFieldWithConfigurationHandler(nil)
            alert1.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            alert1.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: {(sender) in
                self.museumName.setTitle(alert1.textFields![0].text, forState: UIControlState.Normal)
                let x = globalHiwuUser.selfMuseum!["galleries"][0]
                print(x)
            }))
            
            self.navigationController?.presentViewController(alert1, animated: true, completion: nil)
        }))
        let picker = UIPickerView(frame: CGRect(x: 30, y: 40, width: 300, height: 150));
        picker.backgroundColor = UIColor.brownColor()
        picker.delegate = self
        alert.view.addSubview(picker)
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
        
    }
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var isPublic: UISwitch!
    
    @IBAction func ok(sender: UIButton) {
        if((galleryId == 0)||(itemName.text == ""||itemDescription.text == ""||city.text == ""||time.text == "")){
            let alert = UIAlertController(title: "错误", message: "请将信息补全", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
        let contactor = ContactWithServer()
        let jpgUrl = NSHomeDirectory().stringByAppendingString("/tmp/").stringByAppendingString("tmp.jpg")
//            stringByAppendingString("/Documents/"+String(itemName.text!) + ".jpg")
            UIImageJPEGRepresentation(itemImage.image!, 1.0)?.writeToFile(jpgUrl, atomically: false)
            contactor.postItem(galleryId, itemName: itemName.text!, itemDescription: itemDescription.text, year: Int(self.time.text!)!, city: self.city.text!, dataUrl: NSURL(fileURLWithPath: jpgUrl), isPublic: isPublic.on)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryId = globalHiwuUser.selfMuseum!["galleries"][0]["id"].int!
        let gesture = UITapGestureRecognizer(target: self, action: "takePicture:")
        itemImage.addGestureRecognizer(gesture)
        self.itemDescription.delegate = self
        self.itemName.delegate = self
        let gest = UITapGestureRecognizer(target: self, action: "endTheEditingOfTextView")
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        self.time.delegate = self
        self.city.delegate = self
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return globalHiwuUser.selfMuseum!["galleries"].count
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return globalHiwuUser.selfMuseum!["galleries"][row]["name"].string!
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
        self.itemImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        let location = textView.frame
        let size = self.view.frame
        print(location)
        print(size)
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
        print(galleryId)
    }

    
    
}
