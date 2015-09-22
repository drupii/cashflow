// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

// DataModel V2
// (SQLite ver)

#import "CashFlow-Swift.h"

#import "AppDelegate.h"
#import "DataModel.h"
#import "Config.h"
#import "DescLRUManager.h"

@interface DataModel()
@end

@implementation DataModel
{
    id<DataModelDelegate> _delegate;
}

static DataModel *theDataModel = nil;

static NSString *theDbName = DBNAME;

+ (DataModel *)instance
{
    if (!theDataModel) {
        theDataModel = [DataModel new];
    }
    return theDataModel;
}

+ (void)finalize
{
    if (theDataModel) {
        theDataModel = nil;
    }
}

+ (NSString *)dbname
{
    return theDbName;
}

// for unit testing
+ (void)setDbName:(NSString *)dbname
{
    theDbName = dbname;
}

- (instancetype)init
{
    self = [super init];

    _journal = [Journal new];
    _ledger = [Ledger new];
    _categories = [Categories new];
    _isLoadDone = NO;
	
    return self;
}


+ (Journal *)getJournal
{
    return [DataModel instance].journal;
}

+ (Ledger *)getLedger
{
    return [DataModel instance].ledger;
}

+ (Categories *)getCategories
{
    return [DataModel instance].categories;
}

- (void)startLoad:(id<DataModelDelegate>)delegate
{
    _delegate = delegate;
    _isLoadDone = NO;
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadThread:) object:nil];
    [thread start];
}

- (void)loadThread:(id)dummy
{
    @autoreleasepool {

        [self load];
        
        _isLoadDone = YES;
        if (_delegate) {
            [_delegate dataModelLoaded];
        }
    
    }
    [NSThread exit];
}

- (void)load
{
    Database *db = [Database instance];

    // Load from DB
    if (![db open:theDbName]) {
    }

    [Transaction migrate];
    [Asset migrate];
    [TCategory migrate];
    [DescLRU migrate];
    
    [DescLRUManager migrate];
	
    // Load all transactions
    [_journal reload];

    // Load ledger
    [_ledger load];
    [_ledger rebuild];

    // Load categories
    [_categories reload];
}

////////////////////////////////////////////////////////////////////////////
// Utility

// 摘要からカテゴリを推定する
//
// note: 本メソッドは Asset ではなく DataModel についているべき
//
- (NSInteger)categoryWithDescription:(NSString *)desc
{
    Transaction *t = [Transaction find_by_description:desc cond:@"ORDER BY date DESC"];

    if (t == nil) {
        return -1;
    }
    return t.category;
}

@end
