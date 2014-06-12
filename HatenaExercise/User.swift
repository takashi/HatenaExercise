//
//  User.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/06.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import Foundation

class User: NSObject {
    let userID: NSNumber
    let name: NSString
    let created: NSDate
    
    init(userID: NSNumber, name: NSString, created: NSDate) {
        self.userID = userID
        self.name = name
        self.created = created
        super.init()
    }
    
    convenience init(json: NSDictionary) {
        var userID: NSNumber?
        if let userID_ = json["user_id"] as? NSNumber {
            userID = userID_
        }
        
        var name: NSString?
        if let name_ = json["name"] as? NSString {
            name = name_
        }
        
        var dateFormatter = NSDateFormatter.MySQLDateFormatter()
        
        var created: NSDate?
        if let createdString = json["created"] as? NSString{
            created = dateFormatter.dateFromString(createdString)
        }
        
        self.init(userID: userID!, name: name!, created: created!)
    }
}
