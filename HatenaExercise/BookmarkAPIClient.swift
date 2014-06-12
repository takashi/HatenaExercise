//
//  BookmarkAPIClient.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/06.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import Foundation

let BookmarkAPIBaseURLString = "http://localhost:3000"

class BookmarkAPIClient: AFHTTPSessionManager {
    var delegate: BookmarkAPIClientDelegate?
    
    class func loginURL() -> NSURL {
        return NSURL(string: BookmarkAPIBaseURLString + "/login")
    }
    
    
    
    class func sharedClient() -> BookmarkAPIClient {
        var instance: BookmarkAPIClient?
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = [
          "Accept": "application/json"
        ]
        var token : dispatch_once_t = 0
        dispatch_once(&token, {
            instance = BookmarkAPIClient(
                baseURL: NSURL(string: BookmarkAPIBaseURLString),
                sessionConfiguration: configuration
            )
        })
        return instance!
    }
    
    func needsLogin() -> Bool {
        self.delegate?.APIClientNeedsLogin(self)
        return true
    }
    
    func getBookmarks(perPage: UInt!, page: UInt!, completion block: (NSDictionary!, NSError!) -> ()) {
        self.GET("/api/bookmarks",
            parameters: [
                "per_page": perPage,
                "page": page
            ],
            success: { task, responseObject in
                if block != nil {
                    block(responseObject as NSDictionary, nil)
                }
            },
            failure: { task, error in
                if (task.response as NSHTTPURLResponse).statusCode == 401 && self.needsLogin() {
                    if block != nil {
                        block(nil, nil)
                    }
                }
                else {
                    if block != nil {
                        block(nil, error)
                    }
                }
            }
        )
    }
    
    func postBookmark(URL: NSURL, comment: NSString, completion block: (NSDictionary!, NSError!) -> ()){
        self.POST("/api/bookmark",
            parameters: [
                "url": URL.absoluteString,
                "comment": comment
            ],
            success: { task, responseObject in
                if block != nil {
                    block(responseObject as NSDictionary, nil)
                }
            },
            failure: { task, error in
                if (task.response as NSHTTPURLResponse).statusCode == 401 && self.needsLogin() {
                    if block != nil {
                        block(nil, nil)
                    }
                }
                else {
                    if block != nil {
                        block(nil, error)
                    }
                }
            }
        )
    }
        
}

protocol BookmarkAPIClientDelegate {
    func APIClientNeedsLogin(client: BookmarkAPIClient)
}
