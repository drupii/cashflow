// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// 総勘定元帳

#import <UIKit/UIKit.h>
#import "Journal.h"
#import "Asset.h"
#import "Category.h"
#import "Database.h"

@interface Ledger : NSObject

@property(nonatomic,readonly,nonnull) NSArray<Asset *> *assets;

// asset operation
- (void)load;
- (void)rebuild;
@property (nonatomic, readonly) NSInteger assetCount;
- (nonnull Asset *)assetAtIndex:(NSInteger)n;
- (nullable Asset*)assetWithKey:(NSInteger)key;
- (NSInteger)assetIndexWithKey:(NSInteger)key;

- (void)addAsset:(nonnull Asset *)as;
- (void)deleteAsset:(nonnull Asset *)as;
- (void)updateAsset:(nonnull Asset*)asset;
- (void)reorderAsset:(NSInteger)from to:(NSInteger)to;

@end
