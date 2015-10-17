// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

/**
   レポート(カテゴリ毎)

   本エントリは、期間(ReportEntry)毎、カテゴリ毎に１つ生成
*/
class CatReport : NSObject {

    /** カテゴリ (-1 は未分類) */
    private(set) var category: Int = 0

    /** 資産キー (-1 の場合は指定なし) */
    private(set) var assetKey: Int = 0

    /** 該当カテゴリ内の金額合計 */
    private(set) var sum: Double = 0.0

    /** 本カテゴリに含まれる Transaction 一覧 */
    private(set) var transactions: [Transaction] = []

    init(category: Int, asset:Int) {
        super.init()
        self.category = category
        self.assetKey = asset
    }


    func addTransaction(t: Transaction) {
        if (self.assetKey >= 0 && t.dstAsset == self.assetKey) {
            self.sum += -t.value; // 資産間移動の移動先
        } else {
            self.sum += t.value;
        }
        
        self.transactions.append(t)
    }

    func title() -> String {
        if (self.category < 0) {
            return NSLocalizedString("No category", comment:"")
        }
        return DataModel.getCategories().categoryStringWithKey(self.category)
    }
}
