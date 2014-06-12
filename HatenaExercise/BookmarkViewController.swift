//
//  DetailViewController.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/06.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import UIKit

let keyBoardObserver: AnyObject!

class BookmarkViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate {

    @IBOutlet var URLField : UITextField
    @IBOutlet var commentField : UITextField
    @IBOutlet var webView : UIWebView
    @IBOutlet var keyboardHeight : NSLayoutConstraint
    
    var bookmark: Bookmark?
    var keyBoardObserver: AnyObject?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle!){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self.keyBoardObserver!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.bookmark!.entry.title
        
        self.URLField.text = self.bookmark!.entry.URL.absoluteString
        self.commentField.text = self.bookmark!.comment
        
        var request = NSURLRequest(URL: self.bookmark!.entry.URL)
        
        self.webView.loadRequest(request)
        
        self.keyBoardObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification,
            object: nil,
            queue: nil,
            usingBlock: { note in
                self.keyboardWillChangeFrame(note)
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        var keyboardRect : CGRect = notification.userInfo[UIKeyboardFrameEndUserInfoKey].CGRectValue()
        keyboardRect = self.view.convertRect(keyboardRect, fromView:nil)
        var animationDuration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey].doubleValue
        
        // キーボードの高さは画面の縦の長さからキーボードのy座標を引き算することで得られるはず.
        var keyboardHeight = self.view.bounds.size.height - keyboardRect.origin.y
        UIView.animateWithDuration(animationDuration, animations: { () in
            self.view.layoutIfNeeded()
        })
        
    }
    
    // #pragma mark - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.URLField {
            var URL = NSURL(string: textField.text)
            var request = NSURLRequest(URL: URL)
            self.webView.loadRequest(request)
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // #pragma mark - UIWebViewDelegate
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        self.URLField.text = request.URL.absoluteString
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        AFNetworkActivityIndicatorManager.sharedManager().incrementActivityCount()
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
        
        self.URLField.text = webView.request.URL.absoluteString
    }
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        AFNetworkActivityIndicatorManager.sharedManager().decrementActivityCount()
        if error.code != NSURLErrorCancelled {
            var alertView = UIAlertView(error: error)
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
    }

    @IBAction func save(sender : AnyObject) {
        var URL = NSURL(string: self.URLField.text)
        if URL == nil {
            return
        }
        var comment = self.commentField.text
        var entry = Entry(entryID: nil, URL: URL, title: nil, created: nil, updated: nil)
        var bookmark = Bookmark(bookmarkID: nil, comment: comment, entry: entry, user: nil, created: nil, updated: nil)
        
        BookmarkManager.sharedManager().saveBookmark(bookmark,
            withBlock: { error in
                if error {
                    NSLog("error = \(error)")
                }
                else {
                    // 保存が成功したら画面を戻す.
                    self.navigationController.popViewControllerAnimated(true)
                }
            
            }
        )
        
    }
    
    // #pragma mark - IBAction
    
    /* ログイン画面から戻ったとき呼ばれる */
    @IBAction func closeLoginSegue(segue: UIStoryboardSegue) {
        // ログインから戻ったら再読込する.
    }
}

