/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

import iAd
//import "GADBannerView.h"

#if FREE_VERSION
//import GoogleMobileAds
#endif

class TransactionListViewController : UIViewController,
    UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, CalculatorViewDelegate, UISplitViewControllerDelegate,
    BackupViewDelegate, UIPopoverControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate,
#if FREE_VERSION
    AdManagerDelegate
#endif
{
    @IBOutlet tableView: UITableView!
    @IBOutlet weak barBalanceLabel: UIBarButtonItem!
    @IBOutlet weak barActionButton: UIBarButtonItem!
    @IBOutlet weak toolbar: UIToolbar!
    
    var splitAssetListViewController: AssetListViewController!
    var assetKey: Int = 0

    var asset: Asset?

    var searchResults: NSMutableArray?
    private var tappedIndex: Int

    // For Free version
#if FREE_VERSION
    private var adManager: AdManager?
    private var isAdShowing: Bool = false
#endif

    private var actionSheet: UIActionSheet?

    // Note: _popoverController は UIViewController で定義されているため使用不可
    private var mPopoverController: UIPopoverController?
    private var tableViewInsetSave: UIEdgeInsets?

+ (TransactionListViewController *)instantiate
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TransactionListView" bundle:nil];
    return [sb instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _assetKey = -1;
    }
    return self;
}

- (Asset *)asset
{
    if (_assetKey < 0) {
        return nil;
    }
    
#if 0
    // 安全のため、cache を使わないようにした
    if (mAssetCache != nil && mAssetCache.pid == mAssetKey) {
        return mAssetCache;
    }
    mAssetCache = [[[DataModel instance] ledger] assetWithKey:mAssetKey];
    return mAssetCache;
#endif
    return  [[DataModel instance].ledger assetWithKey:_assetKey];
}

- (void)viewDidLoad
{
    NSLog(@"TransactionListViewController:viewDidLoad");

    [super viewDidLoad];
    
    // TransactionCell を register する
    [TransactionCell registerCell:self.tableView];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        // iOS8 以降: 行高さ自動調整
        self.tableView.estimatedRowHeight = 48.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    } else {
        self.tableView.rowHeight = 48.0;
    }
    
    //[AppDelegate trackPageview:@"/TransactionListViewController"];
	
    // title 設定
    //self.title = _L(@"Transactions");
    if (self.asset == nil) {
        self.title = @"";
    } else {
        self.title = self.asset.name;
    }
	
    // "+" ボタンを追加
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addTransaction)];
	
    self.navigationItem.rightBarButtonItem = plusButton;
	
    // Edit ボタンを追加
    // TBD
    //self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
    // Notifiction 受け取り手続き
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(willEnterForeground) name:@"willEnterForeground" object:nil];
    [nc addObserver:self selector:@selector(willResignActive) name:@"willResignActive" object:nil];

#if FREE_VERSION
    _isAdShowing = NO;
    _adManager = [AdManager sharedInstance];
    [_adManager attach:self rootViewController:self];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
#if FREE_VERSION
    [_adManager detach];
#endif
}

- (void)reload
{
    self.title = self.asset.name;
    [self updateBalance];
    [self.tableView reloadData];
    
    // 検索中
    if (self.searchDisplayController.isActive) {
        [self updateSearchResultWithDesc:self.searchDisplayController.searchBar.text];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    
    [self _dismissPopover];
}    

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    mPopoverController = nil;
}

