// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

//
// Journal : 仕訳帳
//

#import <UIKit/UIKit.h>
#import "Transaction.h"

//
// 仕訳帳
// 
@interface Journal : NSObject <NSFastEnumeration>

@property(nonatomic,readonly,nonnull) NSArray<Transaction *> *entries;

- (void)reload;

- (void)insertTransaction:(nonnull Transaction*)tr;
- (void)replaceTransaction:(nonnull Transaction *)from withObject:(nonnull Transaction*)to;
- (BOOL)deleteTransaction:(nonnull Transaction *)tr withAsset:(nonnull Asset *)asset;
- (void)deleteAllTransactionsWithAsset:(nonnull Asset *)asset;

@end
