/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

class TransactionViewController: UIViewController,
    UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIActionSheetDelegate,
    EditMemoViewDelegate, EditTypeViewDelegate,
    EditDateViewDelegate, CalculatorViewDelegate,
    EditDescViewDelegate, CategoryListViewDelegate,
    CFCalendarViewControllerDelegate,
    UIPopoverControllerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var delButton: UIButton!
    @IBOutlet weak var barActionButon: UIBarButtonItem!
    @IBOutlet weak var rememberDateView: UIView!
    @IBOutlet weak var rememberDateLabel: UILabel!
    @IBOutlet weak var rememberDateSwitch: UISwitch!
    
    var asset: Asset!
    
    /** 編集中のエントリ */
    var editingEntry: AssetEntry!
    
    private var transactionIndex: Int = -1

    private var isModified: Bool = false

    private let typeArray: [String] = [_L("Payment"), _L("Deposit"), _L("Adjustment"), _L("Transfer")]

    private var asCancelTransaction: UIActionSheet?
    private var asAction: UIActionSheet?
    
    private var currentPopoverController: UIPopoverController?

    let ROW_DATE = 0
    let ROW_TYPE = 1
    let ROW_VALUE = 2
    let ROW_DESC  = 3
    let ROW_CATEGORY = 4
    let ROW_MEMO = 5

    let NUM_ROWS = 6

    // for debug
    //#define REFCOUNT(x) CFGetRetainCount((__bridge void *)(x))

    override func viewDidLoad() {
        super.viewDidLoad()

        //[AppDelegate trackPageview:@"/TransactionViewController"]
    
        self.isModified = false

        self.title = _L("Transaction")
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("saveAction"))

        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelAction"))

        self.rememberDateLabel.text = _L("Remember Date")

        if isNewTransaction() {
            // 日付記憶関連処理
            self.rememberDateSwitch.on = Transaction.hasLastUsedDate()
        }
    
        // 削除ボタンの背景と位置調整
        //UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0]
        //[_delButton setBackgroundImage:bg forState:UIControlStateNormal]
        self.delButton.setTitle(_L("Delete transaction"), forState: .Normal)
    
        /*if (IS_IPAD) {
            CGRect rect;
            rect = _delButton.frame;
            rect.origin.y += 100;
            _delButton.frame = rect;
        }*/
    }

    // 処理するトランザクションをロードしておく
    func setTransactionIndex(n: Int) {
        self.transactionIndex = n

        self.editingEntry = nil

        if self.transactionIndex < 0 {
            // 新規トランザクション
            self.editingEntry = AssetEntry(transaction: nil, asset: self.asset)
        } else {
            // 変更
            let orig = self.asset.entryAt(self.transactionIndex)
            self.editingEntry = orig.copy() as! AssetEntry
        }
    }

    func isNewTransaction() -> Bool {
        return self.transactionIndex < 0
    }

    // 表示前の処理
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let isNew = isNewTransaction()
	
        self.delButton.hidden = isNew
        self.rememberDateView.hidden = !isNew

        self.tableView.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //[[self tableView] reloadData]
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissPopover()
    }

    /////////////////////////////////////////////////////////////////////////////////
    // TableView 表示処理

    // MARK: - UITableViewDataSource

    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // 行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NUM_ROWS
    }

    // 行の内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getCellForField(indexPath, tableView: tableView)
    }

    private func getCellForField(indexPath: NSIndexPath, tableView: UITableView) -> UITableViewCell {
        let MyIdentifier = "transactionViewCells"
        //UILabel *name, *value;

        var cell = tableView.dequeueReusableCellWithIdentifier(MyIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: .Value2, reuseIdentifier: MyIdentifier)
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            cell!.accessoryType = .DisclosureIndicator
        }

        let name = cell!.textLabel!
        let value = cell!.detailTextLabel!

        //double evalue;
        switch (indexPath.row) {
        case ROW_DATE:
            name.text = _L("Date")
            value.text = DataModel.dateFormatter().stringFromDate(self.editingEntry.transaction()!.date)
            break

        case ROW_TYPE:
            name.text = _L("Type") // @"Transaction type"
            value.text = self.typeArray[self.editingEntry.transaction()!.type]
            break
		
        case ROW_VALUE:
            name.text = _L("Amount")
            let evalue = self.editingEntry.evalue
            value.text = CurrencyManager.formatCurrency(evalue)
            break
		
        case ROW_DESC:
            name.text = _L("Name")
            value.text = self.editingEntry.transaction()!.desc
            break
			
        case ROW_CATEGORY:
            name.text = _L("Category")
            value.text = DataModel.getCategories().categoryStringWithKey(self.editingEntry.transaction()!.category)
            break
			
        case ROW_MEMO:
            name.text = _L("Memo")
            value.text = self.editingEntry.transaction()!.memo
            break
            
        default:
            break
        }

        return cell!
    }

    ///////////////////////////////////////////////////////////////////////////////////
    // 値変更処理

    // MARK: - UITableViewDelegate

    // セルをクリックしたときの処理
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var vc: UIViewController?

        //EditTypeViewController *editTypeVC; // type
        //CalculatorViewController *calcVC;
        //EditDescViewController *editDescVC;
        //EditMemoViewController *editMemoVC; // memo
        //CategoryListViewController *editCategoryVC;

        let transaction = self.editingEntry.transaction()!
        
        // view を表示

        switch (indexPath.row) {
        case ROW_DATE:
            if Config.instance().dateTimeMode == .DateOnly {
                let calendarVc = CFCalendarViewController()
                calendarVc.delegate = self
                calendarVc.selectedDate = transaction.date
                //[calendarVc setCalendarViewControllerDelegate:self]
                vc = calendarVc
            } else {
                let editDateVC = EditDateViewController.instantiate()
                editDateVC.delegate = self
                editDateVC.date = transaction.date
                vc = editDateVC
            }
            break

        case ROW_TYPE:
            let editTypeVC = EditTypeViewController()
            editTypeVC.delegate = self
            editTypeVC.type = transaction.type
            editTypeVC.dstAsset = self.editingEntry.dstAsset()
            vc = editTypeVC
            break

        case ROW_VALUE:
            let calcVC = CalculatorViewController.instantiate()
            calcVC.delegate = self
            calcVC.value = self.editingEntry.evalue
            vc = calcVC
            break

        case ROW_DESC:
            let editDescVC = EditDescViewController.instantiate()
            editDescVC.delegate = self
            editDescVC.desc = transaction.desc
            editDescVC.category = transaction.category
            vc = editDescVC
            break

        case ROW_MEMO:
            let editMemoVC = EditMemoViewController(self, title: _L("Memo"), identifier: 0)
            editMemoVC.text = transaction.memo
            vc = editMemoVC
            break

        case ROW_CATEGORY:
            let editCategoryVC = CategoryListViewController()
            editCategoryVC.isSelectMode = true
            editCategoryVC.delegate = self
            editCategoryVC.selectedIndex = DataModel.getCategories().categoryIndexWithKey(transaction.category)
            vc = editCategoryVC
            break
            
        default:
            break
        }
        
        if isIpad() { // TBD
            let nc = UINavigationController(rootViewController: vc!)
        
            self.currentPopoverController = UIPopoverController(contentViewController: nc)
            self.currentPopoverController!.delegate = self

            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let rect = cell.frame

            // iOS8バグワークアラウンド。dispatch_asyncしないと遅い上に挙動がおかしい。
            dispatch_async(dispatch_get_main_queue(), { () in
                self.currentPopoverController!.presentPopoverFromRect(rect, inView: self.tableView!, permittedArrowDirections: .Any, animated: true)
            })
        } else {
            self.navigationController!.pushViewController(vc!, animated: true)
        }
    }

    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        if isIpad() && self.currentPopoverController != nil {
            self.currentPopoverController = nil
        }
    }

    func dismissPopover() {
        if isIpad() {
            if self.currentPopoverController != nil
                && self.currentPopoverController!.popoverVisible
                && self.view != nil && self.view.window != nil /* for crash problem */ {
                    self.currentPopoverController!.dismissPopoverAnimated(true)
            }
            self.tableView!.reloadData()
        }
    }

    // delegate : 下位 ViewController からの変更通知

    // MARK: - CFCalendarViewController delegates

    func cfcalendarViewController(aCalendarViewController: CFCalendarViewController!, didSelectDate aDate: NSDate!) {
        if (aDate == nil) {
            return; // do nothing (Clear button)
        }
    
        self.isModified = true
        self.editingEntry.transaction()!.date = aDate;
        //[self checkLastUsedDate:aDate]

        if isIpad() {
            self.dismissPopover()
        }

        // 選択時に自動で View を閉じない仕様なので、ここで閉じる
        aCalendarViewController?.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - EditView delegates

    func editDateViewChanged(vc: EditDateViewController!) {
        self.isModified = true

        self.editingEntry.transaction()!.date = vc.date
        //[self checkLastUsedDate:vc.date]
    
        self.dismissPopover()
    }

    // 入力した日付が現在時刻から離れている場合のみ、日付を記憶
    // No longer used
    /*
    - (void)checkLastUsedDate:(NSDate *)date
    {
        NSTimeInterval diff = [[NSDate new] timeIntervalSinceDate:date]
        if (diff < 0.0) diff = -diff;
        if (diff > 24*60*60) {
            [Transaction setLastUsedDate:date]
        } else {
            [Transaction setLastUsedDate:nil]
        }
    }
    */

    func editTypeViewChanged(vc: EditTypeViewController!) {
        self.isModified = true

        // autoPop == NO なので、自分で pop する
        self.navigationController?.popToViewController(self, animated: true)

        if !self.editingEntry.changeType(TransactionType(rawValue: vc!.type)!, assetKey: self.asset.pid, dstAssetKey: vc.dstAsset) {
            return
        }

        let transaction = self.editingEntry.transaction()!
        
        let etype = transaction.etype
        if etype == .Adj {
            transaction.desc = self.typeArray[transaction.type]
        }
        else if etype == .Transfer {
            let ledger = DataModel.getLedger()
            let from = ledger.assetWithKey(transaction.asset)
            let to = ledger.assetWithKey(transaction.dstAsset)

            transaction.desc = "\(from!.name)/\(to!.name)"
        }

        self.dismissPopover()
    }

    func calculatorViewChanged(vc: CalculatorViewController!) {
        self.isModified = true

        self.editingEntry.evalue = vc.value
        self.dismissPopover()
    }

    func editDescViewChanged(vc: EditDescViewController) {
        self.isModified = true

        let transaction = self.editingEntry.transaction()!
        transaction.desc = vc.desc

        if transaction.category < 0 {
            // set category from description
            transaction.category = DataModel.instance().categoryWithDescription(transaction.desc)
        }
        self.dismissPopover()
    }

    func editMemoViewChanged(vc: EditMemoViewController!, identifier id: Int) {
        self.isModified = true

        self.editingEntry.transaction()!.memo = vc!.text
        self.dismissPopover()
    }

    func categoryListViewChanged(vc: CategoryListViewController!) {
        self.isModified = true
        
        let transaction = self.editingEntry.transaction()!
        
        if vc!.selectedIndex < 0 {
            transaction.category = -1
        } else {
            let category = DataModel.getCategories().categoryAtIndex(vc.selectedIndex)
            transaction.category = category.pid
        }
        self.dismissPopover()
    }

    @IBAction func rememberLastUsedDateChanged(view: AnyObject?) {
        if self.rememberDateSwitch.on {
            Transaction.setLastUsedDate(self.editingEntry.transaction()!.date)
        } else {
            Transaction.setLastUsedDate(nil)
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    // 削除処理

    // MARK: - Deletion

    @IBAction func delButtonTapped(sender: AnyObject?) {
        self.asset.deleteEntryAt(self.transactionIndex)
        self.editingEntry = nil

        self.navigationController!.popViewControllerAnimated(true)
    }

    ////////////////////////////////////////////////////////////////////////////////
    // ツールバー
    
    // MARK: - Toolbar

    @IBAction func doAction(sender: AnyObject?) {
        let actionSheet = UIActionSheet()
        //actionSheet.title = ""
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle(_L("Cancel"))
        actionSheet.addButtonWithTitle(_L("Delete with all past transactions"))
        actionSheet.cancelButtonIndex = 0
        actionSheet.destructiveButtonIndex = 1
        
        if isIpad() {
            actionSheet.showFromBarButtonItem(self.barActionButon, animated: true)
        } else {
            actionSheet.showInView(self.view)
        }
        self.asAction = actionSheet
    }

    func asAction(buttonIndex: Int) {
        switch buttonIndex {
        case 1:
            if !self.isNewTransaction() {
                self.delPastButtonTapped(nil)
            }
            break
        
        default:
            break
        }
    }

    private func delPastButtonTapped(sender: AnyObject?) {
        let v = UIAlertView()
        v.title = _L("Delete with all past transactions")
        v.message = _L("You can not cancel this operation.")
        v.delegate = self
        v.addButtonWithTitle(_L("Cancel"))
        v.addButtonWithTitle(_L("OK"))
        v.cancelButtonIndex = 0
        v.show()
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex != 1) {
            return // cancelled
        }

        let e = self.asset!.entryAt(self.transactionIndex)
	
        let date = e.transaction()!.date
        self.asset.deleteOldEntriesBefore(date)
	
        self.editingEntry = nil
        
        self.navigationController!.popViewControllerAnimated(true)
    }

    ////////////////////////////////////////////////////////////////////////////////
    // 保存処理

    // MARK: - Save action

    func saveAction() {
        //editingEntry.transaction.asset = asset.pkey;

        // upsert 処理
        if self.transactionIndex < 0 {
            // 新規追加
            self.asset.insertEntry(self.editingEntry)
        
            if self.rememberDateSwitch.on {
                Transaction.setLastUsedDate(self.editingEntry.transaction()!.date)
            }
        } else {
            self.asset.replaceEntryAtIndex(self.transactionIndex, withObject: self.editingEntry)
            //[asset sortByDate]
        }
        self.editingEntry = nil

        self.navigationController!.popViewControllerAnimated(true)
    }

    func cancelAction() {
        if self.isModified {
            let actionSheet = UIActionSheet()
            actionSheet.title = _L("Save this transaction?")
            actionSheet.delegate = self
            actionSheet.addButtonWithTitle(_L("Cancel"))
            actionSheet.addButtonWithTitle(_L("Yes"))
            actionSheet.addButtonWithTitle(_L("No"))
            actionSheet.cancelButtonIndex = 0
            actionSheet.actionSheetStyle = .Default
            self.asCancelTransaction = actionSheet

            actionSheet.showInView(self.view)
        } else {
            self.navigationController!.popViewControllerAnimated(true)
        }
    }

    func asCancelTransaction(buttonIndex: Int) {
        switch (buttonIndex) {
        case 0:
            // cancel
            break
        
        case 1:
            // save
            self.saveAction()
            break
            
        case 2:
            // do not save
            self.navigationController!.popViewControllerAnimated(true)
            break

        default:
            break
        }
    }

    // MARK: - ActionSheetDelegate

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.asCancelTransaction {
            self.asCancelTransaction(buttonIndex)
        }
        else if actionSheet == self.asAction {
            self.asAction(buttonIndex)
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
