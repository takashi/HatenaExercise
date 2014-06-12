//
//  Bookmark.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/06.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import Foundation

class Bookmark: NSObject {
    let bookmarkID: NSNumber
    let comment: NSString
    let entry: Entry
    let user: User
    let created: NSDate
    let updated: NSDate
    
    init(bookmarkID: NSNumber!, comment:NSString!, entry:Entry!, user:User!, created:NSDate!, updated:NSDate!) {
        self.bookmarkID = bookmarkID
        self.comment = comment
        self.entry = entry
        self.user = user
        self.created = created
        self.updated = updated
        super.init()
    }
    
    convenience init(json: NSDictionary!){
        var bookmarkID: NSNumber?
        if let bookmarkID_ = json["bookmark_id"] as? NSNumber {
            bookmarkID = bookmarkID_
        }
        
        var comment: NSString?
        if let comment_ = json["comment"] as? NSString {
            comment = comment_
        }
        
        var dateFormatter = NSDateFormatter.MySQLDateFormatter()
        
        var created: NSDate?
        if let createdString = json["created"] as? NSString {
            created = dateFormatter.dateFromString(createdString)
        }

        var updated: NSDate?
        if let updatedString = json["created"] as? NSString {
            updated = dateFormatter.dateFromString(updatedString)
            
        }
        
        var entry: Entry?
        if let entryDictionary = json["entry"] as? NSDictionary {
            entry = Entry(json: entryDictionary)
        }
        
        
        var user: User?
        if let userDictionary = json["user"] as? NSDictionary {
            user = User(json: userDictionary)
        }
        
        self.init(bookmarkID: bookmarkID!, comment:comment!, entry:entry!, user:user!, created:created!, updated:updated!)
        
    }
}
