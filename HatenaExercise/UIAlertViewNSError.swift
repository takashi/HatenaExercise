//
//  UIAlertViewNSError.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/07.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import Foundation

extension UIAlertView {
    convenience init(error: NSError) {
        self.init()
        self.title = error.localizedDescription
        self.message =  NSArray(objects: error.localizedFailureReason, error.localizedRecoverySuggestion).componentsJoinedByString("\n")
        var optionTitles = error.localizedRecoveryOptions
        for title : AnyObject in optionTitles {
            addButtonWithTitle(title as NSString)
        }
    }
}