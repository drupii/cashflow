/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

/**
 * Transaction List View Controller
 */
@available(iOS 8.0, *)
class TransactionListViewController : UIViewController,
    UITableViewDelegate,UITableViewDataSource, CalculatorViewDelegate, UISplitViewControllerDelegate,
    BackupViewDelegate, UIPopoverControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, AdManagerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barBalanceLabel: UIBarButtonItem!
    @IBOutlet weak var barActionButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var splitAssetListViewController: AssetListViewController!
    var assetKey: Int = 0

    // 検索
    var searchController: UISearchController!
    var searchResults: [AssetEntry] = []

    private var tappedIndex: Int = 0

    // For Free version
    private var adManager: AdManager?
    private var isAdShowing: Bool = false

    private var popoverController: UIPopoverController?
    private var tableViewInsetSave: UIEdgeInsets?

    static func instantiate() -> TransactionListViewController {
        let sb = UIStoryboard(name: "TransactionListView", bundle:nil)
        let vc = sb.instantiateInitialViewController() as! TransactionListViewController
        return vc
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.assetKey = -1
    }

    var asset: Asset? {
        get {
            if self.assetKey < 0 {
                return nil
            }

            // 安全のため、cache を使わないようにした
            /*
            if (self.assetCache != nil && self.assetCache.pid == self.assetKey) {
                return self.assetCache
            }
            self.assetCache = DataModel.instance().ledger.assetWithKey(self.assetKey)
            return self.assetCache
            */

            return DataModel.instance().ledger.assetWithKey(self.assetKey)
        }
    }

    override func viewDidLoad() {
        print("TransactionListViewController:viewDidLoad")

        super.viewDidLoad()
    
        // TransactionCell を register する
        TransactionCell.registerCell(self.tableView!)
    
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            // iOS8 以降: 行高さ自動調整
            self.tableView.estimatedRowHeight = 48.0
            self.tableView.rowHeight = UITableViewAutomaticDimension;
        } else {
            self.tableView.rowHeight = 48.0
        }
    
        //[AppDelegate trackPageview:@"/TransactionListViewController"];
	
        // title 設定
        //self.title = _L(@"Transactions");
        if (self.asset == nil) {
            self.title = ""
        } else {
            self.title = self.asset?.name
        }
	
        // "+" ボタンを追加
        let plusButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addTransaction"))
        self.navigationItem.rightBarButtonItem = plusButton
	
        // Edit ボタンを追加
        // TBD
        //self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
        // Notifiction 受け取り手続き
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: Selector("willEnterForeground"), name: "willEnterForeground", object: nil)
        nc.addObserver(self, selector: Selector("willResignActive"), name: "willResignActive", object: nil)

        // SearchController 作成
        let sc = UISearchController(searchResultsController: nil)
        //sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        
        //sc.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44)
        sc.searchBar.sizeToFit()
        sc.searchBar.returnKeyType = .Done
        //sc.searchBar.placeholder = "Search"
        sc.searchResultsUpdater = self
        //sc.searchBar.delegate = self
        sc.delegate = self
        self.searchController = sc
        
        // Header に SearchBar を設定
        self.tableView.tableHeaderView = sc.searchBar
        
        // AdManager 設定
        self.isAdShowing = false
        self.adManager = AdManager.getInstance()
        self.adManager?.attach(self, rootViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
        
        self.adManager?.detach()
    }

    func reload() {
        self.title = self.asset?.name
        self.updateBalance()
        self.tableView?.reloadData()
    
        // 検索中
        if isSearching() {
            self.updateSearchResultWithDesc(self.searchController!.searchBar.text)
            self.tableView!.reloadData()
        }
    
        self.dismissPopover()
    }

    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        self.popoverController = nil;
    }

    private func dismissPopover() {
        if (isIpad()
            && self.popoverController != nil
            && self.popoverController!.popoverVisible
            && tableView != nil && tableView!.window != nil /* for crash problem */)
        {
            self.popoverController!.dismissPopoverAnimated(true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reload()
    
        Database.instance().updateModificationDate() // TODO : ここでやるのは正しくないが、、、
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.adManager?.requestShowAd()
    }

    /**
     * アプリが background に入るときの処理
     */
    func willResignActive() {
        /*
        if let s = self.actionSheet {
            s.dismissWithClickedButtonIndex(0, animated: false)
            self.actionSheet = nil
        }
        */
        //[self _dismissPopover];  // TODO: 効かない、、、
    }

    /**
     * アプリが foreground になった時の処理。
     * これは AppDelegate の applicationWillEnterForeground から呼び出される。
     */
    func willEnterForeground() {
        // 表示開始
        self.adManager?.requestShowAd()
    }
    
    /**
     * 広告表示
     */
    func showAd(adManager: AdManager, adView: UIView, adSize: CGSize) {
        if self.isAdShowing {
            print("Ad is already showing!")
            return
        }
    
        print("showAd")
        self.isAdShowing = true

        //NSLog(@"adSize:%fx%f", adSize.width, adSize.height);
    
        let frame = self.tableView.frame
        //NSLog(@"tableView size:%fx%f", frame.size.width, frame.size.height);

        // TODO: 横幅制限。iPad landscape の場合、detail view の横幅は iPad portrait の横幅より
        // 狭いので、制限する必要がある。
        /*
        const float ad_width_max = 703;
        if (adSize.width > ad_width_max) {
            adSize.width = ad_width_max;
        }
        */
    
        // 広告の位置を画面外に設定
        var aframe = frame
        aframe.origin.x = (frame.size.width - adSize.width) / 2
        aframe.origin.y = frame.size.height // 画面外
        aframe.size = adSize
    
        adView.frame = aframe
        self.view.addSubview(adView)
        self.view.bringSubviewToFront(self.toolbar)
    
        /*
         * 広告領域分だけ、tableView の下部をあける
         */
        // 以下の方法は autolayout では動作しない
        /*CGRect tframe = frame;
        tframe.origin.x = 0;
        tframe.origin.y = 0;
        tframe.size.height -= adSize.height;
        _tableView.frame = tframe;*/

        // autolayout を使う方法。inset を使うほうが良いので、修正。
        /*
        NSLayoutConstraint *c = [NSLayoutConstraint
                             constraintWithItem:_toolbar
                             attribute:NSLayoutAttributeTop
                             relatedBy:NSLayoutRelationEqual
                             toItem:_tableView
                             attribute:NSLayoutAttributeBottom
                             multiplier:1
                             constant:adSize.height];
        [self.view addConstraint:c];
        */
    
        // inset を調整する方法
        if self.tableViewInsetSave == nil {
            self.tableViewInsetSave = tableView.contentInset
        }
        var inset: UIEdgeInsets = tableView.contentInset
        inset.bottom += adSize.height
        tableView.contentInset = inset

        // 表示位置
        aframe = frame
        aframe.origin.x = (frame.size.width - adSize.width) / 2
        aframe.origin.y = frame.size.height - adSize.height
        aframe.size = adSize
    
        // 広告をアニメーション表示させる
        UIView.beginAnimations("ShowAd", context: nil)
        adView.frame = aframe
        UIView.commitAnimations()
    }

    /**
     * 広告を隠す
     */
    func removeAd(adManager: AdManager, adView: UIView, adSize: CGSize) {
        if !self.isAdShowing {
            print("Ad is already removed!")
            return
        }
        print("removeAd")
        self.isAdShowing = false
    
        let frame = tableView.bounds
        
        // tableView のサイズをもとに戻す
        /*
        frame.origin.x = 0;
        frame.origin.y = 0;
        frame.size.height += adSize.height;
        _tableView.frame = frame;
        */
        tableView.contentInset = self.tableViewInsetSave!
    
        // 広告の位置
        var aframe = frame
        aframe.origin.x = (frame.size.width - adSize.width) / 2
        aframe.origin.y = frame.size.height
        aframe.size = adSize
    
        // 広告をアニメーション表示させる
        UIView.beginAnimations("HideAd", context: nil)
        adView.frame = aframe
        UIView.commitAnimations()
    
        adView.removeFromSuperview()
    }
    
    private func updateBalance() {
        guard let asset = self.asset else {
            return
        }
        let lastBalance = asset.lastBalance
        let bstr = CurrencyManager.formatCurrency(lastBalance)

        //UILabel *tableTitle = (UILabel *)[self.tableView tableHeaderView];
        //tableTitle.text = [NSString stringWithFormat:@"%@ %@", _L(@"Balance"), bstr];
	
        let balanceLabel = _L("Balance")
        self.barBalanceLabel.title = "\(balanceLabel) \(bstr)"
    
        if isIpad() {
            self.splitAssetListViewController.reload()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissPopover()
    }

    // MARK: - TableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let asset = self.asset else {
            return 0
        }

        if isSearching() {
            return self.searchResults.count
        } else {
            return asset.entryCount + 1
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.rowHeight
    }

    // 指定セル位置に該当する entry Index を返す
    private func entryIndexWithIndexPath(indexPath: NSIndexPath, tableView:UITableView) -> Int {
        if isSearching() {
            return self.searchResults.count - 1 - indexPath.row
        } else {
            return self.asset!.entryCount - 1 - indexPath.row
        }
    }

    // 指定セル位置の Entry を返す
    private func entryWithIndexPath(indexPath: NSIndexPath, tableView:UITableView) -> AssetEntry? {
        let idx = self.entryIndexWithIndexPath(indexPath, tableView: tableView)

        if (idx < 0) {
            return nil  // initial balance
        }
        var e: AssetEntry
        if isSearching() {
            e = self.searchResults[idx]
        } else {
            e = self.asset!.entryAt(idx)
        }
        return e
    }

    //
    // セルの内容を返す
    //
    private let TAG_DESC = 1
    private let TAG_DATE = 2
    private let TAG_VALUE = 3
    private let TAG_BALANCE = 4

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let e = self.entryWithIndexPath(indexPath, tableView:tableView)
        
        var cell: TransactionCell
        if e != nil {
            cell = TransactionCell.transactionCell(tableView, forIndexPath: indexPath).updateWithAssetEntry(e!)
        }
        else {
            cell = TransactionCell.transactionCell(tableView, forIndexPath: indexPath).updateAsInitialBalance(self.asset!.initialBalance)
        }
        return cell;
    }
    
    // MARK: - UITableViewDelegate

    //
    // セルをクリックしたときの処理
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        let idx = self.entryIndexWithIndexPath(indexPath, tableView: tableView)

        if (idx == -1) {
            // initial balance cell
            let v = CalculatorViewController.instantiate()
            v.delegate = self
            v.value = self.asset!.initialBalance

            let nv = UINavigationController(rootViewController: v)
        
            if !isIpad() {
                self.presentViewController(nv, animated: true, completion: nil)
            } else {
                self.dismissPopover()
                self.popoverController = UIPopoverController(contentViewController: nv)
                self.popoverController!.delegate = self
                self.popoverController!.presentPopoverFromRect(tableView.cellForRowAtIndexPath(indexPath)!.frame,
                    inView: tableView, permittedArrowDirections: .Any, animated: true)
            }
        } else if idx >= 0 {
            // transaction view を表示
            if isSearching() {
                let e = self.searchResults[idx]
                self.tappedIndex = e.originalIndex
            } else {
                self.tappedIndex = idx
            }
        
            self.performSegueWithIdentifier("show", sender: self)
        }
    }

    // TransactionView への画面遷移
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show" {
            let vc = segue.destinationViewController as! TransactionViewController
            vc.asset = self.asset
            vc.setTransactionIndex(self.tappedIndex)
        }
    }

    // CalculatorViewDelegate: 初期残高変更処理
    func calculatorViewChanged(vc: CalculatorViewController) {
        self.asset!.initialBalance = vc.value

        self.asset!.updateInitialBalance()
        self.asset!.rebuild()
        self.reload()
    }

    // 新規トランザクション追加
    func addTransaction() {
        if self.asset == nil {
            AssetListViewController.noAssetAlert()
            return
        }
            
        self.tappedIndex = -1
        self.performSegueWithIdentifier("show", sender: self)
    }

    // Editボタン処理 (現在、TransactionListView には Edit ボタンがないため未使用)
    override func setEditing(editing: Bool, animated: Bool) {
        if self.asset == nil {
            return
        }
    
        super.setEditing(editing, animated: animated)
	
        // tableView に通知
        self.tableView.setEditing(editing, animated: animated)

        //
        self.navigationItem.rightBarButtonItem!.enabled = !editing
    }

    // 編集スタイルを返す
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let entryIndex = self.entryIndexWithIndexPath(indexPath, tableView:tableView)
        if (entryIndex < 0) {
            // initial balance cell
            return .None
        }
        return .Delete
    }

    // 編集完了(ここでは削除のみ)処理
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let entryIndex = self.entryIndexWithIndexPath(indexPath, tableView:tableView)

        if (entryIndex < 0) {
            // initial balance cell : do not delete!
            return
        }

        if (editingStyle == .Delete) {
            if isSearching() {
                let e = self.searchResults[entryIndex]
                self.asset!.deleteEntryAt(e.originalIndex)
            
                // 検索結果一覧を更新する
                self.updateSearchResultWithDesc(self.searchController!.searchBar.text)
            } else {
                self.asset!.deleteEntryAt(entryIndex)
            }

            // 残高再計算
            self.updateBalance()

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.reloadData()
        }

        if isIpad() {
            self.splitAssetListViewController?.reload()
        }
    }

    // MARK: - Show Report
    @IBAction func showReport(sender: AnyObject) {
        let reportVC = ReportViewController.instantiate()
        reportVC.setAsset(self.asset)

        let nv = UINavigationController(rootViewController: reportVC)
        if isIpad() {
            nv.modalPresentationStyle = .PageSheet
        }
    
        //[self.navigationController pushViewController:vc animated:YES];
        self.navigationController?.presentViewController(nv, animated: true, completion: nil)
    }

    // MARK: - Action Controller handling

    // action sheet
    @IBAction func doAction(sender: AnyObject) {
        let c = UIAlertController(title: "Action", message: "", preferredStyle: .ActionSheet)
        
        c.addAction(UIAlertAction(title: _L("Cancel"), style: .Cancel, handler: { action in
            // do nothing
        }))
        
        let strExport = _L("Export")
        let strAllAssets = _L("All assets")
        c.addAction(UIAlertAction(title: "\(strExport) \(strAllAssets)", style: .Default, handler: { action in
            self.showActionView(ExportVC.instantiate(nil))
        }))
        

        let strThisAsset = _L("This asset")
        c.addAction(UIAlertAction(title: "\(strExport) \(strThisAsset)", style: .Default, handler: { action in
            self.showActionView(ExportVC.instantiate(self.asset!))
        }))
        
        // 3
        let strSync = _L("Sync")
        let strBackup = _L("Backup")
        c.addAction(UIAlertAction(title: "\(strSync) / \(strBackup)", style: .Default, handler: { action in
            let nv = UIStoryboard(name: "BackupView", bundle: nil).instantiateInitialViewController() as! UINavigationController
            let backupVC = nv.topViewController as! BackupViewController
            backupVC.setDelegate(self)
            self.showActionView(nv)
        }))
        
        // 4
        c.addAction(UIAlertAction(title: _L("Config"), style: .Default, handler: { action in
            let nv = UIStoryboard(name: "ConfigView", bundle: nil).instantiateInitialViewController() as! UINavigationController
            self.showActionView(nv)
        }))
        
        // 5
        c.addAction(UIAlertAction(title: _L("Info"), style: .Default, handler: { action in
            self.showActionView(InfoViewController.instantiate())
        }))

        if isIpad() {
            c.popoverPresentationController?.sourceView = self.view
            c.popoverPresentationController?.barButtonItem = self.barActionButton
        }
        self.presentViewController(c, animated: true, completion: nil)
    }

    private func showActionView(nv: UINavigationController) {
        if isIpad() {
            nv.modalPresentationStyle = .FormSheet
        }
            
        // iPad: actionsheet から presentViewController を直接呼び出せなくなった
        // http://stackoverflow.com/questions/24854802/presenting-a-view-controller-modally-from-an-action-sheets-delegate-in-ios8
         dispatch_async(dispatch_get_main_queue(), { () in
            self.navigationController?.presentViewController(nv, animated: true, completion: nil)
        })
    }

    // MARK: - BackupViewDelegate
    func backupViewFinished(backupViewController: BackupViewController!) {
        // リストアされた場合、mAssetCacheは無効になっている
        //mAssetCache = nil;
    
        if isIpad() {
            self.reload()
            self.splitAssetListViewController?.reload()
        }
    }

    // MARK: - Split View Delegate

    // Landscape -> Portrait への移行
    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController) {
        
        barButtonItem.title = _L("Assets")
        self.navigationItem.leftBarButtonItem = barButtonItem
    
        // 初期残高の popover が表示されている場合、ここで消さないと２つの Popover controller
        // が競合してしまう。
        self.dismissPopover()

        self.popoverController = pc
    }


    // Portrait -> Landscape への移行
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {

        self.navigationItem.leftBarButtonItem = nil
        self.dismissPopover()
    }

    // MARK: - Rotation
    override func shouldAutorotate() -> Bool {
        return isIpad()
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if isIpad() {
            return .All
        } else {
            return .Portrait
        }
    }

    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.updateSearchResultWithDesc(searchController.searchBar.text)
        self.tableView.reloadData()
    }

    // MARK: - 検索処理

    func isSearching() -> Bool {
        return self.searchController!.active
    }

    func updateSearchResultWithDesc(searchString: String?) {
        var allMatch = false
        if (searchString == nil || searchString!.isEmpty) {
            allMatch = true
        }

        self.searchResults.removeAll()

        let searchOptions: NSStringCompareOptions = [NSStringCompareOptions.CaseInsensitiveSearch, NSStringCompareOptions.DiacriticInsensitiveSearch]

        let count = self.asset!.entryCount
        for i in 0..<count {
            let e = self.asset!.entryAt(i)
            e.originalIndex = i
        
            if (allMatch) {
                self.searchResults.append(e)
                continue
            }
        
            // 文字列マッチ
            let desc: String = e.transaction()!.desc
            let foundRange = desc.rangeOfString(searchString!, options: searchOptions)
            if foundRange != nil {
                self.searchResults.append(e)
            }
        }
    }

    func didDismissSearchController(searchController: UISearchController) {
        self.searchResults.removeAll()
    
        // 検索中にデータが変更されるケースがあるので、ここで reload する
        self.tableView.reloadData()
    }
}

