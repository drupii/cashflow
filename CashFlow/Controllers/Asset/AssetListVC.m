// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import "AppDelegate.h"
#import "AssetListVC.h"
#import "Asset.h"
#import "TransactionListVC.h"
//#import "CategoryListVC.h"
#import "ReportVC.h"
#import "BackupVC.h"
#import "PinController.h"
#import "ConfigViewController.h"

@implementation AssetListViewController
{
    IBOutlet UITableView *_tableView;
    IBOutlet UIBarButtonItem *_barActionButton;
    IBOutlet UIBarButtonItem *_barSumLabel;
    IBOutlet UIToolbar *_toolbar;
    
    BOOL _isLoadDone;
    DBLoadingView *_loadingView;
    
    Ledger *_ledger;

    NSMutableArray<UIImage *> *_iconArray;

    NSInteger _selectedAssetIndex;
    
    BOOL _asDisplaying;
    UIActionSheet *_asActionButton;
    UIActionSheet *_asDelete;

    Asset *_assetToBeDelete;
    
    BOOL _pinChecked;
}

- (void)viewDidLoad
{
    NSLog(@"AssetListViewController:viewDidLoad");
    [super viewDidLoad];
    
    //[AppDelegate trackPageview:@"/AssetListViewController"];

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        // 行高さ自動調整 (iOS8以降)
        _tableView.estimatedRowHeight = 48;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    } else {
        _tableView.rowHeight = 48;
    }
    
    _pinChecked = NO;
    _asDisplaying = NO;
    
    _ledger = nil;
	
    // title 設定
    self.title = _L(@"Assets");
	
    // "+" ボタンを追加
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addAsset)];
	
    self.navigationItem.rightBarButtonItem = plusButton;
	
    // Edit ボタンを追加
    self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
    // icon image をロード
    _iconArray = [NSMutableArray<UIImage *> new];
    NSInteger n = [Asset numAssetTypes];

    for (NSInteger i = 0; i < n; i++) {
        NSString *iconName = [Asset iconNameWithType:i];
        
        /* TODO: xsassets に対して以下の記法は使えなくなった模様。
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
        UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
        */
        UIImage *icon = [UIImage imageNamed:iconName];
        
        ASSERT(icon != nil);
        [_iconArray addObject:icon];
    }
    
    if (IS_IPAD) {
        // アクションボタンを出さない
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:_toolbar.items];
        [items removeObjectIdenticalTo:_barActionButton];
        _toolbar.items = items;
    }

    if (IS_IPAD) {
        CGSize s = self.preferredContentSize;
        s.height = 600;
        self.preferredContentSize = s;
    }
    
    if (IS_IPAD) {
        // action button を消す
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:_toolbar.items];
        [items removeObjectAtIndex:items.count - 1];
        _toolbar.items = items;
    }
    
    // データロード開始
    DataModel *dm = [DataModel instance];
    _isLoadDone = dm.isLoadDone;
    if (!_isLoadDone) {
        [dm startLoad:self];
    
        // Loading View を表示させる
        _loadingView = [[DBLoadingView alloc] initWithTitle:@"Loading"];
        [_loadingView setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        _loadingView.userInteractionEnabled = YES; // 下の View の操作不可にする
        [_loadingView show:self.view.window];
    }
}

- (void)didReceiveMemoryWarning {
    NSLog(@"AssetListViewController:didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

#pragma mark DataModelDelegate
- (void)dataModelLoaded
{
    NSLog(@"AssetListViewController:dataModelLoaded");

    _isLoadDone = YES;
    _ledger = [DataModel getLedger];
    
    [self performSelectorOnMainThread:@selector(_dataModelLoadedOnMainThread:) withObject:nil waitUntilDone:NO];
}

- (void)_dataModelLoadedOnMainThread:(id)dummy
{
    // dismiss loading view
    [_loadingView dismissAnimated:NO];
    _loadingView = nil;

    [self reload];
 
   /*
      '12/3/15
      安定性向上のため、iPad 以外では最後に使った資産に遷移しないようにした。
      起動時に TransactionListVC で固まるケースが多いため。
    
      '12/8/12 一旦元に戻す。
    */
    //if (IS_IPAD) {
        [self _showInitialAsset];
    //}
}

- (NSInteger)_firstShowAssetIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"firstShowAssetIndex"];
}

- (void)_setFirstShowAssetIndex:(NSInteger)assetIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:assetIndex forKey:@"firstShowAssetIndex"];
    [defaults synchronize];
}

/**
 * 最後に使用した資産を表示
 */
