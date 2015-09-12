// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Journal.h"
#import "Ledger.h"
#import "Category.h"
#import "DescLRU.h"
#import "Database.h"

@protocol DataModelDelegate
- (void)dataModelLoaded;
@end

@interface DataModel : NSObject

@property(nonatomic,strong) Journal *journal;
@property(nonatomic,strong) Ledger *ledger;
@property(nonatomic,strong) Categories *categories;
@property(readonly) BOOL isLoadDone;

+ (DataModel *)instance;
+ (void)finalize;

+ (void)setDbName:(NSString *)dbname; // for unit testing...

+ (Journal *)journal;
+ (Ledger *)ledger;
+ (Categories *)categories;

+ (NSDateFormatter *)dateFormatter;
+ (NSDateFormatter *)dateFormatter:(BOOL)withDayOfWeek;
+ (NSDateFormatter *)dateFormatter:(NSDateFormatterStyle)timeStyle withDayOfWeek:(BOOL)withDayOfWeek;


// initializer
- (instancetype)init;

// load/save
- (void)startLoad:(id<DataModelDelegate>)delegate;
- (void)loadThread:(id)dummy;
- (void)load;

// utility operation
//+ (NSString*)currencyString:(double)x;

- (NSInteger)categoryWithDescription:(NSString *)desc;

// sql backup operation
- (BOOL)backupDatabaseToSql:(NSString *)path;
- (BOOL)restoreDatabaseFromSql:(NSString *)path;
@property (nonatomic, getter=getBackupSqlPath, readonly, copy) NSString *backupSqlPath;

// for sync
- (void)setLastSyncRemoteRev:(NSString *)rev;
- (BOOL)isRemoteModifiedAfterSync:(NSString *)currev;
- (void)setSyncFinished;
@property (nonatomic, getter=isModifiedAfterSync, readonly) BOOL modifiedAfterSync;

@end
