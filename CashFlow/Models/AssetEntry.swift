// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

//
// 各資産（勘定）のエントリ
//
class AssetEntry : NSObject {
    var assetKey: Int = -1
    private var _transaction: Transaction = Transaction() // dummy
    var value: Double = 0.0
    var balance: Double = 0.0
    
    var evalue: Double {
        get {
            return self.getEvalue()
        }
        set(v) {
            self.setEvalue(v)
        }
    }

    // for search filter (TransactionListViewController)
    var originalIndex: Int = 0

    override init() {
        super.init()
    }

    convenience init(transaction: Transaction?, asset: Asset) {
        self.init()

        self.assetKey = asset.pid;
    
        if (transaction == nil) {
            // 新規エントリ生成
            self._transaction = Transaction()
            self._transaction.asset = self.assetKey
        }
        else {
            self._transaction = transaction!
            
            if (self.isDstAsset()) {
                self.value = -(_transaction.value)
            } else {
                self.value = _transaction.value
            }
        }
    }

    //
    // 資産間移動の移動先取引なら YES を返す
    //
    func isDstAsset() -> Bool {
        return self._transaction.type == numericCast(TYPE_TRANSFER) && self.assetKey == _transaction.dstAsset
    }

    // property transaction : read 処理
    func transaction() -> Transaction? {
        self._setupTransaction()
        return self._transaction;
    }

    // 値を Transaction に書き戻す
    private func _setupTransaction() {
        if (_transaction.type == numericCast(TYPE_ADJ)) {
            _transaction.balance = self.balance
            _transaction.hasBalance = true
        } else {
            _transaction.hasBalance = false
            if (self.isDstAsset()) {
                _transaction.value = -self.value;
            } else {
                _transaction.value = self.value;
            }
        }
    }

    // TransactionViewController 用の値を返す
    private func getEvalue() -> Double {
        var ret: Double = 0.0

        switch (_transaction.type) {
        case numericCast(TYPE_INCOME):
            ret = self.value;
            break;
        case numericCast(TYPE_OUTGO):
            ret = -self.value;
            break;
        case numericCast(TYPE_ADJ):
            ret = self.balance;
            break;
        case numericCast(TYPE_TRANSFER):
            if (self.isDstAsset()) {
                ret = self.value;
            } else {
                ret = -self.value;
            }
            break;
        default:
            // TODO
            break
        }
	
        if (ret == 0.0) {
            ret = 0.0;	// avoid '-0'
        }
        return ret;
    }

    // 編集値をセット
    private func setEvalue(v: Double) {
        switch (_transaction.type) {
        case numericCast(TYPE_INCOME):
            self.value = v;
            break;
        case numericCast(TYPE_OUTGO):
            self.value = -v;
            break;
        case numericCast(TYPE_ADJ):
            self.balance = v;
            break;
        case numericCast(TYPE_TRANSFER):
            if (self.isDstAsset()) {
                self.value = v;
            } else {
                self.value = -v;
            }
            break;
        default:
            // TODO:
            break
        }
    }

    // 種別変更
    //   type のほか、transaction の dst_asset, asset, value も調整する
    func changeType(type :Int, assetKey:Int, dstAssetKey:Int) -> Bool {
        if (type == numericCast(TYPE_TRANSFER)) {
            if (dstAssetKey == self.assetKey) {
                // 自分あて転送は許可しない
                // ### TBD
                return false
            }

            _transaction.type = numericCast(TYPE_TRANSFER)
            self.setDstAsset(dstAssetKey)
        } else {
            // 資産間移動でない取引に変更した場合、強制的に指定資産の取引に変更する
            var ev = self.evalue;
            _transaction.type = type
            _transaction.asset = assetKey
            _transaction.dstAsset = -1
            self.evalue = ev
        }
        return true
    }

    // 転送先資産のキーを返す
    func dstAsset() -> Int {
        if (_transaction.type != numericCast(TYPE_TRANSFER)) {
            //TODO: ASSERT(false)
            return -1;
        }

        if (self.isDstAsset()) {
            return _transaction.asset;
        }

        return _transaction.dstAsset;
    }

    func setDstAsset(asset: Int) {
        if (_transaction.type != numericCast(TYPE_TRANSFER)) {
            //TODO:ASSERT(NO);
            return
        }

        if (self.isDstAsset()) {
            _transaction.asset = asset
        } else {
            _transaction.dstAsset = asset
        }
    }
    
    func copyWithZone(zone: NSZone)-> AnyObject! {
        let e = AssetEntry()
        e.assetKey = self.assetKey;
        e.value = self.value;
        e.balance = self.balance;
        e._transaction = _transaction.copy() as! Transaction

        return e
    }
}
