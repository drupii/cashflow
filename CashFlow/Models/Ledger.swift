// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// 総勘定元帳
import Foundation

class Ledger : NSObject {
    private(set) var assets: [Asset] = []
    
    var assetCount: Int {
        get {
            return self.assets.count
        }
    }

    override init() {
        super.init()
    }
    
    func load() {
        self.assets = Asset.find_all("ORDER BY sorder")
    }

    func rebuild() {
        for asset in self.assets {
            asset.rebuild()
        }
    }

    func assetAtIndex(n: Int) -> Asset {
        return self.assets[n]
    }

    func assetWithKey(pid: Int) -> Asset? {
        for asset in self.assets {
            if (asset.pid == pid) {
                return asset
            }
        }
        return nil
    }

    func assetIndexWithKey(pid: Int) -> Int {
        var i: Int
        for (i = 0; i < self.assets.count; i++) {
            let asset = self.assets[i]
            if (asset.pid == pid) {
                return i
            }
        }
        return -1
    }

    func addAsset(asset: Asset) {
        self.assets.append(asset)
        asset.save()
    }

    func deleteAsset(asset: Asset) {
        let idx = assetIndexWithKey(asset.pid)
        
        asset.delete()
        DataModel.getJournal().deleteAllTransactionsWithAsset(asset)
        self.assets.removeAtIndex(idx)
        self.rebuild()
    }

    func updateAsset(asset: Asset) {
        asset.save()
    }

    func reorderAsset(from: Int, to: Int) {
        let asset = self.assets[from]
        
        self.assets.removeAtIndex(from)
        self.assets.insert(asset, atIndex: to)
	
        // renumbering sorder
        let db = Database.instance()
        db.beginTransaction()
        for (var i = 0; i < self.assets.count; i++) {
            let asset2 = self.assets[i]
            asset2.sorder = i
            asset2.save()
        }
        db.commitTransaction()
    }
}
