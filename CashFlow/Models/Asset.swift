/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

//
// 資産 (総勘定元帳の勘定に相当)
// 
class Asset : AssetBase {
    //@property (nonatomic, readonly) NSInteger entryCount;
    //@property (nonatomic, readonly) double lastBalance;

    private var entries: [AssetEntry] = []

    static let typeNamesArray: [String] = [
        _L("Cash"),
        _L("Bank Account"),
        _L("Credit Card"),
        _L("Investment Account"),
        _L("Electric Money")
    ]

    static func numAssetTypes() -> Int {
        return typeNamesArray.count
    }
    
    static func typeNameWithType(type: Int) -> String {
        if type < 0 || type >= typeNamesArray.count {
            print("WARNING: typeNameWithType: type out of range")
            return "???"
        }
        return typeNamesArray[type]
    }

    static func iconNameWithType(type: Int) -> String {
        switch (type) {
        case AssetType.Cash.rawValue:
            return "cash"
        case AssetType.Bank.rawValue:
            return "bank"
        case AssetType.Card.rawValue:
            return "card"
        case AssetType.Invest.rawValue:
            return "invest"
        case AssetType.Emoney.rawValue:
            return "cash"
            //return @"emoney";
        default:
            return "???" // never happen
        }
    }

    override init() {
        super.init()
        
        self.type = AssetType.Cash.rawValue
    }

    /**
     * 仕訳帳(journal)から転記しなおす
     */
    func rebuild() {
        self.entries = []

        var balance = self.initialBalance

        for t in DataModel.getJournal().entries {
            if t.asset == self.pid || t.dstAsset == self.pid {
                let e = AssetEntry(transaction: t, asset: self)

                // 残高計算
                if t.etype == .Adj && t.hasBalance {
                    // 残高から金額を逆算
                    let oldval = t.value
                    t.value = t.balance - balance
                    if (t.value != oldval) {
                        // 金額が変更された場合、DBを更新
                        t.save()
                    }
                    balance = t.balance

                    e.value = t.value
                    e.balance = balance
                }
                else {
                    balance = balance + e.value
                    e.balance = balance

                    if t.etype == .Adj {
                        t.balance = balance
                        t.hasBalance = true
                    }
                }

                self.entries.append(e)
            }
        }

        //mLastBalance = balance;
    }

    func updateInitialBalance() {
        self.save()
    }

    
    // MARK: - AssetEntry operations

    var entryCount: Int {
        get {
            return self.entries.count
        }
    }

    func entryAt(n: Int) -> AssetEntry {
        return self.entries[n]
    }

    func insertEntry(entry: AssetEntry) {
        DataModel.getJournal().insertTransaction(entry.transaction()!)
        DataModel.getLedger().rebuild()
    }

    func replaceEntryAtIndex(index: Int, withObject entry:AssetEntry) {
        let orig = self.entryAt(index)

        DataModel.getJournal().replaceTransaction(orig.transaction()!, to: entry.transaction()!)
        DataModel.getLedger().rebuild()
    }

    // エントリ削除
    // 注：entries からは削除されない。journal から削除されるだけ
    private func _deleteEntryAt(index: Int) {
        // 先頭エントリ削除の場合は、初期残高を変更する
        if (index == 0) {
            self.initialBalance = self.entryAt(0).balance
            self.updateInitialBalance()
        }

        // エントリ削除
        let entry = self.entryAt(index)
        DataModel.getJournal().deleteTransaction(entry.transaction()!, asset: self)
    }

    // エントリ削除
    func deleteEntryAt(index: Int) {
        self._deleteEntryAt(index)
    
        // 転記し直す
        DataModel.getLedger().rebuild()
    }

    // 指定日以前の取引をまとめて削除
    func deleteOldEntriesBefore(date: NSDate) {
        let db = Database.instance()

        db.beginTransaction()
        while self.entries.count > 0 {
            let e = self.entries[0]
            if e.transaction()!.date.compare(date) != NSComparisonResult.OrderedAscending {
                break
            }

            self._deleteEntryAt(0)
            self.entries.removeAtIndex(0)
        }
        db.commitTransaction()

        DataModel.getLedger().rebuild()
    }

    func firstEntryByDate(date: NSDate) -> Int {
        for (idx, entry) in self.entries.enumerate() {
            if entry.transaction()!.date.compare(date) != NSComparisonResult.OrderedAscending {
                return idx
            }
        }
        return -1
    }

    ////////////////////////////////////////////////////////////////////////////
    // MARK: - Balance operations

    var lastBalance: Double {
        get {
            return _lastBalance()
        }
    }
    
    private func _lastBalance() -> Double {
        let max = self.entries.count
        if max == 0 {
            return self.initialBalance
        }
        return self.entries[max - 1].balance
    }

    //
    // Database operations
    //
    override static func migrate() -> Bool {
        let ret = AssetBase.migrate()
    
        if (ret) {
            // 初期アセット
            let asset = Asset()
            asset.name = "Cash"
            asset.type = AssetType.Cash.rawValue
            asset.initialBalance = 0
            asset.sorder = 0
            asset.save()
        }
        return ret
    }
}
