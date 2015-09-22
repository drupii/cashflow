// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "TransactionBase.h"

extern NSInteger const TYPE_OUTGO; // 支払い
extern NSInteger const TYPE_INCOME; // 入金
extern NSInteger const TYPE_ADJ; // 残高調整
extern NSInteger const TYPE_TRANSFER; // 資産間移動

@class Asset;

@interface Transaction : TransactionBase <NSCopying>

// for balance adjustment
@property(nonatomic,assign) BOOL hasBalance;
@property(nonatomic,assign) double balance;

- (nonnull instancetype)initWithDate:(nonnull NSDate *)date description:(nonnull NSString *)desc value:(double)v;
- (void)updateWithoutUpdateLRU;

+ (nonnull NSDate *)lastUsedDate;
+ (void)setLastUsedDate:(nullable NSDate *)date;
+ (BOOL)hasLastUsedDate;

@end
