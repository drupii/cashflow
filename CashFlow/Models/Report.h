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

/**
   レポート(カテゴリ毎)

   本エントリは、期間(ReportEntry)毎、カテゴリ毎に１つ生成
*/
@interface CatReport : NSObject

/** カテゴリ (-1 は未分類) */
@property(nonatomic,readonly) NSInteger category;

/** 資産キー (-1 の場合は指定なし) */
@property(nonatomic,readonly) NSInteger assetKey;

/** 該当カテゴリ内の金額合計 */
@property(nonatomic,readonly) double sum;

/** 本カテゴリに含まれる Transaction 一覧 */
@property(nonatomic,strong,readonly,nonnull) NSMutableArray<Transaction *> *transactions;

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithCategory:(NSInteger)category withAsset:(NSInteger)assetKey NS_DESIGNATED_INITIALIZER;
- (void)addTransaction:(nonnull Transaction*)t;

@property (nonatomic, readonly, copy, nonnull) NSString *title;

@end
