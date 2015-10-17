import Foundation
import XCTest

@testable import CashFlow

class DataModelTest : XCTestCase {
    var dm : DataModel! = nil
    
    override func setUp() {
        super.setUp()
        TestCommon.initDatabase()
        dm = DataModel.instance()
    }

    override func tearDown() {
        super.tearDown()
    }

    // データベースがないときに、初期化されること
    func testInitial() {
        // 初期データチェック
        XCTAssert(dm != nil)
        XCTAssertEqual(0, dm.journal.entries.count)

        let asset = dm.ledger.assets[0]
        XCTAssertEqual(NSLocalizedString("Cash", comment:""), asset.name)
                  
        XCTAssertEqual(0, dm.categories.count)
    }

    // データベースがあるときに、正常に読み込めること
    func testNotInitial() {
        TestCommon.installDatabase("testdata1")
        dm = DataModel.instance()

        XCTAssertEqual(6, dm.journal.entries.count)
        XCTAssertEqual(3, dm.ledger.assets.count);
        XCTAssertEqual(3, dm.categories.count);
    }
}

