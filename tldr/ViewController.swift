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

    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var markdownPage: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    
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
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print(items[row])
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
        
        let insets: UIEdgeInsets = UIEdgeInsetsMake(markdownPage.scrollView.contentInset.top, 0, keyboardSize!.height, 0)
        
        markdownPage.scrollView.contentInset = insets
        markdownPage.scrollView.scrollIndicatorInsets = insets
    }
    
    func keyboardWillBeHidden (notification: NSNotification) {
        let insets: UIEdgeInsets = UIEdgeInsetsMake(markdownPage.scrollView.contentInset.top, 0, 0, 0)
        
        markdownPage.scrollView.contentInset = insets
        markdownPage.scrollView.scrollIndicatorInsets = insets
    }

    @IBAction func didSearch(sender: UITextField) {
        //print(sender.text!)
        markdownPage.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        var markdown = Markdown()
        var result = commands[sender.text!]
        print(result)
        if (result != nil) {
            //print(result!)
            items.removeAll()
            for item in result! {
                items.append(item.string!)
            }
            print(items)
            self.tableView.reloadData()
            let path = "pages/\(result![0])/\(sender.text!)"
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
        } else {
            markdownPage.loadHTMLString("", baseURL: nil)
            items.removeAll()
            self.tableView.reloadData()
        }
    }
    
}

