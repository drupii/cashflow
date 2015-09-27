import UIKit
import XCTest

class TimeTest : XCTestCase {
    func testAPMPM() {
        let f = NSDateFormatter()

        f.dateFormat = "HH"
        let d = NSDate(timeIntervalSinceReferenceDate: 60*60*13)

        print(f.stringFromDate(d))

        f.locale = nil
        print(f.stringFromDate(d))
    
        T(f, locale: "ja_JP", date: d)
    }
    
    private func T(formatter: NSDateFormatter, locale: String, date: NSDate) {
        formatter.locale = NSLocale(localeIdentifier: locale)

        let s = formatter.stringFromDate(date)
        print("\(locale) \(s)")
    }
}