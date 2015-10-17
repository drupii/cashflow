import UIKit
import XCTest

/**
   UIViewController 用の TestCase

   createViewController をオーバライドして使用すること
*/
class ViewControllerTestCase : XCTestCase {
    var viewController: UIViewController!
    var baseViewController: UIViewController!

    override func setUp() {
        super.setUp()

        self.viewController = self.createViewController()
        self.baseViewController = self.createBaseViewController()

        let window = UIApplication.sharedApplication().keyWindow!

        window.addSubview(self.baseViewController.view)
        window.bringSubviewToFront(self.baseViewController.view)
    }

    override func tearDown() {
        self.baseViewController!.view.removeFromSuperview()
        self.baseViewController = nil
        self.viewController = nil

        super.tearDown()
    }

    func createViewController() -> UIViewController? {
        return nil
    }

    func createBaseViewController() -> UIViewController? {
        return self.viewController
    }
    
    func createViewControllerFromStoryboard(name: String) -> UIViewController {
        return UIStoryboard(name: name, bundle: nil).instantiateInitialViewController()!
    }
    
    func execLoadView(viewController: UIViewController) {
        viewController.performSelectorOnMainThread(Selector("loadView"), withObject: nil, waitUntilDone: true)
    }
}