- (void)_dismissPopover
{
    if (IS_IPAD
        && mPopoverController != nil
        && mPopoverController.popoverVisible
        && _tableView != nil && _tableView.window != nil /* for crash problem */)
    {
        [mPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload];
    
    [[Database instance] updateModificationDate]; // TODO : ここでやるのは正しくないが、、、
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

#if FREE_VERSION
    // 表示開始
    [_adManager requestShowAd];
#endif
}

/**
 * アプリが background に入るときの処理
 */
- (void)willResignActive
{
    if (_actionSheet != nil) {
        [_actionSheet dismissWithClickedButtonIndex:0 animated:NO];
        _actionSheet = nil;
    }
    //[self _dismissPopover];  // TODO: 効かない、、、
}

/**
 * アプリが foreground になった時の処理。
 * これは AppDelegate の applicationWillEnterForeground から呼び出される。
 */
- (void)willEnterForeground
{
#if FREE_VERSION
    // 表示開始
    [_adManager requestShowAd];
#endif
}

/**
 * 広告表示
 */
#if FREE_VERSION
- (void)adManager:(AdManager *)adManager showAd:(AdView *)adView adSize:(CGSize)adSize
{
    if (_isAdShowing) {
        NSLog(@"Ad is already showing!");
        return;
    }
    NSLog(@"showAd");
    _isAdShowing = YES;

    //NSLog(@"adSize:%fx%f", adSize.width, adSize.height);
    
    CGRect frame = _tableView.frame;
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
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height; // 画面外
    aframe.size = adSize;
    
    adView.frame = aframe;
    [self.view addSubview:adView];
    [self.view bringSubviewToFront:_toolbar];
    
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
    UIEdgeInsets inset = _tableView.contentInset;
    inset.bottom += adSize.height;
    _tableView.contentInset = inset;

    // 表示位置
    aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height - adSize.height;
    aframe.size = adSize;
    
    // 広告をアニメーション表示させる
    [UIView beginAnimations:@"ShowAd" context:NULL];
    adView.frame = aframe;
    [UIView commitAnimations];
}

/**
 * 広告を隠す
 */
- (void)adManager:(AdManager *)adManager removeAd:(UIView *)adView adSize:(CGSize)adSize
{
    if (!_isAdShowing) {
        NSLog(@"Ad is already removed!");
        return;
    }
    NSLog(@"removeAd");
    _isAdShowing = NO;
    
    CGRect frame = _tableView.bounds;
        
    // tableView のサイズをもとに戻す
    /*
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.height += adSize.height;
    _tableView.frame = frame;
     */
    _tableView.contentInset = _tableViewInsetSave;
    
    // 広告の位置
    CGRect aframe = frame;
    aframe.origin.x = (frame.size.width - adSize.width) / 2;
    aframe.origin.y = frame.size.height;
    aframe.size = adSize;
    
    // 広告をアニメーション表示させる
    [UIView beginAnimations:@"HideAd" context:NULL];
    adView.frame = aframe;
    [UIView commitAnimations];
    
    [adView removeFromSuperview];
}
#endif // FREE_VERSION

- (void)updateBalance
{
    double lastBalance = [self.asset lastBalance];
    NSString *bstr = [CurrencyManager formatCurrency:lastBalance];

#if 0
    UILabel *tableTitle = (UILabel *)[self.tableView tableHeaderView];
    tableTitle.text = [NSString stringWithFormat:@"%@ %@", _L(@"Balance"), bstr];
#endif
	
    _barBalanceLabel.title = [NSString stringWithFormat:@"%@ %@", _L(@"Balance"), bstr];
    
    if (IS_IPAD) {
        [self.splitAssetListViewController reload];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self _dismissPopover];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.asset == nil) return 0;

    NSInteger n;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        n = (self.searchResults).count;
    } else {
        n = [self.asset entryCount] + 1;
    }
    return n;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.rowHeight;
}

// 指定セル位置に該当する entry Index を返す
- (NSInteger)entryIndexWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSInteger idx;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        idx = ((self.searchResults).count - 1) - indexPath.row;
    } else {
        idx = ([self.asset entryCount] - 1) - indexPath.row;
    }
    return idx;
}

// 指定セル位置の Entry を返す
- (AssetEntry *)entryWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    NSInteger idx = [self entryIndexWithIndexPath:indexPath tableView:tableView];

    if (idx < 0) {
        return nil;  // initial balance
    }
    AssetEntry *e;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        e = (self.searchResults)[idx];
    } else {
        e = [self.asset entryAt:idx];
    }
    return e;
}

