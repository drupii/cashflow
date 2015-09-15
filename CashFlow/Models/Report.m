// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import "AppDelegate.h"
#import "Database.h"
#import "Config.h"

#import "Report.h"

/////////////////////////////////////////////////////////////////////
// Report

@implementation Report

- (instancetype)init
{
    self = [super init];
    _type = REPORT_MONTHLY;
    _reportEntries = nil;
    return self;
}


/**
 レポート生成

 @param type タイプ (REPORT_DAILY/WEEKLY/MONTHLY/ANNUAL)
 @param asset 対象資産 (nil の場合は全資産)
 */
- (void)generate:(NSInteger)type asset:(Asset*)asset
{
    self.type = type;
	
    self.reportEntries = [NSMutableArray new];

    NSCalendar *greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	
    // レポートの開始日と終了日を取得
    NSInteger assetKey;
    if (asset == nil) {
        assetKey = -1;
    } else {
        assetKey = asset.pid;
    }
    NSDate *firstDate = [self firstDateOfAsset:assetKey];
    if (firstDate == nil) return; // no data
    NSDate *lastDate = [self lastDateOfAsset:assetKey];

    // レポート周期の開始時間および間隔を求める
    NSDateComponents *dateComponents, *steps;
    NSDate *nextStartDay = nil;
	
    steps = [NSDateComponents new];
    switch (self.type) {
        case REPORT_DAILY:;
            dateComponents = [greg components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:firstDate];
            nextStartDay = [greg dateFromComponents:dateComponents];
            steps.day = 1;
            break;

        case REPORT_WEEKLY:
            dateComponents = [greg components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay) fromDate:firstDate];
            nextStartDay = [greg dateFromComponents:dateComponents];
            
            // 日曜が 1, 土曜が 7
            NSInteger weekday = dateComponents.weekday;
            
            // 前週の指定曜日に設定
            steps.day = - (weekday - 1) - 7+ [Config instance].startOfWeek;
            
            nextStartDay = [greg dateByAddingComponents:steps toDate:nextStartDay options:0];
            steps.day = 7;
            break;

        case REPORT_MONTHLY:
            dateComponents = [greg components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:firstDate];

            // 締め日設定
            NSInteger cutoffDate = [Config instance].cutoffDate;
            if (cutoffDate == 0) {
                // 月末締め ⇒ 開始は同月1日から。
                dateComponents.day = 1;
            }
            else {
                // 一つ前の月の締め日翌日から開始
                NSInteger year = dateComponents.year;
                NSInteger month = dateComponents.month;
                month--;
                if (month < 1) {
                    month = 12;
                    year--;
                }
                dateComponents.year = year;
                dateComponents.month = month;
                dateComponents.day = cutoffDate + 1;
            }

            nextStartDay = [greg dateFromComponents:dateComponents];
            steps.month = 1;
            break;
			
        case REPORT_ANNUAL:
            dateComponents = [greg components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:firstDate];
            dateComponents.month = 1;
            dateComponents.day = 1;
            nextStartDay = [greg dateFromComponents:dateComponents];
            steps.year = 1;
            break;
    }
	
    // レポートエントリを生成する
    while ([nextStartDay compare:lastDate] != NSOrderedDescending) {
        NSDate *start = nextStartDay;

        // 次の期間開始時期を計算する
        nextStartDay = [greg dateByAddingComponents:steps toDate:nextStartDay options:0];

        // Report 生成
        ReportEntry *r = [[ReportEntry alloc] initWithAsset:assetKey
                            start:start end:nextStartDay];
        [self.reportEntries addObject:r];

        // レポート上限数を制限
        if ((self.reportEntries).count > MAX_REPORT_ENTRIES) {
            [self.reportEntries removeObjectAtIndex:0];
        }
    }

    // 集計実行
    // 全取引について、該当する ReportEntry へ transaction を追加する
    for (Transaction *t in [DataModel journal]) {
        for (ReportEntry *r in self.reportEntries) {
            if ([r addTransaction:t]) {
                break;
            }
        }
    }
    for (ReportEntry *r in self.reportEntries) {
        [r sortAndTotalUp];
    }
}

/**
   レポート内の値の最大絶対値を得る
*/
- (double)getMaxAbsValue
{
    double maxAbsValue = 1;
    for (ReportEntry *rep in self.reportEntries) {
        if (rep.totalIncome > maxAbsValue) maxAbsValue = rep.totalIncome;
        if (-rep.totalOutgo > maxAbsValue) maxAbsValue = -rep.totalOutgo;
    }
    return maxAbsValue;
}

/**
 指定された資産の最初の取引日を取得
 */
- (NSDate*)firstDateOfAsset:(NSInteger)asset
{
    NSMutableArray *entries = [DataModel journal].entries;
    Transaction *t = nil;

    for (t in entries) {
        if (asset < 0) break;
        if (t.asset == asset || t.dstAsset == asset) break;
    }
    if (t == nil) {
        return nil;
    }
    return t.date;
}

/**
 指定された資産の最後の取引日を取得
 */
- (NSDate*)lastDateOfAsset:(NSInteger)asset
{
    NSMutableArray *entries = [DataModel journal].entries;
    Transaction *t = nil;
    NSInteger i;

    for (i = entries.count - 1; i >= 0; i--) {
        t = entries[i];
        if (asset < 0) break;
        if (t.asset == asset || t.dstAsset == asset) break;
    }
    if (i < 0) return nil;
    return t.date;
}

@end
