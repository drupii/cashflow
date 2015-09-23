import Foundation

class TestCommon : NSObject {
    static let kTestDbName = "CashFlowTest.db"

    private static var df: DateFormatter2?
    
    static func dateFormatter() -> DateFormatter2 {
        if (df == nil) {
            df = DateFormatter2()
            df!.timeZone = NSTimeZone(abbreviation: "UTC")
            df!.dateFormat = "yyyyMMddHHmmss"
        }
        return df!
    }

    static func dateWithString(s: String) -> NSDate {
        return TestCommon.dateFormatter().dateFromString(s)!
    }

    static func stringWithDate(date: NSDate) -> String {
        return TestCommon.dateFormatter().stringFromDate(date)
    }

    /**
     * テスト用のデータベース名を設定する (sandbox)
     */
    private static func setupTestDbName() {
        DataModel.setDbName(kTestDbName)
    }

    // データベースを削除する
    static func deleteDatabase() {
        TestCommon.setupTestDbName()
    
        DataModel.finalize()

        let dbPath = Database.instance().dbPath(kTestDbName)

        do {
            try NSFileManager.defaultManager().removeItemAtPath(dbPath)
        } catch {
            // ignore?
        }

        Database.shutdown()
        CashflowDatabase.instantiate()
    }

    // 空のデータベースから開始する
    static func initDatabase() {
        TestCommon.deleteDatabase()
        TestCommon.createDocumentsDir()
        DataModel.instance().load()
    }

    // データベースをインストールする
    static func installDatabase(sqlFileName: String) -> Bool {
        TestCommon.deleteDatabase()

        let bundle = NSBundle(forClass: TestCommon.self)
        //NSString *sqlPath = [[NSBundle mainBundle] pathForResource:sqlFileName ofType:@"sql"];
        let sqlPath = bundle.pathForResource(sqlFileName, ofType: "sql")
        if (sqlPath == nil) {
            print("FATAL: no SQL data file : \(sqlFileName)")
            return false
        }
    
        TestCommon.createDocumentsDir()

        let dbPath = Database.instance().dbPath(kTestDbName)
        //NSLog(@"install db: %@", dbPath);
    
        // load sql
        let data = NSData(contentsOfFile: sqlPath!)
        let sql = NSString(data: data!, encoding:NSUTF8StringEncoding)!
        /*
        char *sql = malloc([data length] + 1);
        [data getBytes:sql];
        sql[[data length]] = '\0'; // null terminate
        */
        
        var handle: COpaquePointer = nil
        if sqlite3_open(dbPath, &handle) != SQLITE_OK {
            print("sqlite3_open failed!");
            // ### ASSERT?
            return false
        }
    
        if (sqlite3_exec(handle, sql.cStringUsingEncoding(NSUTF8StringEncoding), nil, nil, nil) != SQLITE_OK) {
            let errmsg = String.fromCString(sqlite3_errmsg(handle))
            print("sqlite3_exec failed : \(errmsg)")
            return false
            // ### ASSERT?
        }
    
        sqlite3_close(handle)
    
        // load database
        let dm = DataModel.instance()
        dm.load()
#if false
        dm.startLoad(nil)
        while (!dm.isLoadDone) {
            NSThread.sleepForTimeInterval(0.05)
        }
#endif
        return true
    }

    // Document ディレクトリを作成する (単体テストだとなぜかできてない)
    private static func createDocumentsDir() {
        let fm = NSFileManager.defaultManager()
        let dbdir = Database.instance().dbPath("")
        
        if !fm.fileExistsAtPath(dbdir) {
            do {
                try fm.createDirectoryAtPath(dbdir, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // TODO:
            }
        }
    }
}