//
// セルの内容を返す
//
#define TAG_DESC 1
#define TAG_DATE 2
#define TAG_VALUE 3
#define TAG_BALANCE 4

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCell *cell;
	
    AssetEntry *e;
    
    e = [self entryWithIndexPath:indexPath tableView:tv];
    if (e) {
        cell = [[TransactionCell transactionCell:tv forIndexPath:indexPath] updateWithAssetEntry:e];
    }
    else {
        cell = [[TransactionCell transactionCell:tv forIndexPath:indexPath] updateAsInitialBalance:self.asset.initialBalance];
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
	
    NSInteger idx = [self entryIndexWithIndexPath:indexPath tableView:tv];
    if (idx == -1) {
        // initial balance cell
        CalculatorViewController *v = [CalculatorViewController instantiate];
        v.delegate = self;
        v.value = self.asset.initialBalance;

        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:v];
        
        if (!IS_IPAD) {
            [self presentViewController:nv animated:YES completion:NULL];
        } else {
            [self _dismissPopover];
            mPopoverController = [[UIPopoverController alloc] initWithContentViewController:nv];
            mPopoverController.delegate = self;
            [mPopoverController presentPopoverFromRect:[tv cellForRowAtIndexPath:indexPath].frame inView:tv
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else if (idx >= 0) {
        // transaction view を表示
        if (tv == self.searchDisplayController.searchResultsTableView) {
            AssetEntry *e = (self.searchResults)[idx];
            _tappedIndex = e.originalIndex;
        } else {
            _tappedIndex = idx;
        }
        
        [self performSegueWithIdentifier:@"show" sender:self];
    }
}

// 画面遷移
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show"]) {
        TransactionViewController *vc = segue.destinationViewController;
        vc.asset = self.asset;
        [vc setTransactionIndex:_tappedIndex];
    }
}

// 初期残高変更処理
- (void)calculatorViewChanged:(CalculatorViewController *)vc
{
    self.asset.initialBalance = vc.value;
    [self.asset updateInitialBalance];
    [self.asset rebuild];
    [self reload];
}

// 新規トランザクション追加
- (void)addTransaction
{
    if (self.asset == nil) {
        [AssetListViewController noAssetAlert];
        return;
    }
            
    _tappedIndex = -1;
    [self performSegueWithIdentifier:@"show" sender:self];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.asset == nil) return;
    
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [_tableView setEditing:editing animated:animated];

    self.navigationItem.rightBarButtonItem.enabled = !editing;
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger entryIndex = [self entryIndexWithIndexPath:indexPath tableView:tv];
    if (entryIndex < 0) {
        return UITableViewCellEditingStyleNone;
    } 
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger entryIndex = [self entryIndexWithIndexPath:indexPath tableView:tv];

    if (entryIndex < 0) {
        // initial balance cell : do not delete!
        return;
    }

    if (style == UITableViewCellEditingStyleDelete) {
        if (tv == self.searchDisplayController.searchResultsTableView) {
            AssetEntry *e = (self.searchResults)[entryIndex];
            [self.asset deleteEntryAt:e.originalIndex];
            
            // 検索結果一覧を更新する
            [self updateSearchResultWithDesc:self.searchDisplayController.searchBar.text];
        } else {
            [self.asset deleteEntryAt:entryIndex];
        }

        // 残高再計算
        [self updateBalance];
        
        [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tv reloadData];
    }

    if (IS_IPAD) {
        [self.splitAssetListViewController reload];
    }
}

#pragma mark Show Report
- (void)showReport:(id)sender
{
    ReportViewController *reportVC = [ReportViewController instantiate];
    [reportVC setAsset:self.asset];

    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:reportVC];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self.navigationController presentViewController:nv animated:YES completion:NULL];
}

#pragma mark Action sheet handling

