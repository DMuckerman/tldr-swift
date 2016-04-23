//
//  SettingsViewController.swift
//  tldr
//
//  Created by Daniel Muckerman on 4/21/16.
//  Copyright © 2016 Daniel Muckerman. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class SettingsViewController: UITableViewController {
    
    var defaultOS = "1"
    var isDarkTheme = false
    var highlightColor = "#DB3929"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("isDarkTheme") != nil) {
            // Load Dark Theme!
            isDarkTheme = defaults.boolForKey("isDarkTheme")
        }
        
        if (defaults.objectForKey("defaultOS") != nil) {
            // Load Default OS
            defaultOS = defaults.objectForKey("defaultOS") as! String
        }
        
        if (defaults.objectForKey("highlightColor") != nil) {
            // Load Highlight Color
            highlightColor = defaults.objectForKey("highlightColor") as! String
        }
        
        applyTheme()
    }
    
    override func viewDidAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("isDarkTheme") != nil) {
            // Load Dark Theme!
            isDarkTheme = defaults.boolForKey("isDarkTheme")
        }
        
        if (defaults.objectForKey("defaultOS") != nil) {
            // Load Default OS
            defaultOS = defaults.objectForKey("defaultOS") as! String
        }
        
        if (defaults.objectForKey("highlightColor") != nil) {
            // Load Highlight Color
            highlightColor = defaults.objectForKey("highlightColor") as! String
        }
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissSettings(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        //cell.accessoryType = UITableViewCellAccessoryType.None
        
        if (isDarkTheme) {
            cell.backgroundColor = UIColor(red:0.09, green:0.13, blue:0.16, alpha:1.00)
            cell.textLabel?.textColor = UIColor.whiteColor()
            /*cell.tintColor = UIColor(red:0.72, green:0.75, blue:0.78, alpha:1.00)
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.detailTextLabel?.textColor = UIColor(red:0.50, green:0.53, blue:0.56, alpha:1.00)*/
        } else {
            cell.backgroundColor = UIColor.whiteColor()
            cell.textLabel?.textColor = UIColor.blackColor()
            /*cell.tintColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00)
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.00)*/
        }
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            cell.detailTextLabel?.text = defaultOS == "1" ? "OS X" : "Linux"
        case 1:
            if (row == 0) {
                let color : String = {
                    switch highlightColor {
                        case "#DB3929": return "Red"
                        case "#CB4E02": return "Orange"
                        case "#A97F00": return "Yellow"
                        case "#879800": return "Green"
                        case "#2EA098": return "Cyan"
                        case "#1A88D5": return "Blue"
                        case "#6872C7": return "Purple"
                        case "#D23D83": return "Pink"
                        default: return ""
                    }
                }()
                
                cell.detailTextLabel?.text = color
                cell.detailTextLabel?.textColor = UIColor(hexString: highlightColor)
            } else {
                // Dark Theme Toggle!
                let switchView = UISwitch.init(frame: CGRect.zero)
                switchView.on = isDarkTheme
                switchView.addTarget(self, action: #selector(updateSwitchAtIndexPath), forControlEvents: UIControlEvents.TouchUpInside)
                switchView.onTintColor = UIColor(red:0.60, green:0.76, blue:0.83, alpha:1.00)
                cell.accessoryView = switchView
            }
        default: break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.section == 2) {
            let url : NSURL = NSURL.init(string: UIApplicationOpenSettingsURLString)!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func updateSwitchAtIndexPath(sender: UISwitch) {
        NSLog("\(sender.on)")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: "isDarkTheme")
        isDarkTheme = sender.on
        applyTheme()
        self.tableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName("DidChangeThemeColor", object: nil)
    }
    
    func applyTheme() {
        if (isDarkTheme) {
            self.navigationController?.navigationBar.barTintColor = UIColor(red:0.17, green:0.24, blue:0.30, alpha:1.00)
            self.navigationController?.navigationBar.tintColor = UIColor(red:0.60, green:0.76, blue:0.83, alpha:1.00)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            self.navigationController?.navigationBar.tintColorDidChange()
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            self.parentViewController?.setNeedsStatusBarAppearanceUpdate()
            self.tableView.backgroundColor = UIColor(red:0.11, green:0.16, blue:0.20, alpha:1.00)
            self.tableView.separatorColor = UIColor(red:0.12, green:0.17, blue:0.20, alpha:1.00)
        } else {
            self.navigationController?.navigationBar.barTintColor = UIColor ( red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0 )
            self.navigationController?.navigationBar.tintColor = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.00)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
            self.navigationController?.navigationBar.tintColorDidChange()
            UIApplication.sharedApplication().statusBarStyle = .Default
            self.parentViewController?.setNeedsStatusBarAppearanceUpdate()
            self.tableView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.00)
            self.tableView.tableHeaderView?.tintColor = UIColor(red:0.43, green:0.43, blue:0.45, alpha:1.00)
            self.tableView.separatorColor = UIColor(red:0.78, green:0.78, blue:0.80, alpha:1.00)
        }
    }
    
    // MARK: - Table view data source
    
    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 3
     }
     
     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // #warning Incomplete implementation, return the number of rows
     return 0
     }*/

    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
     */

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
