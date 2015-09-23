/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
//  TransactionCell

import UIKit

class TransactionCell : UITableViewCell {
    @IBOutlet var _descLabel: UILabel?
    @IBOutlet var _dateLabel: UILabel?
    @IBOutlet var _valueLabel: UILabel?
    @IBOutlet var _balanceLabel: UILabel?

    private static let cellIdentifier = "TransactionCell"
    
    /**
    TableView に Cell を登録する
    - parameter tableView: Table View
    */
    class func registerCell(tableView: UITableView) {
        let nib = UINib(nibName: "TransactionCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
    }

    /**
    TransactionCell を生成する
    - parameter tableView: TableView
    - parameter indexPath: IndexPath
    - returns: Cell
    */
    class func transactionCell(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> TransactionCell {
        return tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TransactionCell
    }
    
    /**
    AssetEntryで内容を更新する
    - parameter entry: 更新に使用するAssetEntry
    - returns: self
    */
    func updateWithAssetEntry(entry: AssetEntry) -> TransactionCell {
        self.setDescriptionLabel(entry.transaction()!.desc)
        self.setDateLabel(entry.transaction()!.date)
        self.setValueLabel(entry.value)
        self.setBalanceLabel(entry.balance)
        return self
    }

    /**
    初期残高を設定する。初期残高セルとして扱われる。
    - parameter initialBalance: 初期残高
    - returns: self
    */
    func updateAsInitialBalance(initialBalance: Double) -> TransactionCell {
        self.setDescriptionLabel(_L("Initial Balance"))
        self.setBalanceLabel(initialBalance)
        _valueLabel!.text = ""
        _dateLabel!.text = ""
        return self
    }
     
    func setDescriptionLabel(desc: String) {
        _descLabel!.text = desc;
    }

    func setDateLabel(date: NSDate) {
        _dateLabel!.text = DataModel.dateFormatter().stringFromDate(date)
    }

    func setValueLabel(value: Double) {
        var vvalue = value
        if (value >= 0) {
            _valueLabel!.textColor = UIColor.blueColor()
        } else {
            vvalue = -value;
            _valueLabel!.textColor = UIColor.redColor()
        }
        _valueLabel!.text = CurrencyManager.formatCurrency(vvalue)
    }

    func setBalanceLabel(balance: Double) {
        let s1 = _L("Bal.")
        let s2 = CurrencyManager.formatCurrency(balance)
        _balanceLabel!.text = "\(s1) \(s2)"
    }

    func clearValueLabel() {
        _valueLabel!.text = ""
}
    
    func clearDateLabel() {
        _dateLabel!.text = ""
    }

    func clearBalanceLabel() {
        _balanceLabel!.text = ""
    }
}
