//
//  ItemDetailVC.swift
//  hiwu-ios
//
//  Created by 阮良 on 15/10/31.
//  Copyright © 2015年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class ItemDetailVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate {
    
    @IBOutlet weak var addComment: UITextView!
    @IBOutlet weak var itemDetailList: UITableView!
    var item:JSON?

    @IBAction func back(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func ensureComment(sender: UIButton) {
    }
    @IBOutlet weak var ensureCommentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addComment.delegate = self
        self.itemDetailList.estimatedRowHeight = 60
        self.itemDetailList.rowHeight = UITableViewAutomaticDimension
        itemDetailList.dataSource = self
        itemDetailList.delegate = self
        itemDetailList.reloadData()
        let gest = UITapGestureRecognizer(target: self, action: "endTheEditingOfTextView")
        gest.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gest)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemImage")
                let itemImage = cell?.viewWithTag(1) as! UIImageView
                print(self.item!["photos"][0]["url"].string)
                if(self.item!["photos"][0]["url"].string! == ""){
                    itemImage.image = UIImage(named: "add")
                }else{
                    itemImage.kf_setImageWithURL(NSURL(string: self.item!["photos"][0]["url"].string!)!)
                }
                let itemTime = cell?.viewWithTag(2) as! UILabel
                itemTime.text = String(self.item!["date_y"].int!)
                let itemCity = cell?.viewWithTag(3) as! UILabel
                itemCity.text = self.item!["city"].string
                let itemOwner = cell?.viewWithTag(4) as! UIImageView
                let userAvatar = self.item!["hiwuUser"]["avatar"].string!
                itemOwner.kf_setImageWithURL(NSURL(string:userAvatar)!)
            return cell!
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemDescription")
                let itemName = cell?.viewWithTag(1) as! UILabel
                itemName.text = self.item!["name"].string
                let itemDescription = cell?.viewWithTag(2) as! UILabel
                itemDescription.text = self.item!["description"].string
                let addComment = cell?.viewWithTag(5) as! UIImageView
                let gesture = UITapGestureRecognizer(target: self, action: "toAddComment:")
                addComment.addGestureRecognizer(gesture)
                return cell!
            default :
                let cell = tableView.dequeueReusableCellWithIdentifier("Comments")
//                    let cell = tableView.dequeueReusableCellWithIdentifier("Comments")
//                let userName = cell?.viewWithTag(1) as! UILabel
//                let comment = cell?.viewWithTag(2) as! UILabel
//                userName.text = self.item!["nickname"].string! + "："
//                comment.text = self.item!["comments"][indexPath.row - 3].string!
                return cell!
        }
    }
    
    func toAddComment(sender:AnyObject){
        self.addComment.becomeFirstResponder()
        UIView.animateWithDuration(0.6, animations: {void in
            self.addComment.hidden = false
            self.ensureCommentButton.hidden = false
            self.itemDetailList.userInteractionEnabled = false
            self.itemDetailList.alpha = 0.4
            self.view.backgroundColor = UIColor.blackColor()
        })
    }
    
    func textViewDidBeginEditing(textView: UITextView){
        if(textView.text == "在这里添加评论"){
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        
    }
    
    func textViewDidEndEditing(textView: UITextView){
        if(textView.text == ""){
            textView.text = "在这里添加评论"
        }
        textView.textColor = UIColor.grayColor()
        textView.resignFirstResponder()
    }
    
    func endTheEditingOfTextView(){
        self.addComment.endEditing(true)
        UIView.animateWithDuration(0.6, animations: {void in
            self.itemDetailList.alpha = 1
            self.itemDetailList.userInteractionEnabled = true
            self.addComment.hidden = true
            self.ensureCommentButton.hidden = true
            self.view.backgroundColor = UIColor.whiteColor()
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

}
