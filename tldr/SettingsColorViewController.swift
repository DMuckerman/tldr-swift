//
//  SettingsViewController.swift
//  tldr
//
//  Created by Daniel Muckerman on 4/21/16.
//  Copyright © 2016 Daniel Muckerman. All rights reserved.
//

import UIKit

class SettingsColorViewController: UITableViewController {
    
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
        
        if (defaults.objectForKey("highlightColor") != nil) {
            // Load Highlight color
            highlightColor = defaults.objectForKey("highlightColor") as! String
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
            //cell.textLabel?.textColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
            //cell.textLabel?.textColor = UIColor.blackColor()
        }
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            let colorRow : Int = {
                switch highlightColor {
                    case "#DB3929": return 0
                    case "#CB4E02": return 1
                    case "#A97F00": return 2
                    case "#879800": return 3
                    case "#2EA098": return 4
                    case "#1A88D5": return 5
                    case "#6872C7": return 6
                    case "#D23D83": return 7
                    default: return 0
                }
            }()
            if (row == Int(colorRow)) {
                cell.accessoryType = .Checkmark
                
            } else {
                cell.accessoryType = .None
            }
        default: break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        highlightColor = {
            switch indexPath.row {
            case 0: return "#DB3929"
            case 1: return "#CB4E02"
            case 2: return "#A97F00"
            case 3: return "#879800"
            case 4: return "#2EA098"
            case 5: return "#1A88D5"
            case 6: return "#6872C7"
            case 7: return "#D23D83"
                default: return ""
            }
        }()
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(highlightColor, forKey: "highlightColor")
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
}
