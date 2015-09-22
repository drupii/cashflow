/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

protocol DataModelDelegate {
    func dataModelLoaded()
}

class DataModel : NSObject {
    var _journal: Journal
    var _ledger: Ledger
    var _categories: Categories
    
    private(set) var isLoadDone: Bool

    //@property (nonatomic, getter=getBackupSqlPath, readonly, copy, nonnull) NSString *backupSqlPath;

    //@property (nonatomic, getter=isModifiedAfterSync, readonly) BOOL modifiedAfterSync;

    private(set) var _lastModificationDateOfDatabase: NSDate?

    private(set) var _delegate: DataModelDelegate?

    private static var theDataModel: DataModel?

    private static var theDbName: String = "CashFlow.db"

    static func instance() -> DataModel {
        if (theDataModel == nil) {
            theDataModel = DataModel()
        }
        return theDataModel!
    }

    override static func finalize() {
        super.finalize()
        if (theDataModel != nil) {
            theDataModel = nil;
        }
    }

    // for unit testing
    static func setDbName(dbname: String) {
        theDbName = dbname;
    }

    override init() {
        _journal = Journal()
        _ledger = Ledger()
        _categories = Categories()
        self.isLoadDone = false
        
        super.init()
    }

    static func journal() -> Journal {
        return DataModel.instance()._journal
    }

    static func ledger() -> Ledger {
        return DataModel.instance()._ledger
    }

    static func categories() -> Categories {
        return DataModel.instance()._categories
    }

    func startLoad(delegate: DataModelDelegate) {
        _delegate = delegate;
        isLoadDone = false
    
        // TODO:
        let thread = NSThread(target: self, selector: Selector("loadThread:"), object: nil)
        thread.start()
    }

    func loadThread(dummy: AnyObject?) {
        autoreleasepool {

            self.load()
        
            self.isLoadDone = true
            if (self._delegate != nil) {
                self._delegate!.dataModelLoaded()
            }
        }
        NSThread.exit()
    }
    
    private func load() {
        let db = Database.instance()

        // Load from DB
        if (!(db.open(DataModel.theDbName))) {
        }

        Transaction.migrate()
        Asset.migrate()
        TCategory.migrate()
        DescLRU.migrate()
    
        DescLRUManager.migrate()
	
        // Load all transactions
        _journal.reload()

        // Load ledger
        _ledger.load()
        _ledger.rebuild()

        // Load categories
        _categories.reload()
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // Utility

// 摘要からカテゴリを推定する
//
// note: 本メソッドは Asset ではなく DataModel についているべき
//
- (NSInteger)categoryWithDescription:(NSString *)desc
{
    Transaction *t = [Transaction find_by_description:desc cond:@"ORDER BY date DESC"];

    if (t == nil) {
        return -1;
    }
    return t.category;
}
}

