//
//  BookmarkManager.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/07.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import Foundation

let BookmarkManagerBookmarksPerPage: UInt = 20

class BookmarkManager: NSObject {
    var bookmarks: NSMutableArray?
    var nextPage: UInt?
    
    class func sharedManager() -> BookmarkManager! {
        var instance_:BookmarkManager?
    
        // @synchronized in obj-c
        let lockQueue = dispatch_queue_create("com.HatenaExercise", nil)
        dispatch_sync(lockQueue, {
            if instance_ != nil {
                instance_ = BookmarkManager()
            }
        })
        
        return instance_!
    }
    
    init() {
        self.bookmarks = nil
        self.nextPage = 1
        super.init()
    }
    
    func saveBookmark(bookmark: Bookmark, withBlock block: ((NSError!) -> ())!) {
        BookmarkAPIClient.sharedClient()
            .postBookmark(bookmark.entry.URL,
                comment: bookmark.comment,
                completion: { results, error in
                    if let bookmarkDictionary = results["bookmark"] as? NSDictionary {
                        var bookmarks = [Bookmark(json: bookmarkDictionary)]
                        var newBookmarks = self.updateBookmarks(bookmarks)
                        
                        self.mutableArrayValueForKey("bookmarks")
                            .insertObjects(newBookmarks, atIndexes: NSIndexSet(indexesInRange: NSMakeRange(0, newBookmarks.count)))
                    }
                    if block {
                        block(error)
                    }
 
                }
                
            )
    }
    
    func reloadBookmarksWithBlock(block: ((NSError!) -> ())!) {
        self.loadBookmarksWithPage(1 as UInt,
            completion: { bookmarks, nextPage, error in
                if bookmarks {
                    self.mutableArrayValueForKey("bookmarks")
                    .replaceObjectsInRange(NSMakeRange(0, self.bookmarks!.count), withObjectsFromArray: bookmarks)
                }
                if nextPage {
                    self.nextPage = UInt(nextPage)
                }
                if block {
                    block(error)
                }
            }
        )
    }
    
    func loadMoreBookmarksWithBlock(error block: (NSError!) -> Void) {
        var nextPage = UInt(self.nextPage!)
        loadBookmarksWithPage(nextPage,
            completion: { bookmarks, nextPage, error in
                if bookmarks != nil {
                    var newBookmarks = self.updateBookmarks(bookmarks)
                
                    self.mutableArrayValueForKey("bookmarks").addObjectsFromArray(newBookmarks)
                }
                if nextPage != nil {
                    self.nextPage = UInt(nextPage)
                }
                if block != nil {
                    block(error)
                }
            }
        )
    }
        
    
    func loadBookmarksWithPage(page: UInt, completion block: ((NSArray!, NSNumber!, NSError!) -> ())!) {
        BookmarkAPIClient.sharedClient().getBookmarks(
            BookmarkManagerBookmarksPerPage,
            page: page,
            completion: { (results, error) in
                var bookmarks: NSArray?
                var nextPage: UInt = 0
                if results {
                    if let bookmarksJSON = results["bookmarks"] as? NSArray {
                        bookmarks = self.parseBookmark(bookmarksJSON)
                    }
                    
                    if let nextPageNumber = results["next_page"] as? NSNumber {
                        nextPage = UInt(nextPageNumber)
                    }
                }
                
                if block {
                    block(bookmarks, nextPage, error)
                }
            })
    }
    
    func parseBookmark(bookmarks: NSArray!) -> NSArray {
        var mutableBookmarks = NSMutableArray()
        bookmarks.enumerateObjectsUsingBlock({ obj, idx, stop in
            if obj is NSDictionary {
                var bookmark = Bookmark(json: obj as NSDictionary)
                mutableBookmarks.addObject(bookmark)
            }

        })
        return mutableBookmarks.copy() as NSArray
    }

    func updateBookmarks(bookmarks: NSArray!) -> NSArray! {
        var newBookmarks = NSMutableArray()
        var updatedBookmarks = NSMutableArray()
        var indexSet = NSMutableIndexSet()
        
        bookmarks.enumerateObjectsUsingBlock({obj, idx, stop in
            var index = self.bookmarks!.indexOfObject(obj as Bookmark)
            if index == NSIntegerMax {
                newBookmarks.addObject(obj)
            }
            else {
                indexSet.addIndex(index)
                updatedBookmarks.addObject(obj)
            }
        })
        
        self.mutableArrayValueForKey("bookmarks").replaceObjectsAtIndexes(indexSet, withObjects: updatedBookmarks)
        
        return newBookmarks
    }
}
