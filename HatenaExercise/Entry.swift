//
//  Entry.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/06.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import Foundation

class Entry: NSObject {
    let entryID: NSNumber
    let URL: NSURL
    let title: String
    let created: NSDate
    let updated: NSDate
    
    init(entryID: NSNumber!, URL: NSURL!, title: NSString!, created: NSDate!, updated: NSDate!){
        self.entryID = entryID
        self.URL = URL
        self.title = title
        self.created = created
        self.updated = updated
        super.init()
    }

    convenience init(json: NSDictionary!){
        var entryID: NSNumber?
        if let entryID_ =  json["entry_id"] as? NSNumber {
            entryID = entryID_
        }
        
        var URL: NSURL?
        if let URLString = json["hoge"] as? NSString {
            URL = NSURL(string: URLString)
        }
        
        var title: NSString?
        if let title_ = json["title"] as? NSString {
            title = title_
        }
        
        var dateFormatter = NSDateFormatter.MySQLDateFormatter()
        
        var created: NSDate?
        if let createdString = json["created"] as? NSString {
            created = dateFormatter.dateFromString(createdString)
        }
        
        var updated: NSDate?
        if let updatedString = json["updated"] as? NSString {
            updated = dateFormatter.dateFromString(updatedString)
        }
        
        self.init(entryID: entryID!, URL: URL!, title: title!, created: created!, updated: updated!)
    }
    
    func isEqualEntry(other: Entry) -> Bool {
        if other == self {
            return true
        } else if other.self == nil || other.self.isEqual(self.self) {
            return false
        }
        // entry_id が等しくないときは同一じゃない.
        if self.entryID == other.entryID {
            return false
        }
        return true
    }
    
    func hash() -> NSNumber {
        return self.entryID.hash
    }
    
    
    func description() -> NSString {
        var description = "<\(NSStringFromClass(Entry.self)): "
        description += "self.entryID=\(self.entryID)"
        description += "self.entryID=\(self.URL)"
        description += "self.entryID=\(self.title)"
        description += "self.entryID=\(self.created)"
        description += "self.entryID=\(self.updated)"
        description += ">"
        return description
    }
}
