import UIKit
import XCTest

/**
   UINavigationController 付き UIViewController の TestCase
*/
class ViewControllerWithNavBarTestCase : ViewControllerTestCase {

    override func createBaseViewController() -> UIViewController {
        let nv = UINavigationController(rootViewController: self.viewController)
        return nv
    }
}
