//
//  ViewController.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/16.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
        
        let camera = UIImagePickerController()
        camera.sourceType  = UIImagePickerControllerSourceType.PhotoLibrary
        let alert1 = UIAlertController(title: "false", message: "no camera", preferredStyle: UIAlertControllerStyle.Alert)
        alert1.addAction(UIAlertAction(title: "quxiao", style: UIAlertActionStyle.Cancel, handler: nil))
        //            self.presentViewController(alert1, animated: true, completion: nil)
        
        camera.delegate = self
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
    }


}

