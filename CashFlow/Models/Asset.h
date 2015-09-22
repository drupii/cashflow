// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "Database.h"
#import "AssetBase.h"

@class AssetEntry;

// asset types
#define NUM_ASSET_TYPES 5

typedef NS_ENUM(NSInteger, AssetType) {
    AssetTypeCash = 0,
    AssetTypeBank = 1,
    AssetTypeCard = 2,
    AssetTypeInvest = 3,
    AssetTypeEmoney = 4
};

@class Database;

//
// 資産 (総勘定元帳の勘定に相当)
// 
@interface Asset : AssetBase

+ (NSInteger)numAssetTypes;
+ (nonnull NSArray*)typeNamesArray;
+ (nonnull NSString*)typeNameWithType:(NSInteger)type;
+ (nonnull NSString*)iconNameWithType:(NSInteger)type;

- (void)rebuild;

@property (nonatomic, readonly) NSInteger entryCount;
- (nonnull AssetEntry *)entryAt:(NSInteger)n;
- (void)insertEntry:(nonnull AssetEntry *)tr;
- (void)replaceEntryAtIndex:(NSInteger)index withObject:(nonnull AssetEntry *)t;
- (void)deleteEntryAt:(NSInteger)n;
- (void)deleteOldEntriesBefore:(nonnull NSDate*)date;
- (NSInteger)firstEntryByDate:(nonnull NSDate*)date;

@property (nonatomic, readonly) double lastBalance;
- (void)updateInitialBalance;

@end
