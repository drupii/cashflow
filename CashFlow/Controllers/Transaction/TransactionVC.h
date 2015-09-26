// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

#import "Transaction.h"

#import "EditTypeVC.h"
#import "CalcVC.h"
#import "EditDateVC.h"
#import "EditMemoVC.h"
#import "CategoryListVC.h"
#import "CFCalendarViewController.h"

@class AssetEntry;

@interface TransactionViewController : UIViewController 

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,unsafe_unretained) Asset *asset;
@property(nonatomic,strong) AssetEntry *editingEntry;

- (void)setTransactionIndex:(NSInteger)n;
- (void)saveAction;
- (void)cancelAction;

@end
