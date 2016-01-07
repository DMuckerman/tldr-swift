//
//  ViewController.swift
//  tldr
//
//  Created by Daniel Muckerman on 1/3/16.
//  Copyright © 2016 Daniel Muckerman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var commands: [String: [JSON]] = [:]
    var items: [String] = []
    let textCellIdentifier = "TextCell"
    var defaultOS = "0"
    var isDarkTheme = false
    
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var markdownPage: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navBar: UINavigationBar!
    
    // Inital loading upon application launch, or reloading after killed from memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Parse json file into commands dictionary
        if let path = NSBundle.mainBundle().pathForResource("pages/index", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let jsonObj = JSON(data: data)["commands"];
                if jsonObj != JSON.null {
                    //If json is .Dictionary
                    for (_,subJson):(String, JSON) in jsonObj {
                        //Do something you want
                        let name = subJson["name"].string
                        let platform = subJson["platform"].array
                        commands[name!] = platform
                    }
                } else {
                    print("could not get json from file, make sure that file contains valid json.")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        
        // Register platforms tableview
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Load an empty page into the webview by default
        markdownPage.loadHTMLString("", baseURL: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if (isDarkTheme) {
            return UIStatusBarStyle.LightContent
        }
        return UIStatusBarStyle.Default
    }
    
    
    // When the application takes focus
    func applicationActivated(notification: NSNotification) {
        textInput.resignFirstResponder()
        
        // Load user defaults
        // Done here so they can refresh when the user switches back
        if (NSUserDefaults.standardUserDefaults().valueForKey("defaultOS") != nil) {
            defaultOS = NSUserDefaults.standardUserDefaults().valueForKey("defaultOS") as! String
        }
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("isDarkTheme") != nil) {
            isDarkTheme = NSUserDefaults.standardUserDefaults().valueForKey("isDarkTheme") as! Bool
        }
        
        if (isDarkTheme) {
            textInput.keyboardAppearance = UIKeyboardAppearance.Dark;
            //navBar.barStyle = UIBarStyle.Black
            navBar.barTintColor = UIColor ( red: 0.349, green: 0.349, blue: 0.349, alpha: 1.0 )
            self.view.backgroundColor = UIColor ( red: 0.3882, green: 0.3882, blue: 0.3882, alpha: 1.0 )
            textInput.backgroundColor = UIColor ( red: 0.5412, green: 0.5412, blue: 0.5412, alpha: 1.0 )
            textInput.textColor = UIColor.whiteColor()
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            navBar.tintColorDidChange()
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.setNeedsDisplay()
            self.tableView.reloadData()
        } else {
            textInput.keyboardAppearance = UIKeyboardAppearance.Light;
            //navBar.barStyle = UIBarStyle.Default
            navBar.barTintColor = UIColor ( red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0 )
            self.view.backgroundColor = UIColor ( red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0 )
            textInput.backgroundColor = UIColor.whiteColor()
            textInput.textColor = UIColor.blackColor()
            UIApplication.sharedApplication().statusBarStyle = .Default
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.setNeedsDisplay()
            self.tableView.reloadData()
        }
        
        textInput.becomeFirstResponder()
    }
    
    // TableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = items[row]
        
        if (isDarkTheme) {
            cell.backgroundColor = UIColor ( red: 0.3882, green: 0.3882, blue: 0.3882, alpha: 1.0 )
            cell.textLabel?.textColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor ( red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0 )
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        
        var frame = tableView.frame
        frame.size.height = tableView.contentSize.height
        tableView.frame = frame
        tableViewHeight.constant = tableView.frame.size.height
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        textInput.endEditing(true)
        
        let row = indexPath.row
        let path = "pages/\(items[row])/\(textInput.text!)"
        loadMarkdown(path)
    }
    
    // Load the markdown page based on the given path
    func loadMarkdown(path: String) {
        // Create Markingbird object
        var markdown = Markdown()
        
        if let path = NSBundle.mainBundle().pathForResource(path, ofType: "md") {
            do {
                let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                let styled = "<head>\n\t<style>\n\tbody {\n\t\tfont-size: 1.05em !important;\n\t\tmargin-top: 0.5em !important; }\n\t\n\tp {\n\t\tmargin: 0 !important; }\n\th1 {\n\t\tfont-size: 2em !important;\n\t\tmargin: 0 0.23em; }\n\t\n\tblockquote {\n\t\tmargin: 0 0.55em; }\n\t\n\tcode {\n\t\tfont-family: \"Source Code Pro\", courier new, courier;\n\t\tbackground-color: #f2f2f2;\n\t\tcolor: #212121;\n\t\tdisplay: block;\n\t\tfont-size: 0.9em !important;\n\t\tpadding: 0.55em 1.25em;\n\t\tmargin: 0; }\n\t\n\tul {\n\t\tlist-style: none;\n\t\tpadding: 0 !important;\n\t\tmargin: 1em 0 0 0; }\n\t\n\tul li {\n\t\tpadding: 0.5em 0.55em;\n\t\tline-height: 1.1; }\n\t@media only screen and (orientation: landscape) {\n\t\tbody {\n\t\t\tmargin-top: 5em; } }\n\t@media only screen and (min-device-width: 1024px) {\n\t\tbody {\n\t\t\tfont-size: 1em;\n\t\t\tmargin-top: 3em; }\n\t\tcode {\n\t\t\tpadding-left: 3em; }\n\t\tul {\n\t\t\tmargin-top: 1em; }\n\t\tage ul li:before {\n\t\t\tcontent: \"*\";\n\t\t\tpadding: 0 12px; } }\n\t</style>\n</head>\n<body>" + markdown.transform(text2 as String) + "</body>"
                markdownPage.loadHTMLString(styled, baseURL: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    // Load notifications on view's appearance
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForNotifications()
    }
    
    // Unload notifications on view's disappearance
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.deregisterFromNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Register for notifications
    func registerForNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationActivated:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // Deregister for notifications
    func deregisterFromNotifications () -> Void {
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        center.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // Selector for keyboard shown notification
    func keyboardWasShown (notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue
        
        let insets: UIEdgeInsets = UIEdgeInsetsMake(markdownPage.scrollView.contentInset.top, 0, keyboardSize!.height, 0)
        
        markdownPage.scrollView.contentInset = insets
        markdownPage.scrollView.scrollIndicatorInsets = insets
        
        if (items.count > 1) {
            tableView.hidden = false
        }
    }
    
    // Selector for keyboard hidden notification
    func keyboardWillBeHidden (notification: NSNotification) {
        let insets: UIEdgeInsets = UIEdgeInsetsMake(markdownPage.scrollView.contentInset.top, 0, 0, 0)
        
        markdownPage.scrollView.contentInset = insets
        markdownPage.scrollView.scrollIndicatorInsets = insets
        tableView.hidden = true
    }
    
    // Every time the search textfield updates
    @IBAction func didSearch(sender: UITextField) {
        // Fix markdown page offset
        markdownPage.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        // Get the platforms for the current command
        var result = commands[sender.text!]
        if (result != nil) { // If the platforms list isn't nil
            // Empty the platforms tableview
            items.removeAll()
            
            // Fill in the tableview with the platforms from the result
            if (result!.count > 1) { // Only if there's more than 1 result
                tableView.hidden = false
                for item in result! {
                    items.append(item.string!)
                }
            } else { // If there's only 1 result, hide the tableview
                tableView.hidden = true
            }
            
            // Reload the tableview
            self.tableView.reloadData()
            
            // Load the tldr page
            var path = ""
            if (defaultOS == "1" && result!.contains("osx")) { // OS X
                path = "pages/osx/\(sender.text!)"
            } else if (defaultOS == "2" && result!.contains("linux")) { // OS X
                path = "pages/linux/\(sender.text!)"
            } else {
                path = "pages/\(result![0])/\(sender.text!)"
            }
            loadMarkdown(path)
        } else {
            // Load an empty page
            markdownPage.loadHTMLString("", baseURL: nil)
            
            // Make sure the platforms list is empty
            items.removeAll()
            
            // Update the tableview
            self.tableView.reloadData()
        }
    }
    
}

