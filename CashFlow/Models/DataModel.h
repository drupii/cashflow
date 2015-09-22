// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Category.h"
#import "DescLRU.h"
#import "Database.h"

@class Ledger;
@class Journal;

@protocol DataModelDelegate
- (void)dataModelLoaded;
@end

@interface DataModel : NSObject

@property(nonatomic,strong,nonnull) Journal *journal;
@property(nonatomic,strong,nonnull) Ledger *ledger;
@property(nonatomic,strong,nonnull) Categories *categories;
@property(readonly) BOOL isLoadDone;

+ (nonnull DataModel *)instance;
+ (void)finalize;

+ (void)setDbName:(nonnull NSString *)dbname; // for unit testing...

+ (nonnull Journal *)getJournal;
+ (nonnull Ledger *)getLedger;
+ (nonnull Categories *)getCategories;

// initializer
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

// load/save
- (void)startLoad:(nonnull id<DataModelDelegate>)delegate;
- (void)loadThread:(nonnull id)dummy;
- (void)load;

// utility operation
//+ (NSString*)currencyString:(double)x;

- (NSInteger)categoryWithDescription:(nonnull NSString *)desc;

// sql backup operation
- (BOOL)backupDatabaseToSql:(nonnull NSString *)path;
- (BOOL)restoreDatabaseFromSql:(nonnull NSString *)path;
@property (nonatomic, getter=getBackupSqlPath, readonly, copy, nonnull) NSString *backupSqlPath;

// for sync
- (void)setLastSyncRemoteRev:(nonnull NSString *)rev;
- (BOOL)isRemoteModifiedAfterSync:(nonnull NSString *)currev;
- (void)setSyncFinished;
@property (nonatomic, getter=isModifiedAfterSync, readonly) BOOL modifiedAfterSync;

@end
