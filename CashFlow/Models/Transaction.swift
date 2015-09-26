// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

class Transaction : TransactionBase, NSCopying {
    // for balance adjustment
    var hasBalance: Bool = false
    var balance: Double = 0.0

    override static func migrate() -> Bool {
        return TransactionBase.migrate()
    }

    override init() {
        super.init()

        self.asset = -1
        self.dstAsset = -1
    
        // 時刻取得
        var dt: NSDate = Transaction.lastUsedDate()
    
        if Config.instance().dateTimeMode == DateTimeMode.DateOnly {
            // 時刻を 0:00:00 に設定
            let greg = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let dc = greg.components([NSCalendarUnit.Year, .Month, .Day], fromDate: dt)
            dt = greg.dateFromComponents(dc)!
        }
    
        self.date = dt
        self.desc = ""
        self.memo = ""
        self.value = 0.0
        self.etype = TransactionType.Outgo
        self.category = -1
        self.hasBalance = false
    }

    convenience init(date: NSDate, description: String, value: Double) {
        self.init()

        self.asset = -1
        self.dstAsset = -1
        self.date = date
        self.desc = desc
        self.memo = ""
        self.value = value
        self.etype = TransactionType.Outgo
        self.category = -1
        self.pid = 0 // init
        self.hasBalance = false
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let n = Transaction()
        n.pid = self.pid
        n.asset = self.asset
        n.dstAsset = self.dstAsset
        n.date = self.date
        n.desc = self.desc
        n.memo = self.memo
        n.value = self.value
        n.type = self.type
        n.category = self.category
        n.hasBalance = self.hasBalance
        n.balance = self.balance
        return n
    }

    var etype: TransactionType {
        get {
            return TransactionType(rawValue: self.type)!
        }
        set(value) {
            self.type = value.rawValue
        }
    }

    override func _insert() {
        super._insert()
        DescLRUManager.addDescLRU(self.desc, category:self.category)
    }

    override func _update() {
        super._update()
        DescLRUManager.addDescLRU(self.desc, category:self.category)
    }

    func updateWithoutUpdateLRU() {
        super._update()
    }

    static func hasLastUsedDate() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let date = defaults.objectForKey("lastUsedDate")
        return date != nil
    }

    static func lastUsedDate() -> NSDate {
        let defaults = NSUserDefaults.standardUserDefaults()
        let date = defaults.objectForKey("lastUsedDate") as? NSDate
        if let d = date {
            return d
        } else {
            return NSDate() // 現在時刻
        }
    }

    static func setLastUsedDate(date: NSDate) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(date, forKey: "lastUsedDate")
        defaults.synchronize()
    }
}
