/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

class Config : NSObject {

    var dateTimeMode: DateTimeMode = .WithTime

    // 週の開始日 : 日曜 - 0, 月曜 - 1
    var startOfWeek: Int = 0

    // 締め日 (1～29)、月末を指定する場合は 0
    var cutoffDate: Int = 0

    // 最後に選択されたレポート種別 (REPORT_DAILY/WEEKLY/MONTHLY/ANNUAL/...)
    var lastReportType: Int = 0

    // TouchID の使用
    var useTouchId: Bool = true

    private let KEY_DATE_TIME_MODE = "DateTimeMode"
    private let KEY_START_OF_WEEK = "StartOfWeek"
    private let KEY_CUTOFF_DATE = "CutoffDate"
    private let KEY_LAST_REPORT_TYPE = "LastReportType"
    private let KEY_USE_TOUCH_ID = "UseTouchId"

    private static var sConfig: Config? = nil

    static func instance() -> Config {
        if (sConfig == nil) {
            sConfig = Config()
        }
        return sConfig!
    }

    override init() {
        super.init()
        
        let defaults = NSUserDefaults.standardUserDefaults()
    
        let dtMode = defaults.integerForKey(KEY_DATE_TIME_MODE)
        self.dateTimeMode = DateTimeMode.init(rawValue: dtMode)!
        
        if (self.dateTimeMode != .DateOnly &&
            self.dateTimeMode != .WithTime &&
            self.dateTimeMode != .WithTime5min) {
                self.dateTimeMode = .WithTime
        }

        self.startOfWeek = defaults.integerForKey(KEY_START_OF_WEEK)
    
        self.cutoffDate = defaults.integerForKey(KEY_CUTOFF_DATE)
        if (self.cutoffDate < 0 || self.cutoffDate > 28) {
            self.cutoffDate = 0;
        }

        self.lastReportType = defaults.integerForKey(KEY_LAST_REPORT_TYPE)

        self.useTouchId = defaults.boolForKey(KEY_USE_TOUCH_ID)
    
        // 初期処理
        if (!self.useTouchId) {
            if (defaults.objectForKey(KEY_USE_TOUCH_ID) == nil) {
                self.useTouchId = true
                defaults.setBool(self.useTouchId, forKey:KEY_USE_TOUCH_ID)
                defaults.synchronize()
            }
        }
    }

    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()

        defaults.setInteger(self.dateTimeMode.rawValue, forKey:KEY_DATE_TIME_MODE)
        defaults.setInteger(self.startOfWeek, forKey:KEY_START_OF_WEEK)
        defaults.setInteger(self.cutoffDate, forKey:KEY_CUTOFF_DATE)
        defaults.setInteger(self.lastReportType, forKey:KEY_LAST_REPORT_TYPE)
        defaults.setBool(self.useTouchId, forKey:KEY_USE_TOUCH_ID)

        defaults.synchronize()
    }
}

