//
//  AddGalleryVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/12/2.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class AddGalleryVC: UIViewController,UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet weak var galleryName: UITextField!
    @IBOutlet weak var galleryDespcription: UITextView!
    let contactor = ContactWithServer()
    override func viewDidLoad() {
        super.viewDidLoad()
        let gest = UITapGestureRecognizer(target: self, action: "endTheEditingOfTextView")
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        self.galleryDespcription.delegate = self
        self.galleryName.delegate = self
        let gestureBack = UIScreenEdgePanGestureRecognizer(target: self, action: "back")
        gestureBack.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(gestureBack)
    }

    @IBAction func addOk(sender: UIButton) {
        self.contactor.postGallery(self.galleryName.text!, despcription: self.galleryDespcription.text!, isPublic: true, userId: globalHiwuUser.userId)
    }
    @IBAction func back(sender: UIButton) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.galleryName.endEditing(true)
        self.galleryDespcription.endEditing(true)
    }
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
