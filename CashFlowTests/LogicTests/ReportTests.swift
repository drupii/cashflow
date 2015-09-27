import UIKit
import XCTest

@testable import CashFlow

class ReportTest : XCTestCase {
    var report: Report!

    override func setUp() {
        super.setUp()
        
        TestCommon.installDatabase("testdata1")
        DataModel.instance()
    
        self.report = Report()
    }

    override func tearDown() {
        super.tearDown()
        self.report = nil
    }

    func testMonthly() {
        self.report.generate(Report.MONTHLY, asset: nil)

        XCTAssertEqual(1, self.report.reportEntries.count)
        let entry = report.reportEntries[0]

        //NSString *s = [TestCommon stringWithDate:report.date];
        //Assert([s isEqualToString:@"200901010000"]);
        XCTAssertEqual(100000.0, entry.totalIncome)
        XCTAssertEqual(-3100.0, entry.totalOutgo)
    }
}
