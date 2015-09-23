import Foundation
import XCTest

class CurrencyManagerTests : XCTestCase {
    var manager: CurrencyManager = CurrencyManager.instance

    override func setUp() {
        super.setUp()
        manager = CurrencyManager.instance
    }

    func testSystem() {
        manager.baseCurrency = nil
        let s = CurrencyManager.formatCurrency(1234.56)
        XCTAssert(s == "￥1,235" || s == "$1,234.56")
    }
    
    func testUSD() {
        manager.baseCurrency = "USD"
        let s = CurrencyManager.formatCurrency(1234.56)
        XCTAssertEqual("$1,234.56", s)
    }
    
    func testJPY() {
        manager.baseCurrency = "JPY"
        let s = CurrencyManager.formatCurrency(1234)
        XCTAssert(s == "¥1,234" || s == "￥1,234")
    }

    func testEUR() {
        manager.baseCurrency = "EUR"
        let s = CurrencyManager.formatCurrency(1234.56)
        XCTAssertEqual("€1,234.56", s);
    }

    func testOther() {
        manager.baseCurrency = "CAD"
        let s = CurrencyManager.formatCurrency(1234.56)
        XCTAssertEqual("CA$1,234.56", s)
    }
}


