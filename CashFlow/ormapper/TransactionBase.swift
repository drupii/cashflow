// DO NOT MODIFY!
// Generated by mb-ormapper generator ver 2.3
// https://github.com/tmurakam/mb-ormapper

import Foundation

class TransactionBase : ORRecord {

    var asset : Int = 0
    var dstAsset : Int = 0
    var date : NSDate = NSDate(timeIntervalSince1970: 0)
    var type : Int = 0
    var category : Int = 0
    var value : Double = 0
    var desc : String = ""
    var memo : String = ""
    var identifier : String = ""

    override init() {
        super.init()
    }

    /**
     @brief Migrate database table
     @return YES - table was newly created, NO - table already exists
     */
    class func migrate() -> Bool {
        let columnTypes: [String] = [
            "asset", "INTEGER",
            "dst_asset", "INTEGER",
            "date", "DATE",
            "type", "INTEGER",
            "category", "INTEGER",
            "value", "REAL",
            "description", "TEXT",
            "memo", "TEXT",
            "identifier", "TEXT",
        ]

        return super.migrate(columnTypes, primaryKey:"key")
    }

    // MARK: -  Read operations

    /**
      @brief get the record matchs the id
      @param pid Primary key of the record
      @return record
    */
    class func find(pid: Int) -> Transaction? {
        let db = Database.instance()

        let stmt = db.prepare("SELECT * FROM Transactions WHERE key = ?;")
        stmt.bindInt(0, val: pid)

        return find_first_stmt(stmt)
    }

    /**
      finder with asset

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_asset(key: Int, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE asset = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindInt(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_asset(key: Int) -> Transaction? {
        return find_by_asset(key, cond:nil)
    }

    /**
      finder with dst_asset

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_dst_asset(key: Int, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE dst_asset = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindInt(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_dst_asset(key: Int) -> Transaction? {
        return find_by_dst_asset(key, cond:nil)
    }

    /**
      finder with date

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_date(key: NSDate, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE date = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindDate(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_date(key: NSDate) -> Transaction? {
        return find_by_date(key, cond:nil)
    }

    /**
      finder with type

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_type(key: Int, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE type = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindInt(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_type(key: Int) -> Transaction? {
        return find_by_type(key, cond:nil)
    }

    /**
      finder with category

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_category(key: Int, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE category = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindInt(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_category(key: Int) -> Transaction? {
        return find_by_category(key, cond:nil)
    }

    /**
      finder with value

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_value(key: Double, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE value = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindDouble(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_value(key: Double) -> Transaction? {
        return find_by_value(key, cond:nil)
    }

    /**
      finder with description

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_description(key: String, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE description = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindString(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_description(key: String) -> Transaction? {
        return find_by_description(key, cond:nil)
    }

    /**
      finder with memo

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_memo(key: String, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE memo = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindString(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_memo(key: String) -> Transaction? {
        return find_by_memo(key, cond:nil)
    }

    /**
      finder with identifier

      @param key Key value
      @param cond Conditions (ORDER BY etc)
      @note If you specify WHERE conditions, you must start cond with "AND" keyword.
    */
    class func find_by_identifier(key: String, cond: String?) -> Transaction? {
        let cond2 = cond ?? ""
        let whr = "WHERE identifier = ? \(cond2) LIMIT 1"
        let stmt = gen_stmt(whr)
        stmt.bindString(0, val:key)
        return find_first_stmt(stmt)
    }

    class func find_by_identifier(key: String) -> Transaction? {
        return find_by_identifier(key, cond:nil)
    }


    /**
      Get first record matches the conditions
      @param cond Conditions (WHERE phrase and so on)
      @return array of records
    */
    class func find_first(cond: String?) -> Transaction? {
        let cond2: String
        if (cond == nil) {
            cond2 = "LIMIT 1"
        } else {
            cond2 = cond! + " LIMIT 1"
        }
        let stmt = gen_stmt(cond2)
        return  find_first_stmt(stmt)
    }

    /**
      Get all records match the conditions
      @param cond Conditions (WHERE phrase and so on)
      @return array of records
    */
    class func find_all(cond: String?) -> [Transaction] {
        let stmt = gen_stmt(cond)
        return find_all_stmt(stmt)
    }

    /**
      create dbstmt
      @param s condition
      @return dbstmt
    */
    class func gen_stmt(cond: String?) -> dbstmt {
        let sql: String
        if (cond == nil) {
            sql = "SELECT * FROM Transactions;"
        } else {
            sql = "SELECT * FROM Transactions \(cond!);"
        }  
        let stmt = Database.instance().prepare(sql)
        return stmt
    }

    /**
      Get first record matches the conditions
      @param stmt Statement
      @return array of records
    */
    class func find_first_stmt(stmt: dbstmt) -> Transaction? {
        if (stmt.step() == numericCast(SQLITE_ROW)) {
            // e = [[self class] new]
            let e = Transaction()
            e._loadRow(stmt)
            return e
        }
        return nil;
    }

    /**
      Get all records match the conditions
      @param stmt Statement
      @return array of records
    */
    class func find_all_stmt(stmt: dbstmt) -> [Transaction] {
        var array : [Transaction] = []

