// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "DataModel.h"

@class CatReport;

/**
   各期間毎のレポートエントリ
*/
@interface ReportEntry : NSObject

/** 期間開始日 */
@property(nonatomic,strong,readonly,nonnull) NSDate *start;

/** 期間終了日 */
@property(nonatomic,strong,readonly,nonnull) NSDate *end;

/** 期間内の総収入 */
@property(nonatomic,assign,readonly) double totalIncome;

/** 期間内の総支出 */
@property(nonatomic,assign,readonly) double totalOutgo;

/** 収入の最大値 */
@property(nonatomic,assign,readonly) double maxIncome;

/** 支出の最大値（絶対値の) */
@property(nonatomic,assign,readonly) double maxOutgo;

/** カテゴリ毎の収入レポート */
@property(nonatomic,strong,readonly,nonnull) NSMutableArray<CatReport *> *incomeCatReports;

/** カテゴリ毎の支出レポート */
@property(nonatomic,strong,readonly,nonnull) NSMutableArray<CatReport *> *outgoCatReports;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithAsset:(NSInteger)assetKey start:(nonnull NSDate *)start end:(nonnull NSDate *)end NS_DESIGNATED_INITIALIZER;

- (BOOL)addTransaction:(nonnull Transaction*)t;
- (void)sortAndTotalUp;

@end
