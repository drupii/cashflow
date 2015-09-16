// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

let REPORT_DAILY  = 0
let REPORT_WEEKLY = 1
let REPORT_MONTHLY  = 2
let REPORT_ANNUAL = 3

let MAX_REPORT_ENTRIES = 365

/**
 * レポートの構造
 * Report -> ReportEntry -> CatReport
 */

/**
 *  レポート
 */
class Report : NSObject {
    /** レポート種別 (REPORT_XXX) */
    var type: Int
    
    /** 期間毎の ReportEntry の配列 */
    var reportEntries: [ReportEntry]

    override init() {
        super.init()
        self.type = REPORT_MONTHLY;
        self.reportEntries = []
    }

    /**
     * レポート生成
     * @param type タイプ (REPORT_DAILY/WEEKLY/MONTHLY/ANNUAL)
     * @param asset 対象資産 (nil の場合は全資産)
     */
    func generate(type: Int, asset:Asset?) {
        self.type = type;
	
        self.reportEntries = []

        let greg = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
	
        // レポートの開始日と終了日を取得
        let assetKey = (asset != nil) ? asset!.pid : -1
        
        let firstDate = self.firstDateOfAsset(assetKey)
        if (firstDate == nil) {
            return // no data
        }
        let lastDate = self.lastDateOfAsset(assetKey)

        // レポート周期の開始時間および間隔を求める
        var nextStartDay: NSDate? = nil
        var dateComponents : NSDateComponents
	
        var steps = NSDateComponents()
        switch (self.type) {
            case REPORT_DAILY:
                dateComponents = greg.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: firstDate!)
                nextStartDay = greg.dateFromComponents(dateComponents)
                steps.day = 1
                break

            case REPORT_WEEKLY:
                dateComponents = greg.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Weekday, NSCalendarUnit.Day], fromDate:firstDate!)
                nextStartDay = greg.dateFromComponents(dateComponents)
            
                // 日曜が 1, 土曜が 7
                let weekday = dateComponents.weekday
            
                // 前週の指定曜日に設定
                steps.day = -(weekday - 1) - 7 + Config.instance().startOfWeek
            
                nextStartDay = greg.dateByAddingComponents(steps, toDate:nextStartDay!, options:[])
                steps.day = 7;
                break;

            case REPORT_MONTHLY:
                dateComponents = greg.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate:firstDate!)

                // 締め日設定
                let cutoffDate = Config.instance().cutoffDate
                if (cutoffDate == 0) {
                    // 月末締め ⇒ 開始は同月1日から。
                    dateComponents.day = 1;
                }
                else {
                    // 一つ前の月の締め日翌日から開始
                    var year = dateComponents.year;
                    var month = dateComponents.month;
                    month--
                    if (month < 1) {
                        month = 12
                        year--
                    }
                    dateComponents.year = year
                    dateComponents.month = month
                    dateComponents.day = cutoffDate + 1
                }

                nextStartDay = greg.dateFromComponents(dateComponents)
                steps.month = 1;
                break;
			
            case REPORT_ANNUAL:
                dateComponents = greg.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate:firstDate!)
                dateComponents.month = 1
                dateComponents.day = 1
                nextStartDay = greg.dateFromComponents(dateComponents)
                steps.year = 1;
                break;
            
            default:
                break
        }
	
        // レポートエントリを生成する
        while nextStartDay!.compare(lastDate!) != NSComparisonResult.OrderedDescending {
            var start = nextStartDay!

            // 次の期間開始時期を計算する
            nextStartDay = greg.dateByAddingComponents(steps, toDate:nextStartDay!, options:[])

            // Report 生成
            var r = ReportEntry(asset:assetKey, start:start, end:nextStartDay)
            self.reportEntries.append(r)

            // レポート上限数を制限
            if self.reportEntries.count > MAX_REPORT_ENTRIES {
                self.reportEntries.removeAtIndex(0)
            }
        }

        // 集計実行
        // 全取引について、該当する ReportEntry へ transaction を追加する
        for t in DataModel.journal().entries {
            for r in self.reportEntries {
                if r.addTransaction(t as! Transaction) {
                    break
                }
            }
        }
        for r in self.reportEntries {
            r.sortAndTotalUp()
        }
    }

    /**
     *レポート内の値の最大絶対値を得る
     */
    func getMaxAbsValue() -> Double {
        var maxAbsValue: Double = 1.0
        for var rep in self.reportEntries {
            if (rep.totalIncome > maxAbsValue) {
                maxAbsValue = rep.totalIncome
            }
            if (-rep.totalOutgo > maxAbsValue) {
                maxAbsValue = -rep.totalOutgo;
            }
        }
        return maxAbsValue;
    }


    /**
     * 指定された資産の最初の取引日を取得
     */
    private func firstDateOfAsset(asset: Int) -> NSDate? {
        let entries = DataModel.journal().entries

        var found: Transaction? = nil
        for t in entries {
            if (asset < 0) {
                found = t as! Transaction
                break
            }
            if (t.asset == asset || t.dstAsset == asset) {
                found = t as! Transaction
                break
            }
        }
        return found != nil ? found!.date : nil
    }

    /**
     * 指定された資産の最後の取引日を取得
     */
    private func lastDateOfAsset(asset: Int) -> NSDate? {
        let entries = DataModel.journal().entries

        var t: Transaction?
        var i: Int

        for (i = entries.count - 1; i >= 0; i--) {
            t = entries[i] as! Transaction
            if (asset < 0) {
                break
            }
            if (t!.asset == asset || t!.dstAsset == asset) {
                break
            }
        }
        if (i < 0) {
            return nil
        }
        return t!.date
    }
}
