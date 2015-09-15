// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "DataModel.h"

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
