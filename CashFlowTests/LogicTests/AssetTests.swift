import UIKit
import XCTest

@testable import CashFlow

class AssetTest : XCTestCase {
    var asset: Asset!

    override func setUp() {
        super.setUp()
        TestCommon.deleteDatabase()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWithData() {
        TestCommon.installDatabase("testdata1")

        let ledger = DataModel.getLedger()

        asset = ledger.assetAtIndex(0)
        XCTAssertEqual(1, asset.pid)
        XCTAssertEqual(0, asset.type)
        XCTAssertEqual("Cash", asset.name)
        XCTAssertEqual(0, asset.sorder)
        XCTAssertEqual(5000, asset.initialBalance)
    
        XCTAssertEqual(4, asset.entryCount)
        var e = asset.entryAt(0)
        XCTAssertEqual(-100, e.value)
        XCTAssertEqual(4900, e.balance)
        e = asset.entryAt(1)
        XCTAssertEqual(-800, e.value)
        XCTAssertEqual(4100, e.balance)
        e = asset.entryAt(2)
        XCTAssertEqual(-100, e.value)
        XCTAssertEqual(4000, e.balance)
        e = asset.entryAt(3)
        XCTAssertEqual(5000, e.value)
        XCTAssertEqual(9000, e.balance)

        asset = ledger.assetAtIndex(1)
        XCTAssertEqual(2, asset.pid)
        XCTAssertEqual(1, asset.type)
        XCTAssertEqual("Bank", asset.name)
        XCTAssertEqual(1, asset.sorder)
        XCTAssertEqual(100000, asset.initialBalance)

        XCTAssertEqual(2, asset.entryCount)
        e = asset.entryAt(0)
        XCTAssertEqual(-5000, e.value)
        XCTAssertEqual(95000, e.balance)
        e = asset.entryAt(1)
        XCTAssertEqual(100000, e.value)
        XCTAssertEqual(195000, e.balance)

        asset = ledger.assetAtIndex(2)
        XCTAssertEqual(3, asset.pid)
        XCTAssertEqual(2, asset.type)
        XCTAssertEqual("Card", asset.name)
        XCTAssertEqual(2, asset.sorder)
        XCTAssertEqual(-10000, asset.initialBalance)
    
        XCTAssertEqual(1, asset.entryCount)

        e = asset.entryAt(0)
        XCTAssertEqual( -2100, e.value)
        XCTAssertEqual(-12100, e.balance)
    }

    // 支払い取引の追加
    func testInsertOutgo() {
        // not yet
    }

    // 入金取引の追加
    func testInsertIncome() {
        // not yet
    }

    // 残高調整の追加
    func testInsertAdjustment() {
        TestCommon.installDatabase("testdata1")
        
        let ledger = DataModel.getLedger()
        let asset = ledger.assetAtIndex(0)
    
        XCTAssertEqual(9000, asset.lastBalance)

        // 新規エントリ
        let ae = AssetEntry(transaction: nil, asset: asset)

        ae.assetKey = asset.pid
        ae.transaction()!.etype = TransactionType.Adj
        ae.evalue = 10000.0
        ae.transaction()!.date = TestCommon.dateWithString("20090201000000")

        asset.insertEntry(ae)
        XCTAssertEqual(10000, asset.lastBalance)
    }

    // 資産間移動の追加
    func testInsertTransfer() {
        // not yet
    }

    // 初期残高変更処理
    func testChangeInitialBalance() {
        TestCommon.installDatabase("testdata1")
        let ledger = DataModel.getLedger()
        asset = ledger.assetAtIndex(0)

        XCTAssertEqual(5000, asset.initialBalance)
        XCTAssertEqual(9000, asset.lastBalance)
    
        asset.initialBalance = 0.0
        asset.rebuild()
        XCTAssertEqual(0, asset.initialBalance)

        var e = asset.entryAt(0)
        XCTAssertEqual(e.balance, -100)
        e = asset.entryAt(1)
        XCTAssertEqual(e.balance, -900)
        e = asset.entryAt(2)
        XCTAssertEqual(e.balance, 4000)    // 残高調整のため、balance 変化なし
        XCTAssertEqual(e.value, 4900)
    
        XCTAssertEqual(9000, asset.lastBalance)
    }

    // 取引削除
    func testDeleteEntryAt() {
        TestCommon.installDatabase("testdata1")
        let ledger = DataModel.getLedger()
    
        asset = ledger.assetAtIndex(0)
        XCTAssertEqual(5000, asset.initialBalance);

        asset.deleteEntryAt(3) // 資産間移動取引を削除する

        XCTAssertEqual(3, asset.entryCount)
        XCTAssertEqual(5000, asset.initialBalance)

        // 別資産の取引数が減って「いない」ことを確認(置換されているはず)
        XCTAssertEqual(2, ledger.assetAtIndex(1).entryCount)

        // データベースが更新されていることを確認する
        DataModel.load()
        XCTAssertEqual(3, asset.entryCount)
        XCTAssertEqual(2, ledger.assetAtIndex(1).entryCount)
    }

    // 先頭取引削除
    func testDeleteFirstEntry() {
        // not yet
    }

    // 古い取引削除
    func testDeleteOldEntriesBefore() {
        TestCommon.installDatabase("testdata1")
        let ledger = DataModel.getLedger()

        let asset = ledger.assetAtIndex(0)
        XCTAssertEqual(4, asset.entryCount)

        // 最初よりも早い日付の場合に何も削除されないこと
        var date = TestCommon.dateWithString("20081231000000")
        asset.deleteOldEntriesBefore(date)
        XCTAssertEqual(4, asset.entryCount)

        // 途中削除
        let e = asset.entryAt(2)
        asset.deleteOldEntriesBefore(e.transaction()!.date)
        XCTAssertEqual(2, asset.entryCount)

        // 最後の日付の後で削除
        date = TestCommon.dateWithString("20090201000000")
        asset.deleteOldEntriesBefore(date)
        XCTAssertEqual(0, asset.entryCount)

        // 残高チェック
        XCTAssertEqual(9000, asset.initialBalance)

        // データベースが更新されていることを確認する
        DataModel.load()
        XCTAssertEqual(0, asset.entryCount)
        XCTAssertEqual(9000, asset.initialBalance)
    }

    // replace : 日付変更、種別変更なし
    // replace : 通常から資産間移動に変更
    // replace : 資産間移動のままだけど相手資産変更
    // replace : 資産間移動のままだけど相手資産変更(dstAsset側)
    // replace : 資産間移動から通常に変更
    // replace : 資産間移動から通常に変更(dstAsset側)
}
