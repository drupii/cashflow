// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import "TransactionVC.h"
#import "EditDateVC.h"
#import "AppDelegate.h"
#import "Config.h"

@interface EditDateViewController () <CFCalendarViewControllerDelegate>
- (void)doneAction;
@end

@implementation EditDateViewController
{
    IBOutlet UIDatePicker *_datePicker;
    IBOutlet UIButton *_calendarButton;
    IBOutlet UIButton *_setCurrentButton;
}

+ (EditDateViewController *)instantiate
{
    return [[UIStoryboard storyboardWithName:@"EditDateView" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPAD) {
        CGSize s = self.preferredContentSize;
        s.height = 420;
        self.preferredContentSize = s;
    }
    
    self.title = _L(@"Date");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)];

    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        _datePicker.datePickerMode = UIDatePickerModeDate;
    } else {
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.minuteInterval = 1;
        if ([Config instance].dateTimeMode == DateTimeModeWithTime5min) {
            _datePicker.minuteInterval = 5;
        }
    }
    
    _datePicker.timeZone = [NSTimeZone systemTimeZone];
    
    [_calendarButton setTitle:_L(@"Calendar") forState:UIControlStateNormal];
    [_setCurrentButton setTitle:_L(@"Current Time") forState:UIControlStateNormal];
}


- (void)viewWillAppear:(BOOL)animated
{
    [_datePicker setDate:self.date animated:NO];
    [super viewWillAppear:animated];
}

- (void)doneAction
{
    self.date = _datePicker.date;
    [_delegate editDateViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 * カレンダー表示処理
 */
- (IBAction)showCalendar:(id)sender {
    CFCalendarViewController *vc = [CFCalendarViewController new];
    vc.selectedDate = _datePicker.date;
    vc.delegate = self;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setCurrentTime:(id)sender {
    self.date = [NSDate new]; // current time
    [_datePicker setDate:self.date animated:YES];
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

#pragma mark CFCalendarViewControllerDelegate
- (void)cfcalendarViewController:(CFCalendarViewController *)aCalendarViewController didSelectDate:(NSDate *)aDate
{
    if (aDate == nil) return; // do nothing (Clear button)

    // 時刻を取り出す
    NSCalendar *greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [greg components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_datePicker.date];

    NSInteger hour = comps.hour;
    NSInteger min = comps.minute;
    
    // カレンダーで指定した日時(0:00) に以前の時刻の値を加算する
    self.date = [aDate dateByAddingTimeInterval:(hour * 3600 + min * 60)];

    // Si-Calendar は、選択時に自動で View を閉じない仕様なので、ここで閉じる
    [aCalendarViewController.navigationController popViewControllerAnimated:YES];
}

@end
