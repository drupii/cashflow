/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

class AssetViewController : UITableViewController,
    GenEditTextViewDelegate, GenSelectListViewDelegate, UIActionSheetDelegate
{
    var _assetIndex: Int = 0
    var _asset: Asset?

    var _delButton: UIButton?
    
    let ROW_NAME = 0
    let ROW_TYPE = 1

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //[AppDelegate trackPageview:@"/AssetViewController"];
    
        self.title = _L("Asset");
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("saveAction"))
    }

    // 処理するトランザクションをロードしておく
    func setAssetIndex(n: Int) {
        _assetIndex = n;

        if (_assetIndex < 0) {
            // 新規
            _asset = Asset()
            _asset!.name = ""
            _asset!.sorder = 99999
        } else {
            // 変更
            _asset = DataModel.getLedger().assetAtIndex(_assetIndex)
        }
    }

    // 表示前の処理
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
	
        if (_assetIndex >= 0 && _delButton != nil) {
            self.view.addSubview(_delButton!)
        }
		
        self.tableView.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //[[self tableView] reloadData];
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
	
        if (_assetIndex >= 0) {
            _delButton?.removeFromSuperview()
        }
    }

    /////////////////////////////////////////////////////////////////////////////////
    // TableView 表示処理

    // セクション数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // 行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    // 行の内容
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let MyIdentifier = "assetViewCell"

        let cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier)!

        let name = cell.textLabel!
        let value = cell.detailTextLabel!
    
        switch (indexPath.row) {
        case ROW_NAME:
            name.text = _L("Asset Name")
            value.text = _asset!.name
            break
            
        case ROW_TYPE:
            name.text = _L("Asset Type")
            value.text = Asset.typeNameWithType(_asset!.type)
            break
            
        default:
            break
        }

        return cell
    }

    ///////////////////////////////////////////////////////////////////////////////////
    // 値変更処理

    // セルをクリックしたときの処理
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let nc = self.navigationController

        // view を表示
        var vc: UIViewController?
        var ge: GenEditTextViewController?
        var gt: GenSelectListViewController?
        var typeArray: [String]?

        switch (indexPath.row) {
        case ROW_NAME:
            ge = GenEditTextViewController.create(self, title:_L("Asset Name"), identifier:0)
            //ge = [GenEditTextViewController genEditTextViewController:self title:_L(@"Asset Name") identifier:0];
            ge!.text = _asset!.name;
            vc = ge;
            break;

        case ROW_TYPE:
            typeArray = Asset.typeNamesArray()
            gt = GenSelectListViewController.create(self, items:typeArray!, title:_L("Asset Type"), identifier:0)
            gt!.selectedIndex = _asset!.type
            vc = gt
            break
            
        default:
            break
        }
	
        if (vc != nil) {
            nc?.pushViewController(vc!, animated: true)
        }
    }

    // delegate : 下位 ViewController からの変更通知
    func genEditTextViewChanged(vc: GenEditTextViewController, identifier id:Int) {
        _asset!.name = vc.text
    }

    func genSelectListViewChanged(vc: GenSelectListViewController, identifier:Int) -> Bool {
        _asset!.type = vc.selectedIndex
        return true
    }


////////////////////////////////////////////////////////////////////////////////
// 削除処理
/*
#if false
- (void)delButtonTapped
{
    UIActionSheet *as = [[UIActionSheet alloc]
                            initWithTitle:_L(@"ReallyDeleteAsset")
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:_L(@"Delete Asset")
                            otherButtonTitles:nil];
    as.actionSheetStyle = UIActionSheetStyleDefault;
    [as showInView:self.view];
    [as release];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return; // cancelled;
    }
	
    [[DataModel ledger] deleteAsset:asset];
    [self.navigationController popViewControllerAnimated:YES];
}
#endif
*/
    
    ////////////////////////////////////////////////////////////////////////////////
    // 保存処理
    func saveAction() {
        let ledger = DataModel.getLedger()

        if (_assetIndex < 0) {
            ledger.addAsset(_asset!)
        } else {
            ledger.updateAsset(_asset!)
        }
        _asset = nil;
	
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Rotation

    override func shouldAutorotate() -> Bool {
        return isIpad()
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if (isIpad()) {
            return .All
        }
        return .Portrait
    }
}
