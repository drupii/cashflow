// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "CashFlow-Swift.h"

#import "TestCommon.h"
#import "DescLRU.h"
#import "DescLRUManager.h"

@interface EditDescViewControllerTest : ViewControllerWithNavBarTestCase <EditDescViewDelegate> {
    NSString *mDescription;
}

@property(retain, readonly) EditDescViewController *vc;

@end

@implementation EditDescViewControllerTest

- (UIViewController *)createViewController
{
    // storyboard から生成
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EditDescView" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];

    // 重要: loadView を実行する
    [vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
    return vc;
}

- (EditDescViewController *)vc
{
    return (EditDescViewController *)self.viewController;
}

#pragma mark UIViewControllerTest methods

- (NSString *)viewControllerName
{
    return @"EditDescViewController";
}

- (NSString *)viewControllerNibName
{
    return @"EditDescView";
}

- (BOOL)hasNavigationController
{
    return YES;
}

#pragma mark EditDescViewDelegate

- (void)editDescViewChanged:(EditDescViewController*)v
{
    mDescription = v.desc;
}

#pragma mark -

- (void)setUp
{
    [super setUp];
    
    [TestCommon deleteDatabase];

    //[TestCommon installDatabase:@"testdata1"];
    DataModel *dm = [DataModel instance];
    [dm load];

    mDescription = nil;

    // erase all desc LRU data
    [DescLRU delete_cond:nil];

    self.vc.desc = @"TEST";
    self.vc.category = 100;
    self.vc.delegate = self;

    [self.vc viewDidLoad]; // ###
    [self.vc viewWillAppear:YES]; // ###
}

- (void)tearDown
{
    //[vc viewWillDisappear:YES];
    mDescription = nil;
    [super tearDown];
}

- (UITableViewCell *)_cellForRow:(int)row section:(int)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)testDescArea
{
    XCTAssertEqual(2, [self.vc numberOfSectionsInTableView:self.vc.tableView]);
    XCTAssertEqual(1, [self.vc tableView:self.vc.tableView numberOfRowsInSection:0]);
    
    UITableViewCell *cell = [self _cellForRow:0 section:0];
    XCTAssert(cell != nil);

    [self.vc doneAction];
    XCTAssertEqualObjects(@"TEST", mDescription);
}

- (void)testEmptyLRU
{
    int n = [self.vc tableView:self.vc.tableView numberOfRowsInSection:1];
    XCTAssertEqual(0, n);
}

- (void)testAnyCategory
{
    Database *db = [Database instance];
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];

    self.vc.category = -1;
    [self.vc viewWillAppear:YES]; // reload descArray

    int n = [self.vc tableView:self.vc.tableView numberOfRowsInSection:1];
    XCTAssertEqual(6, n);
    
    if (n == 6) {
        UITableViewCell *cell;
        cell = [self _cellForRow:0 section:1];
        XCTAssertEqualObjects(@"test5", cell.textLabel.text);
        cell = [self _cellForRow:5 section:1];
        XCTAssertEqualObjects(@"test0", cell.textLabel.text);
    }
}

- (void)testSpecificCategory
{
    Database *db = [Database instance];
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];

    self.vc.category = 1;
    [self.vc viewWillAppear:YES]; // reload descArray

    int n = [self.vc tableView:self.vc.tableView numberOfRowsInSection:1];
    XCTAssertEqual(2, n);

    if (n == 2) {
        UITableViewCell *cell;
        cell = [self _cellForRow:0 section:1];
        XCTAssertEqualObjects(@"test4", cell.textLabel.text);
        cell = [self _cellForRow:1 section:1];
        XCTAssertEqualObjects(@"test1", cell.textLabel.text);
    }
}

- (void)testClickCell
{
    Database *db = [Database instance];
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];

    self.vc.category = -1;
    [self.vc viewWillAppear:YES]; // reload descArray

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.vc tableView:self.vc.tableView didSelectRowAtIndexPath:indexPath];
    XCTAssertEqualObjects(@"test4", mDescription);
}

@end
