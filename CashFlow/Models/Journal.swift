// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

//
// Journal : 仕訳帳
//

import Foundation

let MAX_TRANSACTIONS:Int = 50000

//
// 仕訳帳
// 
class Journal : NSObject {
    private(set) var entries: [Transaction] = []

    override init() {
        super.init()
    }

    func reload() {
        self.entries = Transaction.find_all("ORDER BY date, key")
    
        // upgrade data
        let db = Database.instance() as! CashflowDatabase
        if db.needFixDateFormat {
            self._sortByDate()
        
            db.beginTransaction()
            for t in self.entries {
                t.updateWithoutUpdateLRU()
            }
            db.commitTransaction()
        }
    }


    /**
     NSFastEnumeration protocol
     */
    /*
    - (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len
    {
        return [_entries countByEnumeratingWithState:state objects:stackbuf count:len];
    }
    */
    
    func insertTransaction(tr: Transaction) {
        var i: Int
        let max = self.entries.count

        // 挿入位置を探す
        for (i = 0; i < max; i++) {
            let t = self.entries[i]
            if (tr.date.compare(t.date) == NSComparisonResult.OrderedAscending) {
                break;
            }
        }

        // 挿入
        self.entries.insert(tr, atIndex: i)
        tr.save()

        // 上限チェック
        if (self.entries.count > MAX_TRANSACTIONS) {
            // 最も古い取引を削除する
            // Note: 初期残高を調整するため、Asset 側で削除させる
            let t = self.entries[0]
            let asset = DataModel.getLedger().assetWithKey(t.asset)
            asset!.deleteEntryAt(0)
        }
    }

    func replaceTransaction(from: Transaction, to: Transaction) {
        // copy key
        to.pid = from.pid

        // update DB
        to.save()

        let idx = self.entries.indexOf(from)
        self.entries[idx!] = to
        self._sortByDate()
    }
    
    /**
     * ソート
     */
    private func _sortByDate() {
        entries.sortInPlace {(x, y) -> Bool in
            x.date.compare(y.date) == NSComparisonResult.OrderedAscending
        }
    }

    private func transactionIndex(transaction: Transaction) -> Int {
        var i: Int = 0
        for t in self.entries {
            if (t.pid == transaction.pid) {
                return i
            }
            i++
        }
        return -1
    }
    
    /**
       Transaction 削除処理

       資産間移動取引の場合は、相手方資産残高が狂わないようにするため、
       相手方資産の入金・出金処理に置換する。

       @param t 取引
       @param asset 取引を削除する資産
       @return エントリが消去された場合は YES、置換された場合は NO。
    */
    func deleteTransaction(t: Transaction, asset: Asset) -> Bool {
        if (t.etype != .Transfer) {
            // 資産間移動取引以外の場合
            t.delete()
            self.entries.removeAtIndex(transactionIndex(t))
            return true
        }


        // 資産間移動の場合の処理
        // 通常取引 (入金 or 出金) に変更する
        if (t.asset == asset.pid) {
            // 自分が移動元の場合、移動方向を逆にする
            // (金額も逆転する）
            t.asset = t.dstAsset;
            t.value = -t.value;
        }
        t.dstAsset = -1;

        // 取引タイプを変更
        if (t.value >= 0) {
            t.etype = .Income
        } else {
            t.etype = .Outgo
        }

        // データベース書き換え
        t.save()
        return false
    }

    /**
     Asset に紐づけられた全 Transaction を削除する (Asset 削除用)
     */
    func deleteAllTransactionsWithAsset(asset: Asset) {
        var max = self.entries.count;

        for var i = 0; i < max; i++ {
            let t = self.entries[i];
            if (t.asset != asset.pid && t.dstAsset != asset.pid) {
                continue;
            }

            if (self.deleteTransaction(t, asset:asset)) {
                // エントリが削除された場合は、配列が一個ずれる
                i--;
                max--;
            }
        }
        // rebuild が必要!
    }
}