        while (stmt.step() == numericCast(SQLITE_ROW)) {
            //let e = self.class().new()
            let e = Transaction()
            e._loadRow(stmt)
            array.append(e)
        }
        return array;
    }

    override func _loadRow(stmt: dbstmt) {
        self.pid = stmt.colInt(0)
        self.asset = stmt.colInt(1)
        self.dstAsset = stmt.colInt(2)
        self.date = stmt.colDate(3)
        self.type = stmt.colInt(4)
        self.category = stmt.colInt(5)
        self.value = stmt.colDouble(6)
        self.desc = stmt.colString(7)
        self.memo = stmt.colString(8)
        self.identifier = stmt.colString(9)
    }

    // MARK: - Create operations

    override func _insert() {
        super._insert()

        let db = Database.instance()
    
        //db.beginTransaction()
        let stmt = db.prepare("INSERT INTO Transactions VALUES(NULL,?,?,?,?,?,?,?,?,?);")
        stmt.bindInt(0, val:self.asset)
        stmt.bindInt(1, val:self.dstAsset)
        stmt.bindDate(2, val:self.date)
        stmt.bindInt(3, val:self.type)
        stmt.bindInt(4, val:self.category)
        stmt.bindDouble(5, val:self.value)
        stmt.bindString(6, val:self.desc)
        stmt.bindString(7, val:self.memo)
        stmt.bindString(8, val:self.identifier)
        stmt.step()

        self.pid = db.lastInsertRowId

        //db.commitTransaction()

        db.setModified()
    }

    // MARK: - Update operations

    override func _update() {
        super._update()

        let db = Database.instance()
        //db.beginTransaction()

        let stmt = db.prepare("UPDATE Transactions SET "
        + "asset = ?"
        + ",dst_asset = ?"
        + ",date = ?"
        + ",type = ?"
        + ",category = ?"
        + ",value = ?"
        + ",description = ?"
        + ",memo = ?"
        + ",identifier = ?"
        + " WHERE key = ?;")
        stmt.bindInt(0, val:self.asset)
        stmt.bindInt(1, val:self.dstAsset)
        stmt.bindDate(2, val:self.date)
        stmt.bindInt(3, val:self.type)
        stmt.bindInt(4, val:self.category)
        stmt.bindDouble(5, val:self.value)
        stmt.bindString(6, val:self.desc)
        stmt.bindString(7, val:self.memo)
        stmt.bindString(8, val:self.identifier)
        stmt.bindInt(9, val:self.pid)

        stmt.step()
        //db.commitTransaction()

        db.setModified()
    }

    // MARK: - Delete operations

    /**
      Delete record
    */
    override func delete() {
        let db = Database.instance()

        let stmt = db.prepare("DELETE FROM Transactions WHERE key = ?;")
        stmt.bindInt(0, val:self.pid)
        stmt.step()

        db.setModified()
    }

    /**
     Delete all records
    */
    class func delete_cond(cond: String?) {
        let db = Database.instance()

        let cond2: String
        if (cond == nil) {
            cond2 = ""
        } else {
            cond2 = cond!
        }
        let sql = "DELETE FROM Transactions \(cond2);"
        db.exec(sql)

        db.setModified()
    }

    override class func delete_all() {
        TransactionBase.delete_cond(nil)
    }

    /**
     * get table sql
     */
    class func getTableSql(s: NSMutableString) {
        s.appendString("DROP TABLE Transactions;\n")
        s.appendString("CREATE TABLE Transactions (key INTEGER PRIMARY KEY")

        s.appendString(", asset INTEGER")
        s.appendString(", dst_asset INTEGER")
        s.appendString(", date DATE")
        s.appendString(", type INTEGER")
        s.appendString(", category INTEGER")
        s.appendString(", value REAL")
        s.appendString(", description TEXT")
        s.appendString(", memo TEXT")
        s.appendString(", identifier TEXT")
    
        s.appendString(");\n")

        let ary = find_all(nil)
        for e in ary {
            e.getInsertSql(s)
            s.appendString("\n")
        }
    }

    /**
     * get "INSERT" SQL
     */
    func getInsertSql(s: NSMutableString) {
        s.appendFormat("INSERT INTO Transactions VALUES(%ld", self.pid)
        s.appendString(",")
        s.appendString(quoteSqlString(asset.description))
        s.appendString(",")
        s.appendString(quoteSqlString(dstAsset.description))
        s.appendString(",")
        s.appendString(quoteSqlString(Database.instance().stringFromDate(date)))
        s.appendString(",")
        s.appendString(quoteSqlString(type.description))
        s.appendString(",")
        s.appendString(quoteSqlString(category.description))
        s.appendString(",")
        s.appendString(quoteSqlString(value.description))
        s.appendString(",")
        s.appendString(quoteSqlString(desc))
        s.appendString(",")
        s.appendString(quoteSqlString(memo))
        s.appendString(",")
        s.appendString(quoteSqlString(identifier))
        s.appendString(");")
    }

    // MARK: - Internal functions

    override class func tableName() -> String {
        return "Transactions"
    }
}
