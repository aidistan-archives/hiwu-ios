//
//  AllTodays.swift
//  hiwu-ios
//
//  Created by 阮良 on 16/1/17.
//  Copyright © 2016年 Shanghai Hiwu Information Technology Co., Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher

class AllTodaysVC: UITableViewController {
    
    var today:JSON?
    
    var cellNumbers = 0
    
    var sections = 0
    var cellsInSection = 0
    
    let dates = NSMutableDictionary()
    let titles = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getDate()
        tableView.reloadData()
//        getTodayInfo()
//        tableView.hidden = true
    }
    
    func getDate(){
        for(var i=0;i<self.today!.count;i++){
            let tmpDate = String(self.today![i]["date_y"].int!) + String(self.today![i]["date_m"].int!)
            if(dates.valueForKey(tmpDate) == nil){
                dates.setValue(NSMutableArray(array: [i]), forKey: tmpDate)
                titles.addObject(tmpDate)
            }else{
                let museum = dates.valueForKey(tmpDate) as! NSMutableArray
                museum.addObject(i)
                dates.setValue(museum, forKey: tmpDate)
            }
        }
        print(dates)
        print(titles)
        tableView.reloadData()
    }
    
    func getTodayInfo(){
        let url = ApiManager.getTodayPublicView
        Alamofire.request(.GET, NSURL(string: url)!).responseJSON{response in
            if(response.result.value != nil){
                self.today = JSON(response.result.value!)
                self.getDate()
            }else{
                print(response.result.error)
            }
            
        }
        
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return dates.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let month = titles[section] as! String
        return (dates[month]?.count)!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(titles)
        let string = (titles[section]) as! NSString
        let year = string.substringToIndex(4)
        let month = string.substringFromIndex(4)
        return year + "年" + month + "月"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tmpDate = titles[indexPath.section] as! String
        let index = (dates[tmpDate] as! NSMutableArray)[indexPath.row] as! Int
        print(index)
        let tmpGallery = today![index]["gallery"]
        print(tmpGallery)
        let cell = tableView.dequeueReusableCellWithIdentifier("TodayCell")
        let avatar = cell?.viewWithTag(1) as! UIImageView
        avatar.kf_setImageWithURL(NSURL(string: tmpGallery["hiwuUser"]["avatar"].string! + "@!200x200")!)
        let name = cell?.viewWithTag(2) as! UILabel
        name.text = tmpGallery["hiwuUser"]["nickname"].string!
        let num = cell?.viewWithTag(3) as! UILabel
        num.text = String(tmpGallery["items"].count)
        return cell!
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
