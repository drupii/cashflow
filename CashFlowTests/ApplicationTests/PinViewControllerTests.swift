import UIKit
import XCTest

@testable import CashFlow

class PinViewControllerTest : ViewControllerWithNavBarTestCase, PinViewDelegate {
    var mCheckResult: Bool = false
    var mIsCanceled: Bool = false
    var mIsFinished: Bool = false

    private func vc() -> PinViewController {
        return self.viewController! as! PinViewController
    }

    override func createViewController() -> UIViewController? {
        let bundle = NSBundle(forClass: PinViewControllerTest.self)
        return PinViewController(nibName: "PinView", bundle: bundle)
    }
    
    // MARK: - PinViewDelegate

    func pinViewFinished(vc: PinViewController!, isCancel: Bool) {
        mIsFinished = true
        mIsCanceled = isCancel
    }

    func pinViewCheckPin(vc: PinViewController!) -> Bool {
        if vc.value == "1234" {
            return true;
        }
        return false
    }
    
    func pinViewTouchIdFinished(vc: PinViewController!) {
    }

    // MARK: -

    override func setUp() {
        super.setUp()
    
        mIsFinished = false
        mIsCanceled = false
        self.vc().delegate = self
    
        self.vc().viewDidLoad() // ###
        self.vc().viewWillAppear(true) // ###
    }

    override func tearDown() {
        super.tearDown()
        //[vc viewWillDisappear:YES];
    }

    func testInitial() {
        XCTAssertEqual("", self.vc().value)
    
        XCTAssertNotNil(self.vc().navigationItem.rightBarButtonItem)
        XCTAssertNil(self.vc().navigationItem.leftBarButtonItem);
    }

    func testCancellable() {
        self.vc().enableCancel = true
        self.vc().viewDidLoad()
    
        XCTAssertNotNil(self.vc().navigationItem.rightBarButtonItem)
        XCTAssertNotNil(self.vc().navigationItem.leftBarButtonItem)
    }

    func testCancel() {
        self.vc().cancelAction(nil)
        XCTAssert(mIsFinished)
        XCTAssert(mIsCanceled)
    }

    func testFinish() {
        self.vc().doneAction(nil)
        XCTAssert(mIsFinished)
        XCTAssertFalse(mIsCanceled)
    }

    func testAutoFinish() {
        self.vc().onKeyIn("1")
        self.vc().onKeyIn("2")
        self.vc().onKeyIn("3")
        XCTAssertFalse(mIsFinished)
        self.vc().onKeyIn("4")
        XCTAssert(mIsFinished)
        XCTAssertFalse(mIsCanceled)
    }
}

