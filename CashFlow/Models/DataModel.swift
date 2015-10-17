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
    var journal: Journal
    var ledger: Ledger
    var categories: Categories
    
    private(set) var isLoadDone: Bool

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
        journal = Journal()
        ledger = Ledger()
        categories = Categories()
        self.isLoadDone = false
        
        super.init()
    }

    static func getJournal() -> Journal {
        return DataModel.instance().journal
    }

    static func getLedger() -> Ledger {
        return DataModel.instance().ledger
    }

    static func getCategories() -> Categories {
        return DataModel.instance().categories
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
        journal.reload()

        // Load ledger
        ledger.load()
        ledger.rebuild()

        // Load categories
        categories.reload()
    }
    
    // 摘要からカテゴリを推定する
    func categoryWithDescription(desc: String) -> Int {
        let t = Transaction.find_by_description(desc, cond:"ORDER BY date DESC")
        if (t == nil) {
            return -1
        }
        return t!.category
    }
}

