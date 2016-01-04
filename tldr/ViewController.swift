//
//  ViewController.swift
//  tldr
//
//  Created by Daniel Muckerman on 1/3/16.
//  Copyright © 2016 Daniel Muckerman. All rights reserved.
//

import UIKit
//import SwiftyJSON

class ViewController: UIViewController {
    var commands: [String: [JSON]] = [:]

    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var markdownPage: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.deregisterFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForKeyboardNotifications ()-> Void   {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications () -> Void {
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown (notification: NSNotification) {
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue
        
//        let insets: UIEdgeInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, keyboardSize!.height, 0)
        
        let insets: UIEdgeInsets = UIEdgeInsetsMake(markdownPage.scrollView.contentInset.top, 0, keyboardSize!.height, 0)
        
        markdownPage.scrollView.contentInset = insets
        markdownPage.scrollView.scrollIndicatorInsets = insets
        
        //markdownPage.scrollView.contentOffset = CGPointMake(markdownPage.scrollView.contentOffset.x, markdownPage.scrollView.contentOffset.y)
    }
    
    func keyboardWillBeHidden (notification: NSNotification) {
        let insets: UIEdgeInsets = UIEdgeInsetsMake(markdownPage.scrollView.contentInset.top, 0, 0, 0)
        
        markdownPage.scrollView.contentInset = insets
        markdownPage.scrollView.scrollIndicatorInsets = insets
        
        //markdownPage.scrollView.contentOffset = CGPointMake(markdownPage.scrollView.contentOffset.x, markdownPage.scrollView.contentOffset.y)
    }

    @IBAction func didSearch(sender: UITextField) {
        print(sender.text!)
        markdownPage.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        var markdown = Markdown()
        var result = commands[sender.text!]
        print(result)
        if (result != nil) {
            print(result![0])
            let path = "pages/\(result![0])/\(sender.text!)"
            if let path = NSBundle.mainBundle().pathForResource(path, ofType: "md") {
                do {
                    let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                    let styled = "<head>\n\t<style>\n\tbody {\n\t\tfont-size: 1.05em !important;\n\t\tmargin-top: 0.5em !important; }\n\t\n\tp {\n\t\tmargin: 0 !important; }\n\th1 {\n\t\tfont-size: 2em !important;\n\t\tmargin: 0 0.23em; }\n\t\n\tblockquote {\n\t\tmargin: 0 0.55em; }\n\t\n\tcode {\n\t\tfont-family: \"Source Code Pro\", courier new, courier;\n\t\tbackground-color: #f2f2f2;\n\t\tcolor: #212121;\n\t\tdisplay: block;\n\t\tfont-size: 0.9em !important;\n\t\tpadding: 0.55em 1.25em;\n\t\tmargin: 0; }\n\t\n\tul {\n\t\tlist-style: none;\n\t\tpadding: 0 !important;\n\t\tmargin: 1em 0 0 0; }\n\t\n\tul li {\n\t\tpadding: 0.5em 0.55em;\n\t\tline-height: 1.1; }\n\t@media only screen and (orientation: landscape) {\n\t\tbody {\n\t\t\tmargin-top: 5em; } }\n\t@media only screen and (min-device-width: 1024px) {\n\t\tbody {\n\t\t\tfont-size: 1em;\n\t\t\tmargin-top: 3em; }\n\t\tcode {\n\t\t\tpadding-left: 3em; }\n\t\tul {\n\t\t\tmargin-top: 1em; }\n\t\tage ul li:before {\n\t\t\tcontent: \"*\";\n\t\t\tpadding: 0 12px; } }\n\t</style>\n</head>\n<body>" + markdown.transform(text2 as String) + "</body>"
                    markdownPage.loadHTMLString(styled, baseURL: nil)
                    print(styled)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else {
                print("Invalid filename/path.")
            }
        } else {
            markdownPage.loadHTMLString("", baseURL: nil)
        }
    }
    
}

