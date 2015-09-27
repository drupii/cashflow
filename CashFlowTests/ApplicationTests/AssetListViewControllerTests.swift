import UIKit
import XCTest

@testable import CashFlow

class AssetListViewControllerTest: ViewControllerWithNavBarTestCase {
    var vc: AssetListViewController!

    override func createViewController() -> UIViewController {
        // 最上位は navigation controller なので、ここから AssetListViewController を取り出す
        let nv = createViewControllerFromStoryboard("AssetListView") as! UINavigationController
        self.vc = nv.topViewController as! AssetListViewController

        // 重要: loadView を実行する
        execLoadView(vc)
        return vc
    }

    override func setUp() {
        TestCommon.installDatabase("testdata1")

        //[self rootViewController];
    
        // AssetView を表示させないようにガードする
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(-1, forKey: "firstShowAssetIndex")

        super.setUp() // ここで rootViewController が生成される
    
        // データはロード完了している (上の installDataBase で)
        vc.dataModelLoaded()
    }
    
/*
#if 0
- (void)waitUntilDataLoaded
{
    // AssetListViewController では、データロードは別スレッドで行われる
    // ここでデータロード完了を待つようにする
    // ただし、setUp からは呼べない(ViewController のハンドラがまだ呼ばれていない)
    DataModel *dm = [DataModel instance];
    while (!dm.isLoadDone) {
        [NSThread sleepForTimeInterval:0.01];
    }
}
#endif
    */

    func cellText(row: Int, section: Int) -> String {
        let index = NSIndexPath(forRow: row, inSection: section)
        let cell = self.vc.tableView(self.vc.tableView!, cellForRowAtIndexPath: index)
        print(cell.textLabel!.text)
        return cell.textLabel!.text!
    }
    
    func testNormal() {
        print("testNormal")

        self.vc.dataModelLoaded()
    
        XCTAssertEqual(1, vc.numberOfSectionsInTableView(vc.tableView!))

        // test number of rows
        XCTAssertEqual(3, vc.tableView(vc.tableView!, numberOfRowsInSection: 0))

        // test cell
        XCTAssertEqual("Cash", cellText(0, section:0))
        XCTAssertEqual("Bank", cellText(1, section:0))
        XCTAssertEqual("Card", cellText(2, section:0))
    }
}
