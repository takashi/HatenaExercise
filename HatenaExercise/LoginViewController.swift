//
//  LoginViewController.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/12.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView : UIWebView
    
    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = NSURLRequest(URL: BookmarkAPIClient.loginURL())
        self.webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        AFNetworkActivityIndicatorManager.sharedManager().incrementActivityCount()
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
    }
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
        if error.code != NSURLErrorCancelled {
            var alertView = UIAlertView(error: error)
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }
}