// action sheet
- (void)doAction:(id)sender
{
    if (_actionSheet != nil) return;
    
    _actionSheet =
        [[UIActionSheet alloc]
         initWithTitle:nil
         delegate:self 
         cancelButtonTitle:_L(@"Cancel")
         destructiveButtonTitle:nil otherButtonTitles:
         [NSString stringWithFormat:@"%@ (%@)", _L(@"Export"), _L(@"All assets")],
         [NSString stringWithFormat:@"%@ (%@)", _L(@"Export"), _L(@"This asset")],
         [NSString stringWithFormat:@"%@ / %@", _L(@"Sync"), _L(@"Backup")],
         _L(@"Config"),
         _L(@"Info"),
         nil];
    if (IS_IPAD) {
        [_actionSheet showFromBarButtonItem:_barActionButton animated:YES];
    } else {
        [_actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BackupViewController *backupVC;
    
    UIViewController *vc;
    UIModalPresentationStyle modalPresentationStyle = UIModalPresentationFormSheet;
    
    _actionSheet = nil;
    
    UINavigationController *nv = nil;
    switch (buttonIndex) {
        case 0:
            nv = [ExportVC instantiate:nil];
            break;
        
        case 1:
            nv = [ExportVC instantiate:self.asset];
            break;
            
        case 2:
            nv = [[UIStoryboard storyboardWithName:@"BackupView" bundle:nil] instantiateInitialViewController];
            backupVC = (BackupViewController *)nv.topViewController;
            backupVC.delegate = self;
            break;
            
        case 3:
            nv = [[UIStoryboard storyboardWithName:@"ConfigView" bundle:nil] instantiateInitialViewController];
            break;
            
        case 4:
            nv = [InfoViewController instantiate];
            break;
            
        default:
            return;
    }

    if (nv == nil) {
        nv = [[UINavigationController alloc] initWithRootViewController:vc];
    }
    if (IS_IPAD) {
        nv.modalPresentationStyle = modalPresentationStyle;
    }

    // iPad: actionsheet から presentViewController を直接呼び出せなくなった
    // http://stackoverflow.com/questions/24854802/presenting-a-view-controller-modally-from-an-action-sheets-delegate-in-ios8
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController presentViewController:nv animated:YES completion:NULL];
    });
}

#pragma mark BackupViewDelegate

- (void)backupViewFinished:(BackupViewController *)backupViewController
{
    // リストアされた場合、mAssetCacheは無効になっている
    //mAssetCache = nil;
    
    if (IS_IPAD) {
        [self reload];
        [self.splitAssetListViewController reload];
    }
}

#pragma mark Split View Delegate

// Landscape -> Portrait への移行
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
    barButtonItem.title = _L(@"Assets");
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    // 初期残高の popover が表示されている場合、ここで消さないと２つの Popover controller
    // が競合してしまう。
    [self _dismissPopover];

    mPopoverController = pc;
}


// Portrait -> Landscape への移行
// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
    [self _dismissPopover];
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

#pragma mark - UISearchDisplayController Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    // 検索用の tableView に、TransactionCell を register する。
    [TransactionCell registerCell:controller.searchResultsTableView];
}

// 検索文字列が入力された
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearchResultWithDesc:searchString];
    return YES;
}

#pragma mark - 検索処理

- (void)updateSearchResultWithDesc:(NSString *)searchString
{
    BOOL allMatch = FALSE;
    if (searchString == nil || searchString.length == 0) {
        allMatch = TRUE;
    }

    NSInteger count = [self.asset entryCount];
    if (self.searchResults == nil) {
        self.searchResults = [[NSMutableArray alloc] initWithCapacity:count];
    } else {
        [self.searchResults removeAllObjects];
    }

    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;

    for (int i = 0; i < count; i++) {
        AssetEntry *e = [self.asset entryAt:i];
        if (e == nil) continue; // nil になることはないはずだが念のため
        e.originalIndex = i;
        
        if (allMatch ) {
            [self.searchResults addObject:e];
            continue;
        }
        
        // 文字列マッチ
        NSString *desc = e.transaction.desc;
        NSRange range = NSMakeRange(0, desc.length);
        NSRange foundRange = [desc rangeOfString:searchString options:searchOptions range:range];
        if (foundRange.length > 0) {
            [self.searchResults addObject:e];
        }
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.searchResults = nil;
    
    // 検索中にデータが変更されるケースがあるので、ここで reload する
    [_tableView reloadData];
}

@end
