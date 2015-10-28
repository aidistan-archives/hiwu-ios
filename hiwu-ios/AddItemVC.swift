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

class AddItemVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITextFieldDelegate{
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBAction func timeSelect(sender: UIButton) {
    }

    @IBAction func locationSelect(sender: UIButton) {
    }
    @IBAction func ownerSelector(sender: UIButton) {
    }
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var ownerAvatar: UIImageView!
    
    
    
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
    
    @IBAction func museumSelector(sender: UIButton) {
        
        let alert = UIAlertController(title: "选择博物馆", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "添加博物馆", style: UIAlertActionStyle.Default, handler: nil))
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: "takePicture:")
        itemImage.addGestureRecognizer(gesture)
        self.itemDescription.delegate = self
        self.itemName.delegate = self
        let gest = UITapGestureRecognizer(target: self, action: "endTheEditingOfTextView")
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        
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
        self.presentViewController(camera, animated: true, completion: nil)
    
    }
    
    func callPhotoLibrary(){
        let camera = UIImagePickerController()
        camera.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        camera.delegate = self
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        print("selected")
        print(info)
        self.itemImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
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
            self.view.frame = newFrame
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
        self.view.frame.origin.y = 0
    }
    
    func textFieldDidBeginEditing(textField: UITextField){
        let location = textField.frame
        let size = self.view.frame
        print(location)
        print(size)
        let offset = size.height - location.maxY - 300
        if(offset<0){
            
            var newFrame = self.view.frame
            newFrame.origin.y = offset
            self.view.frame = newFrame
        }

    }
    
    func textFieldDidEndEditing(textField: UITextField){
        textField.resignFirstResponder()
        self.view.frame.origin.y = 0
    }
    
    func endTheEditingOfTextView(){
        self.itemDescription.endEditing(true)
        self.itemName.endEditing(true)
    }

    
    
}
