//
//  MySQLDateFormatter.swift
//  HatenaExercise
//
//  Created by Takashi Nakagawa on 2014/06/06.
//  Copyright (c) 2014年 Takashi Nakagawa. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    class func MySQLDateFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "GMT")
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}