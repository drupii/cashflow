import UIKit
import XCTest

@testable import CashFlow

class TransactionTest : XCTestCase {
    var transaction: Transaction!

    override func setUp() {
        super.setUp()

        TestCommon.deleteDatabase()
        DataModel.instance().load()
    }

    override func tearDown() {
        super.tearDown()
    }

    // 最終使用日のテスト
    func testLastUsedDate() {
        // 解除
        Transaction.setLastUsedDate(nil)
        XCTAssertFalse(Transaction.hasLastUsedDate())

        let t = NSDate(timeIntervalSince1970: 0)
        Transaction.setLastUsedDate(t)
        XCTAssert(Transaction.hasLastUsedDate())

        let t2 = Transaction.lastUsedDate()
        XCTAssertEqual(t, t2)
    }
    
// 日付のアップグレードテスト (ver 3.2.1 -> 3.3以降 へのアップグレード)
/*
- (void)testMigrateDate
{
    Database *db = [Database instance];
    
    // 旧バージョンのフォーマットでデータを作成
    [db beginTransaction];
    for (int i = 0; i < 100; i++) {
        [db exec:@"INSERT INTO Transactions VALUES(NULL, 0, 0, 200901011356, 0, 0, 0, '', '');"];
        [db exec:@"INSERT INTO Transactions VALUES(NULL, 0, 0, '20090101午後0156', 0, 0, 0, '', '');"];
    }
    [db commitTransaction];
    
    // Migrate 実行
    [DataModel finalize];
    [[DataModel instance] load];
    
    // チェック
    dbstmt *stmt = [db prepare:@"SELECT date FROM Transactions;"];
    XCTAssertEqual(SQLITE_ROW, [stmt step]);
    do {
        NSString *s = [stmt colString:0];
        XCTAssertEqualObjects(@"20090101135600", s);
    } while ([stmt step] == SQLITE_ROW);
}
*/


}

