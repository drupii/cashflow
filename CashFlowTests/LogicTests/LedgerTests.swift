import UIKit
import XCTest

@testable import CashFlow

class LedgerTest : XCTestCase {
    var ledger: Ledger!

    override func setUp() {
        super.setUp()
        TestCommon.deleteDatabase()
        DataModel.instance().load()
        ledger = DataModel.getLedger()
    }

    func testInitial() {
        // 現金のみがあるはず
        XCTAssertEqual(1, ledger.assets.count)
        ledger.load()
        ledger.rebuild()
        XCTAssertEqual(1, ledger.assets.count)
        
        let asset = ledger.assetAtIndex(0)
        XCTAssertEqual(0, asset.entryCount)
    }

    func testNormal() {
        TestCommon.installDatabase("testdata1")
        ledger = DataModel.getLedger()
    
        XCTAssertEqual(3, ledger.assets.count)
        ledger.load()
        ledger.rebuild()
        XCTAssertEqual(3, ledger.assets.count)

        XCTAssertEqual(4, ledger.assetAtIndex(0).entryCount)
        XCTAssertEqual(2, ledger.assetAtIndex(1).entryCount)
        XCTAssertEqual(1, ledger.assetAtIndex(2).entryCount)
    }
}
