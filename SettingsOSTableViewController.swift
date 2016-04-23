//
//  SettingsViewController.swift
//  tldr
//
//  Created by Daniel Muckerman on 4/21/16.
//  Copyright © 2016 Daniel Muckerman. All rights reserved.
//

import UIKit

class SettingsOSViewController: UITableViewController {
    
    var defaultOS = "1"
    var isDarkTheme = false
    
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
        
        applyTheme()
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
        
        if (isDarkTheme) {
            cell.backgroundColor = UIColor(red:0.09, green:0.13, blue:0.16, alpha:1.00)
            cell.textLabel?.textColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            if ((row + 1) == Int(defaultOS)) {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        default: break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defaultOS = String(indexPath.row + 1)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(defaultOS, forKey: "defaultOS")
        self.tableView.reloadData()
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
}
