/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

@objc protocol EditDescViewDelegate {
    func editDescViewChanged(vc: EditDescViewController)
}

class EditDescViewController: UITableViewController, UITextFieldDelegate, UISearchDisplayDelegate {
    weak var delegate: EditDescViewDelegate?
    var desc: String = ""
    var category: Int = -1

    private var textField: UITextField!

    private var descArray: [DescLRU] = []
    private var filteredDescArray: [DescLRU] = []

    static func instantiate() -> EditDescViewController {
        return UIStoryboard(name: "EditDescView", bundle: nil).instantiateInitialViewController() as! EditDescViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.category = -1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isIpad() {
            var sz = self.preferredContentSize
            sz.height = 600;  // AdHoc : 480 にすると横画面の時に下に出てしまい、文字入力ができない
            self.preferredContentSize = sz
        }
    
        self.title = _L("Name")

        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("doneAction"))

        // ここで textField を生成する
        let tf = UITextField(frame: CGRectMake(12, 12, 300, 24))
        tf.placeholder = _L("Description")
        tf.returnKeyType = .Done
        tf.delegate = self;
        self.textField = tf
    
        /*
        [mTextField addTarget:self action:@selector(onTextChange:)
                forControlEvents:UIControlEventEditingDidEndOnExit];
        */
    }

    /**
     * 表示前の処理
     * 処理するトランザクションをロードしておく
     */
    override func viewWillAppear(animated: Bool) {
        self.textField.text = self.desc
        super.viewWillAppear(animated)

        self.descArray = DescLRUManager.getDescLRUs(self.category) // mutableCopy
        self.filteredDescArray = self.descArray // copy

        // キーボードを消す ###
        self.textField.resignFirstResponder()

        self.tableView.reloadData()
    }

    //- (void)viewWillDisappear:(BOOL)animated
    //{
    //    [super viewWillDisappear:animated];
    //}

    func doneAction() {
        self.desc = self.textField.text!
        self.delegate?.editDescViewChanged(self)

        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // キーボードを消すための処理
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - TableViewDataSource

    private func isSearching() -> Bool {
        return self.searchDisplayController!.active
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSearching() {
            return 1;
        } else {
            return 2;
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearching() && section == 0 {
            return 1; // テキスト入力欄
        }

        return self.filteredDescArray.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching() {
            return nil
        }
        switch (section) {
        case 0:
            return _L("Name")
        case 1:
            return _L("History")
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !isSearching() && indexPath.section == 0 {
            return textFieldCell(tableView)
        }
        else {
            return descCell(tableView, row:indexPath.row)
        }
    }

    private func textFieldCell(tableView: UITableView) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "textFieldCell")
            cell!.contentView.addSubview(self.textField)
        }
        return cell!
    }

    private func descCell(tableView: UITableView, row:Int) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("descCell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "descCell")
        }
        
        let lru = self.filteredDescArray[row]
        cell!.textLabel!.text = lru.desc;
        return cell!
    }

    // MARK: - UITableViewDelegate

    //
    // セルをクリックしたときの処理
    //
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        if isSearching() || indexPath.section == 1 {
            let lru = self.filteredDescArray[indexPath.row]
            self.textField.text = lru.desc
            self.doneAction()
        }
    }

    // 編集スタイルを返す
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if !isSearching() && indexPath.section == 0 {
            return .None
        }
        // 適用は削除可能
        return .Delete
    }

    // 削除処理
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle != .Delete {
            return
        }
        if !isSearching() && indexPath.section != 1 {
            return // テキスト入力欄
        }

        let lru = self.filteredDescArray[indexPath.row]
        self.filteredDescArray.removeAtIndex(indexPath.row)
        
        // フィルタ前リストから抜く
        for (idx, aLru) in self.descArray.enumerate() {
            if lru == aLru {
                self.descArray.removeAtIndex(idx)
                break
            }
        }
        lru.delete() // delete from DB

        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    // MARK: - UISearchDisplayController Delegate

    // iOS7 バグ回避
    // see http://stackoverflow.com/questions/18924710/uisearchdisplaycontroller-overlapping-original-table-view
    func searchDisplayController(controller: UISearchDisplayController, willShowSearchResultsTableView tableView: UITableView) {
        tableView.backgroundColor = UIColor.whiteColor()
    }

    // 検索開始 : サーチバーの文字列が変更されたときに呼び出される
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.updateFilteredDescArray(searchString)
        return true
    }

    // 検索終了
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
        self.filteredDescArray = self.descArray // copy
        self.tableView.reloadData()
    }


    // MARK: -

    // サーチテキスト変更時の処理：フィルタリングをし直す
    private func updateFilteredDescArray(searchString: String?) {
        if (searchString == nil || searchString!.isEmpty) {
            self.filteredDescArray = self.descArray
            return
        }
    
        self.filteredDescArray.removeAll()
    
        let searchOptions: NSStringCompareOptions = [NSStringCompareOptions.CaseInsensitiveSearch, NSStringCompareOptions.DiacriticInsensitiveSearch]

        for lru in self.descArray {
            let foundRange = lru.desc.rangeOfString(searchString!, options: searchOptions)
            if foundRange != nil {
                self.filteredDescArray.append(lru)
            }
        }
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
}
