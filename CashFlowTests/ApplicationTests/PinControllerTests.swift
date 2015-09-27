import UIKit
import XCTest

@testable import CashFlow

class PinControllerTest : ViewControllerWithNavBarTestCase {
    var pinController: PinController!
    
    override func createViewController() -> UIViewController {
        // 最上位は navigation controller なので、ここから AssetListViewController を取り出す
        let nv = createViewControllerFromStoryboard("AssetListView") as! UINavigationController
        let av = nv.topViewController!

        // 重要: loadView を実行する
        execLoadView(av)
        return av
    }

    func assetListViewController() -> AssetListViewController? {
        return self.viewController as? AssetListViewController
    }


    // MARK: -
    override func setUp() {
        super.setUp()

        PinController._deleteSingleton()
        self.pinController = PinController.sharedController()

        //[self.vc viewDidLoad]; // ###
        //[self.vc viewWillAppear:YES]; // ###
    }

    override func tearDown() {
        //[vc viewWillDisappear:YES];
        super.tearDown()
    }

    func testNoPin() {
        let saved = self.pinController
    
        self.pinController.pin = nil
        self.pinController.firstPinCheck(self.viewController)
        // この時点で、Pin チェック完了したため、PinController の singleton は削除されているはず
    
        let new = PinController.sharedController()
        XCTAssert(new != saved)
    
        // modal view がでていないことを確認する
        //AssertNil(self.vc.modalViewController);
        XCTAssertNil(self.viewController.presentedViewController)
    }

    func testHasPin() {
        let saved = self.pinController
    
        self.pinController.pin = "1234"
        self.pinController.firstPinCheck(self.viewController)

        // Pin があるため、この時点ではまだ終了していないはず
        let new = PinController.sharedController()
        XCTAssert(new == saved);
    
        // modal view が出ていることを確認する
        let nv = self.viewController.presentedViewController as! UINavigationController
        XCTAssertNotNil(nv)
        
        let pv = nv.viewControllers[0] as? PinViewController
        XCTAssertNotNil(pv)
    }
}
