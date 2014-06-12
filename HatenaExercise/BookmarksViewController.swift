//
//  BookmarksViewController.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/06.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import UIKit

class BookmarksViewController: UITableViewController {
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        BookmarkManager.addObserver(self,
            forKeyPath: "bookmarks",
            options: NSKeyValueObservingOptions.New,
            context: nil)
        
        self.refreshControl.addTarget(self, action: Selector("refreshBookmarks"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshBookmarks(self)
    }
    
    deinit {
        BookmarkManager.sharedManager().removeObserver(self, forKeyPath: "bookmarks")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: NSDictionary!, context: CMutableVoidPointer) {
        if object as NSObject == BookmarkManager.sharedManager() && keyPath == "bookmarks" {
            var indexSet = change[NSKeyValueChangeIndexesKey] as NSIndexSet
            var changeKind = change[NSKeyValueChangeKindKey] as NSNumber
            var indexPaths: NSMutableArray?
            indexSet.enumerateIndexesUsingBlock(){ index, stop in
                indexPaths!.addObject(NSIndexPath(forRow: index, inSection: 0))
            }
            // `bookmarks` の変更の種類に合わせて TableView を更新.
            self.tableView.beginUpdates()
            
            if changeKind == NSKeyValueChange.Insertion.hashValue {
                self.tableView.insertRowsAtIndexPaths(indexPaths!, withRowAnimation: UITableViewRowAnimation.Automatic)
            } else if changeKind == NSKeyValueChange.Removal.hashValue {
                self.tableView.deleteRowsAtIndexPaths(indexPaths!, withRowAnimation: UITableViewRowAnimation.Automatic)
            } else if changeKind == NSKeyValueChange.Replacement.hashValue {
                self.tableView.reloadRowsAtIndexPaths(indexPaths!, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            self.tableView.endUpdates() // 更新終了
        }
        
    }
    
    func refreshBookmarks(id: AnyObject!) {
        self.refreshControl.beginRefreshing()
        BookmarkManager.sharedManager().reloadBookmarksWithBlock(){error in
            if error {
                NSLog("error = \(error)")
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "NewBookmarkSegue" {
            var bookmarkViewController = segue.destinationViewController as BookmarkViewController
        } else if segue.identifier == "OpenBookmarkSegue" {
            var bookmarkViewController = segue.destinationViewController as BookmarkViewController
            bookmarkViewController.bookmark = self.selectedBookmark()
        }
    }

    func selectedBookmark() -> Bookmark {
        var selectedIndexPath = self.tableView.indexPathForSelectedRow()
        var bookmarks = BookmarkManager.sharedManager().bookmarks
        return bookmarks![selectedIndexPath.row] as Bookmark
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BookmarkManager.sharedManager().bookmarks!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("IBKMBookmarkCell", forIndexPath: indexPath) as UITableViewCell
        var bookmark : Bookmark! = BookmarkManager.sharedManager().bookmarks![indexPath.row] as Bookmark
        if !bookmark {
            return cell
        }
        cell.textLabel.text = bookmark.entry.title
        cell.detailTextLabel.text = bookmark.comment

        return cell
    }
    
    /* Scroll View のスクロール状態に合わせて */
    override func scrollViewWillEndDragging(scrollView: UIScrollView?, withVelocity velocity: CGPoint, targetContentOffset: CMutablePointer<CGPoint>) {
        var offset: CGPoint =  UnsafePointer<CGPoint>(targetContentOffset).memory
        offset.y += self.tableView.bounds.size.height - 1.0 // offset は表示領域の上端なので, 下端にするため `tableView` の高さを付け足す. このとき 1.0 引くことであとで必ずセルのある座標になるようにしている.
        var indexPath = self.tableView.indexPathForRowAtPoint(offset)
        var bookmarkManger = BookmarkManager.sharedManager()
        bookmarkManger.loadMoreBookmarksWithBlock(){ error in
            if error {
                NSLog("error = \(error)")
            }
        }
    }
    
    /* ログイン画面から戻ったとき呼ばれる */
    @IBAction func closeLoginSegue(segue: UIStoryboardSegue) {
        // ログインから戻ったら再読込する.
        self.refreshBookmarks(self)
    }
}

