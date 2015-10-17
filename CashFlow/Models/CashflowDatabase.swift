/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

public class CashflowDatabase: Database {

    private(set) var needFixDateFormat: Bool

    internal let dateFormatter1: NSDateFormatter
    private let dateFormatter2: DateFormatter2
    private let dateFormatter3: DateFormatter2

    static private var theInstance: CashflowDatabase?

    /**
     * 初期化
     */
    public static func instantiate() {
        let db = CashflowDatabase()
        theInstance = db
        Database._setInstance(db)
    }

    override public static func instance() -> CashflowDatabase {
        return theInstance!
    }
    
    override public init() {
        needFixDateFormat = false;
	
        let utc = NSTimeZone(abbreviation: "UTC")
        
        dateFormatter1 = NSDateFormatter()
        dateFormatter1.timeZone = utc
        dateFormatter1.dateFormat = "yyyyMMddHHmmss"
    
        // Set US locale, because JP locale for date formatter is buggy,
        // especially for 12 hour settings.
        let us = NSLocale(localeIdentifier: "US")
        dateFormatter1.locale = us

        // backward compat.
        dateFormatter2 = DateFormatter2()
        dateFormatter2.timeZone = utc
        dateFormatter2.dateFormat = "yyyyMMddHHmm"
    
        // for broken data...
        dateFormatter3 = DateFormatter2()
        dateFormatter3.timeZone = utc
        dateFormatter3.dateFormat = "yyyyMMdd"
    
        super.init()
    }

    override public func dateFromString(str: String) -> NSDate {
        var date: NSDate?

        if (str.characters.count == 14) { // yyyyMMddHHmmss
            date = dateFormatter1.dateFromString(str)
        }

        if (date == nil) {
            // backward compat.
            self.needFixDateFormat = true
            date = dateFormatter2.dateFromString(str)
        }
        if (date == nil) {
            date = dateFormatter3.dateFromString(str)
        }
        if (date == nil) {
            date = dateFormatter.dateFromString("20000101000000") // fallback
        }

        return date!
    }

    override public func stringFromDate(date: NSDate) -> String {
        let str = dateFormatter1.stringFromDate(date)
        return str
    }
}

