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

@implementation DataModel(Sync)

#define KEY_LAST_SYNC_REMOTE_REV        @"LastSyncRemoteRev"
#define KEY_LAST_MODIFIED_DATE_OF_DB    @"LastModifiedDateOfDatabase"

- (void)setLastSyncRemoteRev:(NSString *)rev
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:rev forKey:KEY_LAST_SYNC_REMOTE_REV];
    
    NSLog(@"set last sync remote rev: %@", rev);
}

- (BOOL)isRemoteModifiedAfterSync:(NSString *)currev
{
    if (currev == nil) {
        // リモートが存在しない場合は、変更されていないとみなす。
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastrev = [defaults objectForKey:KEY_LAST_SYNC_REMOTE_REV];
    if (lastrev == nil) {
        // まだ同期したことがない。remote は変更されているものとみなす
        return YES;
    }
    return ![lastrev isEqualToString:currev];
}

- (NSDate *)_lastModificationDateOfDatabase
{
    Database *db = [Database instance];
    NSString *dbpath = [db dbPath:[DataModel dbname]];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *attrs = [manager attributesOfItemAtPath:dbpath error:nil];
    NSDate *date = attrs[NSFileModificationDate];
    return date;
}

- (void)setSyncFinished
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastdate = [self _lastModificationDateOfDatabase];
    [defaults setObject:lastdate forKey:KEY_LAST_MODIFIED_DATE_OF_DB];
    
    NSLog(@"sync finished: DB modification date is %@", lastdate);
}

- (BOOL)isModifiedAfterSync
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastdate = [defaults objectForKey:KEY_LAST_MODIFIED_DATE_OF_DB];
    if (lastdate == nil) {
        // まだ同期したことがない。local は変更されているものとみなす。
        return YES;
    }
    NSDate *curdate = [self _lastModificationDateOfDatabase];
    return ![curdate isEqualToDate:lastdate];
}

@end
