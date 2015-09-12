// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"

//
// 各資産（勘定）のエントリ
//
@interface AssetEntry : NSObject

@property(nonatomic,assign) NSInteger assetKey;
@property(nonatomic,strong,nonnull) Transaction *transaction;
@property(nonatomic,assign) double value;
@property(nonatomic,assign) double balance;
@property(nonatomic,assign) double evalue;

// for search filter (TransactionListViewController)
@property(nonatomic) NSInteger originalIndex;

- (nonnull instancetype)initWithTransaction:(nonnull Transaction *)t withAsset:(nonnull Asset *)asset;
- (BOOL)changeType:(NSInteger)type assetKey:(NSInteger)as dstAssetKey:(NSInteger)das;
@property (nonatomic) NSInteger dstAsset;
- (BOOL)isDstAsset;

@end
