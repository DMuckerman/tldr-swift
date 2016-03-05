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

class ViewController: UIViewController {
    var commands: [String: [JSON]] = [:]
    var items: [String] = []
    let textCellIdentifier = "TextCell"
    var defaultOS = "1"
    var isDarkTheme = false
    var highlightColor = "#DB3929"
    
    /* Base 16 Ocean
    let darkBackground = "#2B303B"
    let darkForeground = "#343D46"
    let lightBackground = "#EFF1F5"
    let lightForeground = "#DFE1E8"
    */
    
    /* Base 16 Monokai
    let darkBackground = "#272822"
    let darkForeground = "#383830"
    let lightBackground = "#F9F8F5"
    let lightForeground = "#F8F8F2"
    */
    
    // Base 16 Solarized
    let darkBackground = "#002B37"
    let darkForeground = "#063643"
    let lightBackground = "#FDF6E2"
    let lightForeground = "#EEE8D4"
    
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var markdownPage: UIWebView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var stackView: UIStackView!
    
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
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("highlightColor") != nil) {
            highlightColor = NSUserDefaults.standardUserDefaults().valueForKey("highlightColor") as! String
        }
        
        if (isDarkTheme) {
            textInput.keyboardAppearance = UIKeyboardAppearance.Dark;
            markdownPage.backgroundColor = UIColor ( red: 0.0, green: 0.1686, blue: 0.2196, alpha: 1.0 )
            navBar.barTintColor = UIColor ( red: 0.349, green: 0.349, blue: 0.349, alpha: 1.0 )
            self.view.backgroundColor = UIColor ( red: 0.3882, green: 0.3882, blue: 0.3882, alpha: 1.0 )
            textInput.backgroundColor = UIColor ( red: 0.5412, green: 0.5412, blue: 0.5412, alpha: 1.0 )
            textInput.textColor = UIColor.whiteColor()
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            navBar.tintColorDidChange()
            self.setNeedsStatusBarAppearanceUpdate()
            loadPage(commands[textInput.text!], text: textInput.text!)
        } else {
            textInput.keyboardAppearance = UIKeyboardAppearance.Light;
            markdownPage.backgroundColor = UIColor ( red: 0.9922, green: 0.9647, blue: 0.8824, alpha: 1.0 )
            navBar.barTintColor = UIColor ( red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0 )
            self.view.backgroundColor = UIColor ( red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0 )
            textInput.backgroundColor = UIColor.whiteColor()
            textInput.textColor = UIColor.blackColor()
            UIApplication.sharedApplication().statusBarStyle = .Default
            self.setNeedsStatusBarAppearanceUpdate()
            loadPage(commands[textInput.text!], text: textInput.text!)
        }
        
        textInput.becomeFirstResponder()
    }
    
    // Load the markdown page based on the given path
    func loadMarkdown(path: String) {
        // Create Markingbird object
        var markdown = Markdown()
        
        if let path = NSBundle.mainBundle().pathForResource(path, ofType: "md") {
            do {
                let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                var styled = ""
                if (isDarkTheme) {
                    styled = "<head>\n\t<style>\n\tbody {\n\t\tfont-size: 1.05em !important;\n\t\tmargin-top: 0.5em !important;\n\t\tbackground-color: " + darkBackground + " !important;\n\t\tcolor: #C0C5CE !important;\n\t\tfont-family: -apple-system, Helvetica, Arial, sans-serif;}\n\t\n\tp {\n\t\tmargin: 0 !important; }\n\th1 {\n\t\tfont-size: 2em !important;\n\t\tmargin: 0 0.23em; }\n\t\n\tblockquote {\n\t\tmargin: 0 0.55em; }\n\t\n\tcode {\n\t\tfont-family: \"Menlo\", courier new, courier;\n\t\tbackground-color: " + darkForeground + ";\n\t\tcolor: " + highlightColor + ";\n\t\tdisplay: block;\n\t\tfont-size: 0.9em !important;\n\t\tpadding: 0.55em 1.25em;\n\t\tmargin: 0; }\n\t\n\tul {\n\t\tlist-style: none;\n\t\tpadding: 0 !important;\n\t\tmargin: 1em 0 0 0; }\n\t\n\tul li {\n\t\tpadding: 0.5em 0.55em;\n\t\tline-height: 1.1; }\n\t@media only screen and (orientation: landscape) {\n\t\tbody {\n\t\t\tmargin-top: 5em; } }\n\t@media only screen and (min-device-width: 1024px) {\n\t\tbody {\n\t\t\tfont-size: 1em;\n\t\t\tmargin-top: 3em; }\n\t\tcode {\n\t\t\tpadding-left: 3em; }\n\t\tul {\n\t\t\tmargin-top: 1em; }\n\t\tage ul li:before {\n\t\t\tcontent: \"*\";\n\t\t\tpadding: 0 12px; } }\n\t</style>\n</head>\n<body>" + markdown.transform(text2 as String) + "</body>"
                } else {
                    styled = "<head>\n\t<style>\n\tbody {\n\t\tfont-size: 1.05em !important;\n\t\tmargin-top: 0.5em !important;\n\t\tbackground-color: " + lightBackground + " !important;\n\t\tcolor: #4F5B67 !important;\n\t\tfont-family: -apple-system, Helvetica, Arial, sans-serif;}\n\t\n\tp {\n\t\tmargin: 0 !important; }\n\th1 {\n\t\tfont-size: 2em !important;\n\t\tmargin: 0 0.23em; }\n\t\n\tblockquote {\n\t\tmargin: 0 0.55em; }\n\t\n\tcode {\n\t\tfont-family: \"Menlo\", courier new, courier;\n\t\tbackground-color: " + lightForeground + ";\n\t\tcolor: " + highlightColor + ";\n\t\tdisplay: block;\n\t\tfont-size: 0.9em !important;\n\t\tpadding: 0.55em 1.25em;\n\t\tmargin: 0; }\n\t\n\tul {\n\t\tlist-style: none;\n\t\tpadding: 0 !important;\n\t\tmargin: 1em 0 0 0; }\n\t\n\tul li {\n\t\tpadding: 0.5em 0.55em;\n\t\tline-height: 1.1; }\n\t@media only screen and (orientation: landscape) {\n\t\tbody {\n\t\t\tmargin-top: 5em; } }\n\t@media only screen and (min-device-width: 1024px) {\n\t\tbody {\n\t\t\tfont-size: 1em;\n\t\t\tmargin-top: 3em; }\n\t\tcode {\n\t\t\tpadding-left: 3em; }\n\t\tul {\n\t\t\tmargin-top: 1em; }\n\t\tage ul li:before {\n\t\t\tcontent: \"*\";\n\t\t\tpadding: 0 12px; } }\n\t</style>\n</head>\n<body>" + markdown.transform(text2 as String) + "</body>"
                }
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
        //tableView.hidden = true
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationActivated:", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // Deregister for notifications
    func deregisterFromNotifications () -> Void {
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        center.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // Selector for keyboard shown notification
    func keyboardWasShown (notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            // Adjust keyboard size properly
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: (UIScreen.mainScreen().bounds.height - keyboardSize.origin.y)
                , right: 0)
            
            markdownPage.scrollView.contentInset = contentInsets
            markdownPage.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    // Selector for keyboard shown notification
    func keyboardWillShow (notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.size.height, right: 0)
            
            markdownPage.scrollView.contentInset = contentInsets
            markdownPage.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    // Selector for keyboard hidden notification
    func keyboardWillBeHidden (notification: NSNotification) {
        let insets: UIEdgeInsets = UIEdgeInsetsMake(markdownPage.scrollView.contentInset.top, 0, 0, 0)
        
        markdownPage.scrollView.contentInset = insets
        markdownPage.scrollView.scrollIndicatorInsets = insets
    }
    
    // Every time the search textfield updates
    @IBAction func didSearch(sender: UITextField) {
        // Fix markdown page offset
        markdownPage.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        // Get the platforms for the current command
        loadPage(commands[sender.text!], text: sender.text!)
    }
    
    func loadPage(result: [JSON]?, text: String) {
        // Get the platforms for the current command
        if (result != nil) { // If the platforms list isn't nil
            // Empty the platforms tableview
            items.removeAll()
            
            // Load the tldr page
            var path = ""
            if (defaultOS == "1" && result!.contains("osx")) { // OS X
                path = "pages/osx/\(text)"
            } else if (defaultOS == "2" && result!.contains("linux")) { // Linux
                path = "pages/linux/\(text)"
            } else {
                path = "pages/\(result![0])/\(text)"
            }
            loadMarkdown(path)
        } else {
            // Load an empty page
            if(isDarkTheme) {
                markdownPage.backgroundColor = UIColor.clearColor()
                markdownPage.loadHTMLString("<head>\n\t<style>\n\tbody {\n\t\tfont-size: 1.05em !important;\n\t\tmargin-top: 0.5em !important;\n\t\tbackground-color: " + darkBackground + " !important;\n\t\tcolor: #C0C5CE !important;\n\t\tfont-family: -apple-system, Helvetica, Arial, sans-serif;}\n\t</style>\n</head>\n<body>\n</body>", baseURL: nil)
            } else {
                markdownPage.backgroundColor = UIColor.clearColor()
                markdownPage.loadHTMLString("<head>\n\t<style>\n\tbody {\n\t\tfont-size: 1.05em !important;\n\t\tmargin-top: 0.5em !important;\n\t\tbackground-color: " + lightBackground + " !important;\n\t\tcolor: #4F5B67 !important;\n\t\tfont-family: -apple-system, Helvetica, Arial, sans-serif;}\n\t</style>\n</head>\n<body>\n</body>", baseURL: nil)
            }
            
            // Make sure the platforms list is empty
            items.removeAll()
        }
    }
    
    // Creates a UIColor from a Hex string.
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
}

