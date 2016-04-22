//
//  SettingsViewController.swift
//  tldr
//
//  Created by Daniel Muckerman on 4/21/16.
//  Copyright © 2016 Daniel Muckerman. All rights reserved.
//

import UIKit

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
            } else {
                // Dark Theme Toggle!
                let switchView = UISwitch.init(frame: CGRect.zero)
                switchView.on = isDarkTheme
                switchView.addTarget(self, action: #selector(updateSwitchAtIndexPath), forControlEvents: UIControlEvents.TouchUpInside)
                cell.accessoryView = switchView
            }
        default: break
        }
        
        return cell
    }
    
    func updateSwitchAtIndexPath(sender: UISwitch) {
        NSLog("\(sender.on)")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(sender.on, forKey: "isDarkTheme")
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
