// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "CategoryListVC.h"
#import "Category.h"
#import "GenEditTextVC.h"

@implementation CategoryListViewController
{
    BOOL _isAddCategoryRowDisplayed;
}

- (instancetype)init
{
    self = [super initWithNibName:@"CategoryListView" bundle:nil];
    if (self) {
        _isAddCategoryRowDisplayed = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/CategoryListViewController"];

    if (IS_IPAD) {
        CGSize s = self.preferredContentSize;
        s.height = 600;
        self.preferredContentSize = s;
    }
	
    // title 設定
    self.title = _L(@"Categories");

    // Edit ボタンを追加
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[DataModel instance].categories count];
    if (self.editing) {
        count++;	// insert cell
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = @"categoryCell";

    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellid];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }

    if (indexPath.row >= [[DataModel instance].categories count]) {
        cell.textLabel.text = _L(@"Add category");
    } else {
        TCategory *c = [[DataModel instance].categories categoryAtIndex:indexPath.row];
        cell.textLabel.text = c.name;
    }

    if (_isSelectMode && !self.editing) {
        if (indexPath.row == _selectedIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } 
	
    return cell;
}

#pragma mark Cell tap action

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSelectMode && !self.editing) {
        [tv deselectRowAtIndexPath:indexPath animated:NO];
		
        _selectedIndex = indexPath.row;
        ASSERT(delegate);
        [_delegate categoryListViewChanged:self];
		
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    NSInteger idx = indexPath.row;
    if (idx >= [[DataModel instance].categories count]) {
        idx = -1; // insert row
    }
    GenEditTextViewController *vc = [GenEditTextViewController
                                        create:self
                                        title:_L(@"Category")
                                        identifier:idx];
    if (idx >= 0) {
        TCategory *category = [[DataModel instance].categories categoryAtIndex:idx];
        vc.text = category.name;
    }
	
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)genEditTextViewChanged:(GenEditTextViewController *)vc identifier:(NSInteger)identifier
{
    if (identifier < 0) {
        // 新規追加
        [[DataModel instance].categories addCategory:vc.text];
    } else {
        // 変更
        TCategory *c = [[DataModel instance].categories categoryAtIndex:identifier];
        c.name = vc.text;
        [[DataModel instance].categories updateCategory:c];
    }
    [self.tableView reloadData];
}

#pragma mark Edit cells

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
    // "Add Category" 用の行を追加・削除する
    // Edit ボタンを押したのではなく swipe した場合もこれが呼ばれるので注意すること。
    // なお、その場合、setEditing は１回ずつではなく２回呼ばれる場合があるので、
    // 二重処理にならないようにする必要がある。
    NSInteger insButtonIndex = [[DataModel instance].categories count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insButtonIndex inSection:0];
    NSArray *iary = @[indexPath];
	
    [self.tableView beginUpdates];
    if (editing && !_isAddCategoryRowDisplayed) {
        [self.tableView insertRowsAtIndexPaths:iary withRowAnimation:UITableViewRowAnimationTop];
        _isAddCategoryRowDisplayed = YES;
    } else if (!editing && _isAddCategoryRowDisplayed) {
        [self.tableView deleteRowsAtIndexPaths:iary withRowAnimation:UITableViewRowAnimationTop];
        _isAddCategoryRowDisplayed = NO;
    }
    [self.tableView endUpdates];

    self.navigationItem.leftBarButtonItem.enabled = !editing;
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [[DataModel instance].categories count]) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

// 編集処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row >= [[DataModel instance].categories count]) {
        // add
        GenEditTextViewController *vc = [GenEditTextViewController create:self title:_L(@"Category") identifier:-1];
        [self.navigationController pushViewController:vc animated:YES];
    }
	
    else if (style == UITableViewCellEditingStyleDelete) {
        [[DataModel instance].categories deleteCategoryAtIndex:indexPath.row];
        [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

#pragma mark Sort cells

// 並べ替え可能チェック
- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [[DataModel instance].categories count]) {
        return NO; // 追加列は移動不可
    }
    return YES;
}

// 移動先チェック
- (NSIndexPath *)tableView:(UITableView *)tv targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row >= [[DataModel instance].categories count]) {
        // 移動先が「追加」列の場合は、移動不可
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

// セル移動
- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath*)from toIndexPath:(NSIndexPath*)to
{
    [[DataModel instance].categories reorderCategory:from.row to:to.row];
}

#pragma mark - Rotation

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
