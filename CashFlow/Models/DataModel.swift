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

#define BACKUP_FILE_VERSION 3
#define BACKUP_FILE_IDENT_PRE @"-- CashFlow Backup Format rev. "
#define BACKUP_FILE_IDENT_POST @" --"

- (NSString *)backupFileIdent
{
    return [NSString stringWithFormat:@"%@%d%@", BACKUP_FILE_IDENT_PRE, BACKUP_FILE_VERSION, BACKUP_FILE_IDENT_POST];
}

/**
 * Ident からバージョン番号を取り出す
 */
- (int)getBackupFileIdentVersion:(NSString *)line
{
    NSString *pattern = [NSString stringWithFormat:@"%@(\\d+)%@", 
                                  BACKUP_FILE_IDENT_PRE, BACKUP_FILE_IDENT_POST];

    NSError *error;
    NSRegularExpression *regex;
    regex = [NSRegularExpression
                regularExpressionWithPattern:pattern
                                     options:0
                                       error:&error];

    NSTextCheckingResult *match;
    match  = [regex firstMatchInString:line
                               options:0
                                 range:NSMakeRange(0, line.length)];
    if (match == nil) return -1;
    
    NSString *verString = [line substringWithRange:[match rangeAtIndex:1]];
    int ver = verString.intValue;
    
    return ver;
}

- (NSString *)getBackupSqlPath
{
    return [[Database instance] dbPath:@"CashFlowBackup.sql"];
}

/**
 * SQL でファイルに書きだす
 */
- (BOOL)backupDatabaseToSql:(NSString *)path
{
    NSMutableString *sql = [NSMutableString new];
    
    [sql appendString:[self backupFileIdent]];
    [sql appendString:@"\n"];

    [Asset getTableSql:sql];
    [Transaction getTableSql:sql];
    [TCategory getTableSql:sql];
    [DescLRU getTableSql:sql];

    return [sql writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}

/**
 * ファイルから SQL を読みだして実行する
 */
- (BOOL)restoreDatabaseFromSql:(NSString *)path
{
    Database *db = [Database instance];

    // 先に VACUUM を実行しておく
    [db exec:@"VACUUM;"];

    // SQL をファイルから読み込む
    NSString *sql = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (sql == nil) {
        return NO;
    }

    // check ident
    int ver = [self getBackupFileIdentVersion:sql];
    if (ver < 0) {
        NSLog(@"Invalid backup data ident");
        return NO;
    }
    if (ver > BACKUP_FILE_VERSION) {
        NSLog(@"Backup file version too new");
        return NO;
    }

    // SQL 実行
    [db beginTransaction];
    if (![db exec:sql]) {
        [db rollbackTransaction];
        return NO;
    }
    [db commitTransaction];

    // 再度 VACUUM を実行
    [db exec:@"VACUUM;"];

    return YES;
}

#pragma mark Sync operations

#define KEY_LAST_SYNC_REMOTE_REV        @"LastSyncRemoteRev"
#define KEY_LAST_MODIFIED_DATE_OF_DB    @"LastModifiedDateOfDatabase"

- (void)setLastSyncRemoteRev:(NSString *)rev
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:rev forKey:KEY_LAST_SYNC_REMOTE_REV];
    
    NSLog(@"set last sync remote rev: %@", rev);
}

- (BOOL)isRemoteModifiedAfterSync:(NSString *)currev
{
    if (currev == nil) {
        // リモートが存在しない場合は、変更されていないとみなす。
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastrev = [defaults objectForKey:KEY_LAST_SYNC_REMOTE_REV];
    if (lastrev == nil) {
        // まだ同期したことがない。remote は変更されているものとみなす
        return YES;
    }
    return ![lastrev isEqualToString:currev];
}

- (NSDate *)_lastModificationDateOfDatabase
{
    Database *db = [Database instance];
    NSString *dbpath = [db dbPath:theDbName];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *attrs = [manager attributesOfItemAtPath:dbpath error:nil];
    NSDate *date = attrs[NSFileModificationDate];
    return date;
}

- (void)setSyncFinished
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastdate = [self _lastModificationDateOfDatabase];
    [defaults setObject:lastdate forKey:KEY_LAST_MODIFIED_DATE_OF_DB];
    
    NSLog(@"sync finished: DB modification date is %@", lastdate);
}

- (BOOL)isModifiedAfterSync
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastdate = [defaults objectForKey:KEY_LAST_MODIFIED_DATE_OF_DB];
    if (lastdate == nil) {
        // まだ同期したことがない。local は変更されているものとみなす。
        return YES;
    }
    NSDate *curdate = [self _lastModificationDateOfDatabase];
    return ![curdate isEqualToDate:lastdate];
}
*/
}

