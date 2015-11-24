import UIKit
import XCTest

@testable import CashFlow

class JournalTest : XCTestCase {
    var journal: Journal!

    override func setUp() {
        super.setUp()
        TestCommon.initDatabase()
        journal = DataModel.getJournal()
    }

    func testReload() {
        XCTAssertEqual(0, journal.entries.count);
        journal.reload();
        XCTAssertEqual(0, journal.entries.count);
    
        TestCommon.installDatabase("testdata1")
        journal = DataModel.getJournal();
        XCTAssertEqual(6, journal.entries.count);

        journal.reload();
        XCTAssertEqual(6, journal.entries.count);
    }

    func testFastEnumeration() {
        TestCommon.installDatabase("testdata1")
        journal = DataModel.getJournal();
    
        for (idx, t) in journal.entries.enumerate() {
            XCTAssertEqual(idx + 1, t.pid);
        }
    }
    
    func testInsertTransaction() {
        TestCommon.installDatabase("testdata1")
        journal = DataModel.getJournal()

        // 途中に挿入する
        let t = Transaction()
        t.pid = 7
        t.asset = 1
        t.type = 0
        t.value = 100
        t.date = TestCommon.dateWithString("20090103000000")
    
        journal.insertTransaction(t)
        XCTAssertEqual(7, journal.entries.count)
        
        let tt = journal.entries[2]
        XCTAssertEqual(t, tt)
        XCTAssertEqual(t.pid, tt.pid)
    }

    func testReplaceTransaction() {
        TestCommon.installDatabase("testdata1")
        journal = DataModel.getJournal();

        // 途中に挿入する
        let t = Transaction()
        t.pid = 999
        t.asset = 3
        t.type = 0
        t.value = 100
        t.date = TestCommon.dateWithString("20090201000000") // last
    
        let orig = journal.entries[3]
        XCTAssertEqual(4, orig.pid)

        journal.replaceTransaction(orig, to: t)

        XCTAssertEqual(6, journal.entries.count) // 数は変更なし
        let tt = journal.entries[5]
        //ASSERT_EQUAL(t, tt);
        XCTAssertEqual(t.pid, tt.pid)
    }

    func testDeleteTransaction() {
        TestCommon.installDatabase("testdata1")
        journal = DataModel.getJournal();
        
        let asset = Asset()

        // 資産間取引を削除 (pid == 4 の取引)
        asset.pid = 2
        var t = journal.entries[3]
        XCTAssertFalse(journal.deleteTransaction(t, asset: asset))
        XCTAssertEqual(6, journal.entries.count) // 置換されたので消えてないはず
    
        t = journal.entries[2]
        XCTAssertEqual(3, t.pid)
        t = journal.entries[3]
        XCTAssertEqual(4, t.pid) // まだ消えてない
    
        // 置換されていることを確認する
        XCTAssertEqual(1, t.asset)
        XCTAssertEqual(-1, t.dstAsset)
        XCTAssertEqual(5000.0, t.value)
    
        // 今度は置換された資産間取引を消す
        asset.pid = 1
        XCTAssert(journal.deleteTransaction(t, asset:asset))
    
        t = journal.entries[2]
        XCTAssertEqual(3, t.pid)
        t = journal.entries[3]
        XCTAssertEqual(5, t.pid)
    }

    func testDeleteTransaction2() {
        TestCommon.installDatabase("testdata1")
        journal = DataModel.getJournal();
        let asset = Asset()
    
        // 資産間取引を削除 (pid == 4 の取引)、ただし、testDeleteTransaction とは逆方向
        asset.pid = 1
        var t = journal.entries[3]
        XCTAssertFalse(journal.deleteTransaction(t, asset:asset))
    
        // 置換されていることを確認する
        XCTAssertEqual(2, t.asset);
        XCTAssertEqual(-1, t.dstAsset);
        XCTAssertEqual(-5000.0, t.value);
    
        // 置換された資産間取引を消す
        asset.pid = 2;
        XCTAssert(journal.deleteTransaction(t, asset:asset))
    
        t = journal.entries[2]
        XCTAssertEqual(3, t.pid)
        t = journal.entries[3]
        XCTAssertEqual(5, t.pid)
    }

    func testDeleteTransactionWithAsset() {
        TestCommon.installDatabase("testdata1")
        journal = DataModel.getJournal();
        let asset = Asset()

        XCTAssertEqual(6, journal.entries.count)

        asset.pid = 4; // not exist
        journal.deleteAllTransactionsWithAsset(asset)
        XCTAssertEqual(6, journal.entries.count)
    
        asset.pid = 1
        journal.deleteAllTransactionsWithAsset(asset)
        XCTAssertEqual(3, journal.entries.count);
    
        asset.pid = 2
        journal.deleteAllTransactionsWithAsset(asset)
        XCTAssertEqual(1, journal.entries.count)

        asset.pid = 3
        journal.deleteAllTransactionsWithAsset(asset)
        XCTAssertEqual(0, journal.entries.count)
    }

    /**
     sort : 日付昇順に並び替えられること
    */
    func testSort() {
        journal = DataModel.getJournal()
    
        let t1 = Transaction()
        t1.date = NSDate(timeIntervalSince1970: 300)
        t1.pid = 1
        journal.entries.append(t1)
        
        let t2 = Transaction()
        t2.date = NSDate(timeIntervalSince1970: 100)
        t2.pid = 2
        journal.entries.append(t2)
        
        let t3 = Transaction()
        t3.date = NSDate(timeIntervalSince1970: 200)
        t3.pid = 3
        journal.entries.append(t3)
        
        journal._sortByDateAndPid()
        
        XCTAssertEqual(2, journal.entries[0].pid)
        XCTAssertEqual(3, journal.entries[1].pid)
        XCTAssertEqual(1, journal.entries[2].pid)
    }
    
    /**
     sort: 日付が同一の場合、pid 順に並び替えられること。
    */
    func testSortSameDate() {
        journal = DataModel.getJournal()

        let t1 = Transaction()
        t1.date = NSDate()
        t1.pid = 3
        journal.entries.append(t1)

        let t2 = Transaction()
        t2.date = t1.date
        t2.pid = 1
        journal.entries.append(t2)
        
        let t3 = Transaction()
        t3.date = t1.date
        t3.pid = 2
        journal.entries.append(t3)
        
        journal._sortByDateAndPid()
        
        XCTAssertEqual(1, journal.entries[0].pid)
        XCTAssertEqual(2, journal.entries[1].pid)
        XCTAssertEqual(3, journal.entries[2].pid)
    }


    /*
// Journal 上限数チェック
#if 0
- (void)testJournalInsertUpperLimit
{
    Assert(journal.entries.count == 0);

    Transaction *t;
    int i;

    for (i = 0; i < MAX_TRANSACTIONS; i++) {
        t = [Transaction new];
        t.asset = 1; // cash
        [journal insertTransaction:t];
        [t release];

        Assert(journal.entries.count == i + 1);
    }

    Ledger *ledger = [DataModel ledger];
    [ledger rebuild];
    Asset *asset = [ledger assetAtIndex:0];
    Assert([asset entryCount] == MAX_TRANSACTIONS);
    
    // 上限数＋１個目
    t = [Transaction new];
    t.asset = 1; // cash
    [journal insertTransaction:t];
    [t release];

    Assert(journal.entries.count == MAX_TRANSACTIONS);
}
#endif
*/
}
