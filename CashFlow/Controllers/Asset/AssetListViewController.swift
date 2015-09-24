/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

class AssetListViewController : UIViewController,
        DataModelDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, BackupViewDelegate
{
    @IBOutlet var tableView: UITableView?
    var splitTransactionListViewController: TransactionListViewController?

    @IBOutlet weak var barActionButton: UIBarButtonItem?
    @IBOutlet weak var barSumLabel: UIBarButtonItem?
    @IBOutlet weak var toolbar: UIToolbar?
    
    private var _isLoadDone: Bool = false
    private var _loadingView: DBLoadingView?
    
    private var _ledger: Ledger?

    private var _iconArray: [UIImage] = []

    private var _selectedAssetIndex: Int = 0
    
    private var _asDisplaying: Bool = false
    private var _asActionButton: UIActionSheet?

    private var _assetToBeDelete: Asset?
    
    private var _pinChecked: Bool = false

    override func viewDidLoad() {
        print("AssetListViewController:viewDidLoad")
        super.viewDidLoad()

        //[AppDelegate trackPageview:@"/AssetListViewController"];

        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            // 行高さ自動調整 (iOS8以降)
            tableView!.estimatedRowHeight = 48
            tableView!.rowHeight = UITableViewAutomaticDimension
        } else {
            tableView!.rowHeight = 48
        }

        _pinChecked = false
        _asDisplaying = false
    
        _ledger = nil
	
        // title 設定
        self.title = _L("Assets")
	
        // "+" ボタンを追加
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addAsset"))
        self.navigationItem.rightBarButtonItem = plusButton
	
        // Edit ボタンを追加
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
	
        // icon image をロード
        _iconArray = []
        let n = Asset.numAssetTypes()

        for i in 0..<n {
            let iconName = Asset.iconNameWithType(i)
        
            /* TODO: xsassets に対して以下の記法は使えなくなった模様。
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
            UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
            */
            let icon = UIImage(named: iconName)
        
            assert(icon != nil)
            _iconArray.append(icon!)
        }
    
        if isIpad() {
            // アクションボタンを出さない
            var items = toolbar!.items!
            for (idx, item) in items.enumerate() {
                if item == barActionButton {
                    items.removeAtIndex(idx)
                    toolbar!.items = items
                    break
                }
            }
        }

        if isIpad() {
            var s = self.preferredContentSize;
            s.height = 600
            self.preferredContentSize = s
        }

        // データロード開始
        let dm = DataModel.instance()
        _isLoadDone = dm.isLoadDone;
        if (!_isLoadDone) {
            dm.startLoad(self)
    
            // Loading View を表示させる
            _loadingView = DBLoadingView(title: "Loading")
            _loadingView!.setOrientation(UIApplication.sharedApplication().statusBarOrientation)
            _loadingView!.userInteractionEnabled = true // 下の View の操作不可にする
            _loadingView!.show(self.view.window)
        }
    }

    override func didReceiveMemoryWarning() {
        print("AssetListViewController:didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }

    // MARK: - DataModelDelegate
    func dataModelLoaded() {
        print("AssetListViewController:dataModelLoaded")

        _isLoadDone = true
        _ledger = DataModel.getLedger()
    
        self.performSelectorOnMainThread(Selector("_dataModelLoadedOnMainThread"), withObject: nil, waitUntilDone: false)
    }

    func _dataModelLoadedOnMainThread() {
        // dismiss loading view
        _loadingView?.dismissAnimated(false)
        _loadingView = nil

        self.reload()
 
        /*
        '12/3/15
        安定性向上のため、iPad 以外では最後に使った資産に遷移しないようにした。
        起動時に TransactionListVC で固まるケースが多いため。
    
        '12/8/12 一旦元に戻す。
        */
        //if (IS_IPAD) {
            self.showInitialAsset()
        //}
    }

    /**
     * 初回表示する資産インデックスを返す
     */
    private func firstShowAssetIndex() -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey("firstShowAssetIndex")
    }

    /**
     * 初回表示する資産インデックスを保存する
     */
    private func setFirstShowAssetIndex(assetIndex: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(assetIndex, forKey: "firstShowAssetIndex")
        defaults.synchronize()
    }
    
    /**
     * 最後に使用した資産を表示
     */
    private func showInitialAsset() {
        var asset: Asset?
    
        // 前回選択資産を選択
        let firstShowAssetIndex = self.firstShowAssetIndex()
        if (firstShowAssetIndex >= 0 && _ledger!.assetCount > firstShowAssetIndex) {
            asset = _ledger!.assetAtIndex(firstShowAssetIndex)
        }
        // iPad では、前回選択資産がなくても、最初の資産を選択する
        if isIpad() && asset == nil && _ledger!.assetCount > 0 {
            asset = _ledger!.assetAtIndex(0)
        }

        // TransactionListView を表示
        if (asset != nil) {
            if isIpad() {
                self.splitTransactionListViewController!.assetKey = asset!.pid;
                self.splitTransactionListViewController!.reload()
            } else {
                let vc = TransactionListViewController.instantiate()
                vc.assetKey = asset!.pid;
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        
        // 資産が一個もない場合は警告を出す
        if _ledger!.assetCount == 0 {
            AssetListViewController.noAssetAlert()
        }
    }

    /**
     * 資産が存在しないという警告を表示
     */
    class func noAssetAlert() {
        let v = UIAlertView(title: "No assets", message: _L("At first, please create and select an asset."),
            delegate: nil, cancelButtonTitle: _L("Dismiss"))
        v.show()
    }

    /**
     * リロード
     */
    func reload() {
        if (!_isLoadDone) {
            return
        }
    
        _ledger = DataModel.getLedger()
        _ledger!.rebuild()
        tableView!.reloadData()

        // 合計欄
        var value: Double = 0.0
        for i in 0..<_ledger!.assetCount {
            value += _ledger!.assetAtIndex(i).lastBalance
        }
        let s1 = _L("Total")
        let s2 = CurrencyManager.formatCurrency(value)
        let lbl = "\(s1) \(s2)"
        barSumLabel!.title = lbl
    
        Database.instance().updateModificationDate() // TODO : ここでやるのは正しくないが、、、
    }

    override func viewWillAppear(animated: Bool) {
        //print("AssetListViewController:viewWillAppear")
        super.viewWillAppear(animated)
        self.reload()
    }

    private static var isInitial: Bool = true
    
    override func viewDidAppear(animated: Bool) {
        //print("AssetListViewController:viewDidAppear")
        super.viewDidAppear(animated)

        if AssetListViewController.isInitial {
            AssetListViewController.isInitial = false
        }
        else if !isIpad() {
            // 初回以外：初期起動する画面を資産一覧画面に戻しておく
            self.setFirstShowAssetIndex(-1)
        }
    }

    // MARK: - TableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        //if (tv.editing) return 1 else return 2;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!_isLoadDone) {
            return 0
        }
    
        return _ledger!.assetCount
    }

    private func assetIndex(indexPath: NSIndexPath) -> Int {
        return indexPath.row
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "assetCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)!
        // prototype cell を使用するため、cell は常に自動生成される

        // 資産
        let asset = _ledger!.assetAtIndex(self.assetIndex(indexPath))

        // 資産タイプ範囲外対応
        var type = asset.type
        if (type < 0 || _iconArray.count <= type) {
            type = 0
        }
        cell.imageView!.image = _iconArray[type]

        // 資産名
        cell.textLabel!.text = asset.name;

        // 残高
        let value = asset.lastBalance
        let c = CurrencyManager.formatCurrency(value)
        cell.detailTextLabel!.text = c
    
        if (value >= 0) {
            cell.detailTextLabel!.textColor = UIColor.blueColor()
        } else {
            cell.detailTextLabel!.textColor = UIColor.redColor()
        }
	
        return cell
    }

    // MARK: - UITableViewDelegate

    //
    // セルをクリックしたときの処理
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        let assetIndex = self.assetIndex(indexPath)
        if (assetIndex < 0) {
            return
        }

        // 最後に選択した asset を記憶
        self.setFirstShowAssetIndex(assetIndex)
	
        let asset = _ledger!.assetAtIndex(assetIndex)

        // TransactionListView を表示
        if isIpad() {
            self.splitTransactionListViewController!.assetKey = asset.pid;
            self.splitTransactionListViewController!.reload()
        } else {
            let vc = TransactionListViewController.instantiate()
            vc.assetKey = asset.pid

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // アクセサリボタンをタップしたときの処理 : アセット変更
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let assetIndex = self.assetIndex(indexPath)
        if assetIndex >= 0 {
            _selectedAssetIndex = indexPath.row;
            self.performSegueWithIdentifier("show", sender: self)
        }
    }

    // 新規アセット追加
    private func addAsset() {
        _selectedAssetIndex = -1;
        self.performSegueWithIdentifier("show", sender:self)
    }

    // 画面遷移
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show" {
            let vc = segue.destinationViewController as! AssetViewController
            vc.setAssetIndex(_selectedAssetIndex)
        }
    }

    // Editボタン処理
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
	
        // tableView に通知
        self.tableView!.setEditing(editing, animated: animated)
        self.navigationItem.rightBarButtonItem!.enabled = !editing;
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.assetIndex(indexPath) < 0 {
            return false
        }
        return true
    }

    // 編集スタイルを返す
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.assetIndex(indexPath) < 0 {
            return .None
        }
        return .Delete
    }

    // 削除処理
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle != .Delete {
            return
        }
        
        let assetIndex = self.assetIndex(indexPath)
        _assetToBeDelete = _ledger!.assetAtIndex(assetIndex)

        // iOS8 : UIAlertController を使う
        let alertController = UIAlertController(title: "Warning", message: _L("ReallyDeleteAsset"), preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: _L("Delete Asset"), style: UIAlertActionStyle.Destructive,
            handler: {(action:UIAlertAction!) -> Void in
                self.actionDelete(0)
            })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    /**
     * 削除処理
     */
    private func actionDelete(buttonIndex: Int) {
        if (buttonIndex != 0) {
            return // cancelled;
        }
	
        let pid = _assetToBeDelete!.pid
        _ledger!.deleteAsset(_assetToBeDelete!)
    
        if isIpad() {
            let svc = self.splitTransactionListViewController!
            if (svc.assetKey == pid) {
                svc.assetKey = -1
                svc.reload()
            }
        }

        self.tableView!.reloadData()
    }

    // 並べ替え処理
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.assetIndex(indexPath) >= 0
    }

    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        // 合計額(section:1)には移動させない
        let idx = NSIndexPath(forRow: proposedDestinationIndexPath.row, inSection: 0)
        return idx
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let fromIndex = self.assetIndex(sourceIndexPath)
        let toIndex = self.assetIndex(destinationIndexPath)
        if fromIndex < 0 || toIndex < 0 {
            return
        }

        DataModel.getLedger().reorderAsset(fromIndex, to: toIndex)
    }

    // MARK: - Show Report
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Report

    @IBAction func showReport(sender: AnyObject?) {
        let reportVC = ReportViewController.instantiate()
        reportVC.setAsset(nil)
    
        let nv = UINavigationController(rootViewController: reportVC)
        if isIpad() {
            nv.modalPresentationStyle = .PageSheet
        }
        self.navigationController!.presentViewController(nv, animated: true, completion: nil)
    }

    // MARK: - Action Sheet
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Action Sheet 処理

    @IBAction func doAction(sender: AnyObject?) {
        if _asDisplaying {
            return
        }
        _asDisplaying = true
    
        let s = UIActionSheet(title: "", delegate: self, cancelButtonTitle: _L("Cancel"), destructiveButtonTitle: nil)
        
        let strExport = _L("Export")
        let strAllAssets = _L("All assets")
        s.addButtonWithTitle("\(strExport) \(strAllAssets)")
        
        let strSync = _L("Sync")
        let strBackup = _L("Backup")
        s.addButtonWithTitle("\(strSync) / \(strBackup)")

        s.addButtonWithTitle(_L("Config"))
        s.addButtonWithTitle(_L("Info"))
        
        _asActionButton = s

        //if (IS_IPAD) {
        //    [mAsActionButton showFromBarButtonItem:mBarActionButton animated:YES];
        //}
        
        _asActionButton!.showInView(self.view)
    }

    func _actionActionButton(buttonIndex: Int) {
        var backupVC: BackupViewController?
    
        _asDisplaying = false

        var nv: UINavigationController? = nil
        
        switch (buttonIndex) {
            case 1:
                nv = ExportVC.instantiate(nil)
                break;
            
            case 2:
                nv = (UIStoryboard(name: "BackupView", bundle: nil).instantiateInitialViewController() as! UINavigationController)
                backupVC = (nv!.topViewController as! BackupViewController)
                backupVC!.setDelegate(self)
                break;
            
            case 3:
                nv = (UIStoryboard(name: "ConfigView", bundle: nil).instantiateInitialViewController() as! UINavigationController)
                break;
            
            case 4:
                nv = InfoViewController.instantiate()
                break;
            
            default:
                return;
        }
    
        //if (IS_IPAD) {
        //    nv.modalPresentationStyle = UIModalPresentationFormSheet; //UIModalPresentationPageSheet;
        //}
        self.navigationController!.presentViewController(nv!, animated: true, completion: nil)
    }

    // actionSheet ハンドラ
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet == _asActionButton) {
            _asActionButton = nil;
            self._actionActionButton(buttonIndex)
        }
        else {
            assert(false)
        }
    }

    // MARK: - BackupViewDelegate
    func backupViewFinished(backupViewController: BackupViewController!) {
        self.reload()
        if isIpad() {
            self.splitTransactionListViewController!.assetKey = -1
            self.splitTransactionListViewController!.reload()
        }
    }

    // MARK: - Rotation
    
    override func shouldAutorotate() -> Bool {
        return isIpad()
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if isIpad() {
            return .All
        }
        return .Portrait
    }
}
