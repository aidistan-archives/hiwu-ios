//
//  AddGalleryVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/12/2.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddGalleryVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var galleryDespcription: BRPlaceholderTextView!
    @IBOutlet weak var galleryName: UITextField!
    
    @IBAction func cancel(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    let contactor = ContactWithServer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.galleryName.layer.borderColor = UIColor(red: 204, green: 204, blue: 204, alpha: 1).CGColor
        self.galleryName.layer.borderWidth = 1
        let gest = UITapGestureRecognizer(target: self, action: #selector(AddGalleryVC.endTheEditingOfTextView))
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        self.galleryDespcription.placeholder = "在这里添加长廊描述"
        self.galleryName.delegate = self
        let gestureBack = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(AddGalleryVC.back as (AddGalleryVC) -> () -> ()))
        gestureBack.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(gestureBack)
    }

    @IBAction func addOk(sender: UIButton) {
        self.postGallery(self.galleryName.text!, despcription: self.galleryDespcription.text!, isPublic: true, userId: globalHiwuUser.userId)
        
    }
    
    @IBAction func back(sender: UIButton) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func postGallery(name:String!,despcription:String!,isPublic:Bool!,userId:Int!){
        let url = ApiManager.postGallery1 + String(userId) + ApiManager.postGallery2 + globalHiwuUser.hiwuToken
        Alamofire.request(.POST, url, parameters: ["name":name + "博物馆","description":despcription,"public":isPublic]).responseJSON{response in
            if(response.result.value != nil)
            {
                let value = JSON(response.result.value!)
                if(value["error"] == nil){
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
            }
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return  true
    }

}
