// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

/**
   取引種類指定 View

   Note: 本Viewは、自動で popViewController しない
   理由は、別の View を上に乗せており、利用する側のクラスで
   popToViewController するため。
*/
#import "CashFlow-Swift.h"

#import "AppDelegate.h"
#import "EditTypeVC.h"
#import "Transaction.h"

@implementation EditTypeViewController

- (instancetype)init
{
    self = [super initWithNibName:@"EditTypeView" bundle:nil];
    if (self) {
        self.title = _L(@"Type");
        _dstAsset = -1;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPAD) {
        CGSize s = self.preferredContentSize;
        s.height = 300;
        self.preferredContentSize = s;
    }
}
    
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#if FREE_VERSION
//    return 3;   // Free版は資産間移動なし
//#else
    return 4;
//#endif
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"editTypeViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    if (indexPath.row == _type) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
		
    NSString *t;
    switch (indexPath.row) {
    case 0:
    default:
        t = @"Payment";
        break;
    case 1:
        t = @"Deposit";
        break;
    case 2:
        t = @"Adjustment";
        break;
    case 3:
        t = @"Transfer";
        break;
    }
    cell.textLabel.text = _L(t);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.type = indexPath.row;

    if (self.type != TransactionTypeTransfer) {
        // pop しない
        [_delegate editTypeViewChanged:self];
        return;
    }

    // 資産間移動
    Ledger *ledger = [DataModel ledger];
    NSInteger assetCount = [ledger assetCount];
    NSMutableArray *assetNames = [[NSMutableArray alloc] initWithCapacity:assetCount];
    for (int i = 0; i < assetCount; i++) {
        Asset *asset = [ledger assetAtIndex:i];
        [assetNames addObject:asset.name];
    }
    
    GenSelectListViewController *vc;
    vc = [GenSelectListViewController genSelectListViewController:self
                                    items:assetNames
                                      title:_L(@"Asset")
                                    identifier:0];
    vc.selectedIndex = [ledger assetIndexWithKey:_dstAsset];

    [self.navigationController pushViewController:vc animated:YES];
}

// 資産選択
- (BOOL)genSelectListViewChanged:(GenSelectListViewController*)vc identifier:(NSInteger)id
{
    Asset *as = [[DataModel ledger] assetAtIndex:vc.selectedIndex];
    _dstAsset = as.pid;

    [_delegate editTypeViewChanged:self];

    return NO; // pop しない
}

#pragma mark Rotation

- (BOOL)shouldAutorotate
{
    return IS_IPAD;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IS_IPAD) return UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationMaskPortrait;
}

@end
