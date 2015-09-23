// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import "AppDelegate.h"
#import "DataModel.h"
#import "ReportCatDetailVC.h"

@implementation CatReportDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TransactionCell registerCell:self.tableView];
    
    //[AppDelegate trackPageview:@"/ReportCatDetailViewController"];
    
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_catReport.transactions).count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCell *cell = [TransactionCell transactionCell:tv forIndexPath:indexPath];
    
    Transaction *t = (_catReport.transactions)[(_catReport.transactions).count - 1 - indexPath.row];
    double value;
    if (_catReport.assetKey < 0) {
        // 全資産指定の場合
        value = t.value;
    } else {
        // 資産指定の場合
        if (t.asset == _catReport.assetKey) {
            value = t.value;
        } else {
            value = -t.value;
        }
    }
    [cell setDescriptionLabel:t.desc];
    [cell setDateLabel:t.date];
    [cell setValueLabel:value];
    [cell clearBalanceLabel];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
