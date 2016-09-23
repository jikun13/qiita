//
//  WebViewController.swift
//  QiitaApp
//
//  Created by Junki Takada on 2016/09/14.
//  Copyright © 2016年 Junki Takada. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var articleUrl :String?

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let articleUrl = articleUrl {
            if let url = NSURL(string: articleUrl) {
                let request = NSURLRequest(URL: url)
                webView.loadRequest(request)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        let shareText = ""
        let shareUrl = NSURL(string: self.articleUrl!)!
        let activityItems = [shareText, shareUrl]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
//        let excludedActivityTypes = [
//            UIActivityTypePostToTwitter
//        ]
//        
//        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
}
