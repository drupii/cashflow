// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

/**
   各期間毎のレポートエントリ
*/
class ReportEntry : NSObject {

    /** 期間開始日 */
    private(set) var start: NSDate?

    /** 期間終了日 */
    private(set) var end: NSDate?
    
    /** 期間内の総収入 */
    private(set) var totalIncome: Double = 0.0

    /** 期間内の総支出 */
    private(set) var totalOutgo: Double = 0.0

    /** 収入の最大値 */
    private(set) var maxIncome: Double = 0.0

    /** 支出の最大値（絶対値の) */
    private(set) var maxOutgo: Double = 0.0

    /** カテゴリ毎の収入レポート */
    private(set) var incomeCatReports: [CatReport] = []

    /** カテゴリ毎の支出レポート */
    private(set) var outgoCatReports: [CatReport] = []

    /** 資産キー */
    private var assetKey: Int = 0

    /**
     イニシャライザ
     @param assetKey 資産キー (-1の場合は全資産)
     @param start 開始日
     @param end 終了日
    */
    init(asset: Int, start:NSDate?, end:NSDate?) {
        super.init()

        self.assetKey = asset
        self.start = start
        self.end = end

        self.totalIncome = 0.0
        self.totalOutgo = 0.0

        // カテゴリ毎のレポート (CatReport) の生成
        let categories = DataModel.instance().categories
        let numCategories = categories.count

        self.incomeCatReports = []
        self.outgoCatReports  = []

        for (var i = -1; i < numCategories; i++) {
            var catkey: Int
            var cr: CatReport

            if (i == -1) {
                catkey = -1; // 未分類項目用
            } else {
                catkey = categories.categoryAtIndex(i).pid
            }

            cr = CatReport(category:catkey, asset:assetKey)
            self.incomeCatReports.append(cr)

            cr = CatReport(category:catkey, asset:assetKey)
            self.outgoCatReports.append(cr)
        }
    }


    /**
      取引をレポートに追加
      @return NO - 日付範囲外, YES - 日付範囲ない、もしくは処理必要なし
     */
    func addTransaction(t: Transaction) -> Bool {
        // 資産 ID チェック
        var value: Double
        if (self.assetKey < 0) {
            // 資産指定なしレポートの場合、資産間移動は計上しない
            if (t.type == numericCast(TYPE_TRANSFER)) {
                return true
            }
            value = t.value;
        } else if t.asset == self.assetKey {
            // 通常または移動元
            value = t.value;
        } else if t.dstAsset == self.assetKey {
            // 移動先
            value = -t.value;
        } else {
            // 対象外
            return true
        }

        // 日付チェック
        var cpr: NSComparisonResult
        if let start = self.start {
            cpr = t.date.compare(start)
            if (cpr == NSComparisonResult.OrderedAscending) {
                return false
            }
        }
        if let end = self.end {
            cpr = t.date.compare(end)
            if (cpr == NSComparisonResult.OrderedSame || cpr == NSComparisonResult.OrderedDescending) {
                return false
            }
        }

        // 該当カテゴリを検索して追加
        var ary: [CatReport]
        if (value < 0) {
            ary = self.outgoCatReports;
        } else {
            ary = self.incomeCatReports;
        }
        for var cr in ary {
            if (cr.category == t.category) {
                cr.addTransaction(t)
                break;
            }
        }
        return true
    }

    /**
     ソートと集計
     */
    func sortAndTotalUp() {
        self.totalIncome = sortAndTotalUp(self.incomeCatReports)
        self.totalOutgo  = sortAndTotalUp(self.outgoCatReports)

        self.maxIncome = 0.0
        self.maxOutgo = 0.0
        var cr: CatReport
        if (self.incomeCatReports.count > 0) {
            cr = self.incomeCatReports[0]
            self.maxIncome = cr.sum
        }
        if (self.outgoCatReports.count > 0) {
            cr = self.outgoCatReports[0]
            self.maxOutgo = cr.sum;
        }
    }

    private func sortAndTotalUp(var ary: [CatReport]) -> Double {
        // 金額が 0 のエントリを削除する
        var count = ary.count;
        for (var i = 0; i < count; i++) {
            let cr = ary[i]
            if (cr.sum == 0.0) {
                ary.removeAtIndex(i)
                i--
                count--;
            }
        }

        // ソート
        ary.sortInPlace { (x, y) -> Bool in
            return sortCatReport(x, y:y)
        }

        // 集計
        var total = 0.0
        for var cr2 in ary {
            total += cr2.sum;
        }
        return total
    }

    /**
     CatReport 比較用関数 : 絶対値降順でソート
     */
    func sortCatReport(x: CatReport, y: CatReport) -> Bool {
        var xv = x.sum
        var yv = y.sum
        if (xv < 0) {
            xv = -xv
        }
        if (yv < 0) {
            yv = -yv
        }
	
        if (xv == yv) {
            return false
        }
        if (xv > yv) {
            return false
        }
        return true
    }
}