- (void)_showInitialAsset
{
    Asset *asset = nil;
    
    // 前回選択資産を選択
    NSInteger firstShowAssetIndex = [self _firstShowAssetIndex];
    if (firstShowAssetIndex >= 0 && [_ledger assetCount] > firstShowAssetIndex) {
        asset = [_ledger assetAtIndex:firstShowAssetIndex];
    }
    // iPad では、前回選択資産がなくても、最初の資産を選択する
    if (IS_IPAD && asset == nil && [_ledger assetCount] > 0) {
        asset = [_ledger assetAtIndex:0];
    }

    // TransactionListView を表示
    if (asset != nil) {
        if (IS_IPAD) {
            self.splitTransactionListViewController.assetKey = asset.pid;
            [self.splitTransactionListViewController reload];
        } else { 
            TransactionListViewController *vc = 
                [TransactionListViewController instantiate];
            vc.assetKey = asset.pid;
            [self.navigationController pushViewController:vc animated:NO];
        }
    }

    // 資産が一個もない場合は警告を出す
    if ([_ledger assetCount] == 0) {
        [AssetListViewController noAssetAlert];
    }
}

+ (void)noAssetAlert
{
    UIAlertView *v = [[UIAlertView alloc]
                      initWithTitle:@"No assets"
                      message:_L(@"At first, please create and select an asset.")
                      delegate:nil
                      cancelButtonTitle:_L(@"Dismiss")
                      otherButtonTitles:nil];
    [v show];
}

- (void)reload
{
    if (!_isLoadDone) return;
    
    _ledger = [DataModel getLedger];
    [_ledger rebuild];
    [_tableView reloadData];

    // 合計欄
    double value = 0.0;
    for (NSInteger i = 0; i < [_ledger assetCount]; i++) {
        value += [[_ledger assetAtIndex:i] lastBalance];
    }
    NSString *lbl = [NSString stringWithFormat:@"%@ %@", _L(@"Total"), [CurrencyManager formatCurrency:value]];
    _barSumLabel.title = lbl;
    
    [[Database instance] updateModificationDate]; // TODO : ここでやるのは正しくないが、、、
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"AssetListViewController:viewWillAppear");
    
    [super viewWillAppear:animated];
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"AssetListViewController:viewDidAppear");

    static BOOL isInitial = YES;

    [super viewDidAppear:animated];

    if (isInitial) {
         isInitial = NO;
     } 
    else if (!IS_IPAD) {
        // 初回以外：初期起動する画面を資産一覧画面に戻しておく
        [self _setFirstShowAssetIndex:-1];
    }
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 1;
    
    //if (tv.editing) return 1 else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_isLoadDone) return 0;
    
    return [_ledger assetCount];
}

- (NSInteger)_assetIndex:(NSIndexPath*)indexPath
{
    return indexPath.row;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tv.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    NSString *cellid = @"assetCell";
    cell = [tv dequeueReusableCellWithIdentifier:cellid];
    // prototype cell を使用するため、cell は常に自動生成される

    // 資産
    Asset *asset = [_ledger assetAtIndex:[self _assetIndex:indexPath]];

    // 資産タイプ範囲外対応
    NSInteger type = asset.type;
    if (type < 0 || _iconArray.count <= type) {
        type = 0;
    }
    cell.imageView.image = _iconArray[type];

    // 資産名
    cell.textLabel.text = asset.name;

    // 残高
    double value = [asset lastBalance];
    NSString *c = [CurrencyManager formatCurrency:value];
    cell.detailTextLabel.text = c;
    
    if (value >= 0) {
        cell.detailTextLabel.textColor = [UIColor blueColor];
    } else {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
	
    return cell;
}

#pragma mark UITableViewDelegate

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];

    NSInteger assetIndex = [self _assetIndex:indexPath];
    if (assetIndex < 0) return;

    // 最後に選択した asset を記憶
    [self _setFirstShowAssetIndex:assetIndex];
	
    Asset *asset = [_ledger assetAtIndex:assetIndex];

    // TransactionListView を表示
    if (IS_IPAD) {
        self.splitTransactionListViewController.assetKey = asset.pid;
        [self.splitTransactionListViewController reload];
    } else {
        TransactionListViewController *vc = 
            [TransactionListViewController instantiate];
        vc.assetKey = asset.pid;

        [self.navigationController pushViewController:vc animated:YES];
    }
}

// アクセサリボタンをタップしたときの処理 : アセット変更
- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger assetIndex = [self _assetIndex:indexPath];
    if (assetIndex >= 0) {
        _selectedAssetIndex = indexPath.row;
        [self performSegueWithIdentifier:@"show" sender:self];
    }
}

// 新規アセット追加
- (void)addAsset
{
    _selectedAssetIndex = -1;
    [self performSegueWithIdentifier:@"show" sender:self];
}

// 画面遷移
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show"]) {
        AssetViewController *vc = segue.destinationViewController;
        [vc setAssetIndex:_selectedAssetIndex];
    }
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [self.tableView setEditing:editing animated:editing];

    self.navigationItem.rightBarButtonItem.enabled = !editing;
}

