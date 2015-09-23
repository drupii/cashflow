import UIKit
import XCTest

class AssetEntryTest : XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // transaction 指定なし
    func testAllocNew() {
        let a = Asset()
        a.pid = 999

        let e = AssetEntry(transaction: nil, asset: a)

        XCTAssertEqual(e.assetKey, 999)
        XCTAssertEqual(e.value, 0.0)
        XCTAssertEqual(e.balance, 0.0)
        XCTAssertEqual(e.transaction()!.asset, 999)
        XCTAssertFalse(e.isDstAsset())

        // 値設定
        e.value = 200.0
        //[e setupTransaction]
        XCTAssertEqual(e.transaction()!.value, 200.0)
    }

    // transaction 指定あり、通常
    func testAllocExisting() {
        let a = Asset()
        a.pid = 111

        let t = Transaction()
        t.etype = .Transfer
        t.asset = 111
        t.dstAsset = 222
        t.value = 10000.0

        let e = AssetEntry(transaction: t, asset: a)

        XCTAssertEqual(e.assetKey, 111)
        XCTAssertEqual(e.value, 10000.0)
        XCTAssertEqual(e.balance, 0.0)
        XCTAssertEqual(e.transaction()!.asset, 111)
        XCTAssertFalse(e.isDstAsset())

        // 値設定
        e.value = 200.0;
        //[e setupTransaction];
        XCTAssertEqual(e.transaction()!.value, 200.0);
    }

    // transaction 指定あり、逆
    func testAllocExistingReverse() {
        let a = Asset()
        a.pid = 111

        let t = Transaction()
        t.etype = .Transfer
        t.asset = 222
        t.dstAsset = 111
        t.value = 10000.0

        let e = AssetEntry(transaction: t, asset: a)

        XCTAssertEqual(e.assetKey, 111)
        XCTAssertEqual(e.value, -10000.0)
        XCTAssertEqual(e.balance, 0.0)
        XCTAssertEqual(e.transaction()!.asset, 222)
        XCTAssert(e.isDstAsset())

        // 値設定
        e.value = 200.0;
        //[e setupTransaction];
        XCTAssertEqual(e.transaction()!.value, -200.0)
    }

    func testEvalueNormal() {
        let a = Asset()
        a.pid = 111

        let t = Transaction()
        t.asset = 111
        t.dstAsset = -1

        let e = AssetEntry(transaction: t, asset: a)
        e.balance = 99999.0

        t.etype = .Income
        e.value = 10000
        XCTAssertEqual(e.evalue, 10000.0)
        e.evalue = 20000
        XCTAssertEqual(e.transaction()!.value, 20000.0)

        t.etype = .Outgo
        e.value = 10000
        XCTAssertEqual(e.evalue, -10000.0)
        e.evalue = 20000
        XCTAssertEqual(e.transaction()!.value, -20000.0)

        t.etype = .Adj
        e.balance = 99999
        XCTAssertEqual(e.evalue, 99999.0)
        e.evalue = 88888
        XCTAssertEqual(e.balance, 88888.0)

        t.etype = .Transfer
        e.value = 10000
        XCTAssertEqual(e.evalue, -10000.0)
        e.evalue = 20000
        XCTAssertEqual(e.transaction()!.value, -20000.0)
    }
}

