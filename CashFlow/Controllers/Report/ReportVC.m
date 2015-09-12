// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "ReportVC.h"
#import "ReportCatVC.h"
#import "ReportCell.h"
#import "Config.h"

@implementation ReportViewController
{
    IBOutlet UITableView *_tableView;
    
    NSInteger _type;
    Report *_reports;
    double _maxAbsValue;
    
    ReportEntry *_showingReportEntry; // 表示中のエントリ
    
    NSDateFormatter *_dateFormatter;
}

+ (ReportViewController *)instantiate
{
    return [[UIStoryboard storyboardWithName:@"ReportView" bundle:nil] instantiateInitialViewController];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    _dateFormatter = [NSDateFormatter new];
    return self;
}

- (void)setAsset:(Asset*)asset type:(NSInteger)type
{
    self.designatedAsset = asset;

    _type = type;

    [self _updateReport];
}

- (void)setAsset:(Asset*)asset
{
    [self setAsset:asset type:-1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[AppDelegate trackPageview:@"/ReportViewController"];

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


/**
   レポート(再)生成
*/
- (void)_updateReport
{
    // レポート種別を設定から読み込む
    Config *config = [Config instance];
    if (_type < 0) {
        _type = config.lastReportType;
    }

    switch (_type) {
        default:
            _type = REPORT_DAILY;
            // FALLTHROUGH
        case REPORT_DAILY:
            self.title = _L(@"Daily Report");
            _dateFormatter.dateFormat = @"yyyy/MM/dd";
            break;

        case REPORT_WEEKLY:
            self.title = _L(@"Weekly Report");
            _dateFormatter.dateFormat = @"yyyy/MM/dd~";
            break;

        case REPORT_MONTHLY:
            self.title = _L(@"Monthly Report");
            //[dateFormatter setDateFormat:@"yyyy/MM"];
            _dateFormatter.dateFormat = @"~yyyy/MM/dd";
            break;

        case REPORT_ANNUAL:
            self.title = _L(@"Annual Report");
            _dateFormatter.dateFormat = @"yyyy";
            break;
    }

    // 設定保存
    config.lastReportType = _type;
    [config save];

    // レポート生成
    if (_reports == nil) {
        _reports = [Report new];
    }
    [_reports generate:_type asset:_designatedAsset];
    _maxAbsValue = [_reports getMaxAbsValue];

    [self.tableView reloadData];
}

// レポートのタイトルを得る
- (NSString *)_reportTitle:(ReportEntry *)report
{
    if (_reports.type == REPORT_MONTHLY) {
        // 終了日の時刻の１分前の時刻から年月を得る
        //
        // 1) 締め日が月末の場合、endDate は翌月1日0:00を指しているので、
        //    1分前は当月最終日の23:59である。
        // 2) 締め日が任意の日、例えば25日の場合、endDate は当月25日を
        //    指している。そのまま年月を得る。
        NSDate *d = [report.end dateByAddingTimeInterval:-60];
        return [_dateFormatter stringFromDate:d];
    } else {
        return [_dateFormatter stringFromDate:report.start];
    }
}

#pragma mark Event Handlers

- (IBAction)setReportDaily:(id)sender
{
    _type = REPORT_DAILY;
    [self _updateReport];
}

- (IBAction)setReportWeekly:(id)sender;
{
    _type = REPORT_WEEKLY;
    [self _updateReport];
}

- (IBAction)setReportMonthly:(id)sender;
{
    _type = REPORT_MONTHLY;
    [self _updateReport];
}

- (IBAction)setReportAnnual:(id)sender;
{
    _type = REPORT_ANNUAL;
    [self _updateReport];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_reports.reportEntries).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ReportCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = (_reports.reportEntries).count;
    ReportEntry *report = (_reports.reportEntries)[count - indexPath.row - 1];
	
    ReportCell *cell = (ReportCell*)[tv dequeueReusableCellWithIdentifier:@"ReportCell"];
    cell.name = [self _reportTitle:report];
    cell.income = report.totalIncome;
    cell.outgo = report.totalOutgo;
    cell.maxAbsValue = _maxAbsValue;
    [cell updateGraph];

    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
	
    NSInteger count = (_reports.reportEntries).count;
    _showingReportEntry = (_reports.reportEntries)[count - indexPath.row - 1];

    [self performSegueWithIdentifier:@"show" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CatReportViewController *vc = segue.destinationViewController;
    
    vc.title = [self _reportTitle:_showingReportEntry];
    vc.reportEntry = _showingReportEntry;
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
