import UIKit
import XCTest

@testable import CashFlow

class DescLRUManagerTests : XCTestCase {
    var manager: DescLRUManager!

    override func setUp() {
        super.setUp()
        TestCommon.deleteDatabase()
        DataModel.instance().load() // re-create DataModel
    }

    override func tearDown() {
        super.tearDown()
        DataModel.finalize()
        Database.shutdown()
    }

    func setupTestData() {
        let db = Database.instance()
     
        DescLRUManager.addDescLRU("test0", category:0, date:db.dateFromString("20100101000000"))
        DescLRUManager.addDescLRU("test1", category:1, date:db.dateFromString("20100101000001"))
        DescLRUManager.addDescLRU("test2", category:2, date:db.dateFromString("20100101000002"))
        DescLRUManager.addDescLRU("test3", category:0, date:db.dateFromString("20100101000003"))
        DescLRUManager.addDescLRU("test4", category:1, date:db.dateFromString("20100101000004"))
        DescLRUManager.addDescLRU("test5", category:2, date:db.dateFromString("20100101000005"))
    }

    func testInit() {
        let ary = DescLRUManager.getDescLRUs(-1)
        XCTAssertEqual(0, ary.count)
    }

    func testAnyCategory() {
        self.setupTestData()

        let ary = DescLRUManager.getDescLRUs(-1)
        XCTAssertEqual(6, ary.count)

        var lru = ary[0]
        XCTAssertEqual("test5", lru.desc, "first entry")
        lru = ary[5]
        XCTAssertEqual("test0", lru.desc, "last entry")
    }

    func testCategory() {
        self.setupTestData()

        let ary = DescLRUManager.getDescLRUs(1)
        XCTAssertEqual(2, ary.count, "LRU count must be 2.")

        var lru = ary[0]
        XCTAssertEqual("test4", lru.desc, "first entry")
        lru = ary[1]
        XCTAssertEqual("test1", lru.desc, "last entry")
    }

    func testUpdateSameCategory() {
        self.setupTestData()

        DescLRUManager.addDescLRU("test1", category:1) // same name/cat.

        let ary = DescLRUManager.getDescLRUs(1)
        XCTAssertEqual(2, ary.count, "LRU count must be 2.")

        var lru = ary[0]
        XCTAssertEqual("test1", lru.desc, "first entry")
        lru = ary[1]
        XCTAssertEqual("test4", lru.desc, "last entry")
    }

    func testUpdateOtherCategory() {
        self.setupTestData()

        DescLRUManager.addDescLRU("test1", category:2) // same name/other cat.

        var ary = DescLRUManager.getDescLRUs(1)
        XCTAssertEqual(1, ary.count, "LRU count must be 2.")

        var lru = ary[0]
        XCTAssertEqual("test4", lru.desc, "first entry")

        ary = DescLRUManager.getDescLRUs(2)
        XCTAssertEqual(3, ary.count, "LRU count must be 3.")
        lru = ary[0]
        XCTAssertEqual("test1", lru.desc, "new entry")
    }
}