- (BOOL)tableView:(UITableView*)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0)
        return NO;
    return YES;
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (style == UITableViewCellEditingStyleDelete) {
        NSInteger assetIndex = [self _assetIndex:indexPath];
        _assetToBeDelete = [_ledger assetAtIndex:assetIndex];

        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            // iOS8 : UIAlertController を使う
            UIAlertController *alert = nil;
            alert = [UIAlertController
                     alertControllerWithTitle:@"Warning"
                     message:_L(@"ReallyDeleteAsset")
                     preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
            UIAlertAction *ok =
                [UIAlertAction actionWithTitle:_L(@"Delete Asset")
                                         style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action) {
                                           [self _actionDelete:0];
                                       }];
            [alert addAction:cancel];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // iOS7 : UIActionSheet (deprecated) を使う
            _asDelete =
                [[UIActionSheet alloc]
                 initWithTitle:_L(@"ReallyDeleteAsset")
                 delegate:self
                 cancelButtonTitle:@"Cancel"
                 destructiveButtonTitle:_L(@"Delete Asset")
                 otherButtonTitles:nil];
            _asDelete.actionSheetStyle = UIActionSheetStyleDefault;
        
            // 注意: self.view から showInView すると、iPad縦画面でクラッシュする。self.view.window にすれば OK。
            [_asDelete showInView:self.view.window];
        }
    }
}

- (void)_actionDelete:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return; // cancelled;
    }
	
    NSInteger pid = _assetToBeDelete.pid;
    [_ledger deleteAsset:_assetToBeDelete];
    
    if (IS_IPAD) {
        if (self.splitTransactionListViewController.assetKey == pid) {
            self.splitTransactionListViewController.assetKey = -1;
            [self.splitTransactionListViewController reload];
        }
    }

    [self.tableView reloadData];
}

// 並べ替え処理
- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tv
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)fromIndexPath 
       toProposedIndexPath:(NSIndexPath *)proposedIndexPath
{
    // 合計額(section:1)には移動させない
    NSIndexPath *idx = [NSIndexPath indexPathForRow:proposedIndexPath.row inSection:0];
    return idx;
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath*)from toIndexPath:(NSIndexPath*)to
{
    NSInteger fromIndex = [self _assetIndex:from];
    NSInteger toIndex = [self _assetIndex:to];
    if (fromIndex < 0 || toIndex < 0) return;

    [[DataModel getLedger] reorderAsset:fromIndex to:toIndex];
}

//////////////////////////////////////////////////////////////////////////////////////////
// Report

#pragma mark Show Report

- (void)showReport:(id)sender
{
    ReportViewController *reportVC = [ReportViewController instantiate];
    [reportVC setAsset:nil];
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:reportVC];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [self.navigationController presentViewController:nv animated:YES completion:NULL];
}


//////////////////////////////////////////////////////////////////////////////////////////
// Action Sheet 処理

#pragma mark Action Sheet

- (void)doAction:(id)sender
{
    if (_asDisplaying) return;
    _asDisplaying = YES;
    
    _asActionButton = 
        [[UIActionSheet alloc]
         initWithTitle:@"" delegate:self 
         cancelButtonTitle:_L(@"Cancel")
         destructiveButtonTitle:nil
         otherButtonTitles:
         [NSString stringWithFormat:@"%@ (%@)", _L(@"Export"), _L(@"All assets")],
         [NSString stringWithFormat:@"%@ / %@", _L(@"Sync"), _L(@"Backup")],
         _L(@"Config"),
         _L(@"Info"),
         nil];

    //if (IS_IPAD) {
    //    [mAsActionButton showFromBarButtonItem:mBarActionButton animated:YES];
    //}
    
    [_asActionButton showInView:self.view];
}

- (void)_actionActionButton:(NSInteger)buttonIndex
{
    BackupViewController *backupVC;
    UIViewController *vc;
    
    _asDisplaying = NO;

    UINavigationController *nv = nil;
    
    switch (buttonIndex) {
        case 0:
            nv = [ExportVC instantiate:nil];
            break;
            
        case 1:
            nv = [[UIStoryboard storyboardWithName:@"BackupView" bundle:nil] instantiateInitialViewController];
            backupVC = (BackupViewController *)nv.topViewController;
            backupVC.delegate = self;
            break;
            
        case 2:
            nv = [[UIStoryboard storyboardWithName:@"ConfigView" bundle:nil] instantiateInitialViewController];
            break;
            
        case 3:
            nv = [InfoViewController instantiate];
            break;
            
        default:
            return;
    }
    
    if (nv == nil) {
        nv = [[UINavigationController alloc] initWithRootViewController:vc];
    }
    //if (IS_IPAD) {
    //    nv.modalPresentationStyle = UIModalPresentationFormSheet; //UIModalPresentationPageSheet;
    //}
    [self.navigationController presentViewController:nv animated:YES completion:NULL];
}

// actionSheet ハンドラ
- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as == _asActionButton) {
        _asActionButton = nil;
        [self _actionActionButton:buttonIndex];
    }
    else if (as == _asDelete) {
        _asDelete = nil;
        [self _actionDelete:buttonIndex];
    }
    else {
        ASSERT(NO);
    }
}

#pragma mark BackupViewDelegate

- (void)backupViewFinished:(BackupViewController *)backupViewController
{
    [self reload];
    if (IS_IPAD) {
        self.splitTransactionListViewController.assetKey = -1;
        [self.splitTransactionListViewController reload];
    }
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
