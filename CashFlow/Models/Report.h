// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "DataModel.h"

#define REPORT_DAILY 0
#define REPORT_WEEKLY 1
#define REPORT_MONTHLY 2
#define REPORT_ANNUAL 3

#define MAX_REPORT_ENTRIES      365

/*
  レポートの構造

  Report -> ReportEntry -> CatReport
 */

@class ReportEntry;
@class CatReport;

/**
   レポート
*/
@interface Report : NSObject

/** レポート種別 (REPORT_XXX) */
@property(nonatomic,assign) NSInteger type;
/** 期間毎の ReportEntry の配列 */
@property(nonatomic,strong,nonnull) NSMutableArray<ReportEntry *> *reportEntries;

- (void)generate:(NSInteger)type asset:(nullable Asset *)asset;
@property (nonatomic, getter=getMaxAbsValue, readonly) double maxAbsValue;

@end
