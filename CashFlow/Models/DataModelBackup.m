// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import "AppDelegate.h"
#import "DataModel.h"
#import "Config.h"
#import "DescLRUManager.h"

@implementation DataModel(Backup)

#define BACKUP_FILE_VERSION 3
#define BACKUP_FILE_IDENT_PRE @"-- CashFlow Backup Format rev. "
#define BACKUP_FILE_IDENT_POST @" --"

- (NSString *)backupFileIdent
{
    return [NSString stringWithFormat:@"%@%d%@", BACKUP_FILE_IDENT_PRE, BACKUP_FILE_VERSION, BACKUP_FILE_IDENT_POST];
}

/**
 * Ident からバージョン番号を取り出す
 */
- (int)getBackupFileIdentVersion:(NSString *)line
{
    NSString *pattern = [NSString stringWithFormat:@"%@(\\d+)%@", 
                                  BACKUP_FILE_IDENT_PRE, BACKUP_FILE_IDENT_POST];

    NSError *error;
    NSRegularExpression *regex;
    regex = [NSRegularExpression
                regularExpressionWithPattern:pattern
                                     options:0
                                       error:&error];

    NSTextCheckingResult *match;
    match  = [regex firstMatchInString:line
                               options:0
                                 range:NSMakeRange(0, line.length)];
    if (match == nil) return -1;
    
    NSString *verString = [line substringWithRange:[match rangeAtIndex:1]];
    int ver = verString.intValue;
    
    return ver;
}

- (NSString *)getBackupSqlPath
{
    return [[Database instance] dbPath:@"CashFlowBackup.sql"];
}

/**
 * SQL でファイルに書きだす
 */
- (BOOL)backupDatabaseToSql:(NSString *)path
{
    NSMutableString *sql = [NSMutableString new];
    
    [sql appendString:[self backupFileIdent]];
    [sql appendString:@"\n"];

    [Asset getTableSql:sql];
    [Transaction getTableSql:sql];
    [TCategory getTableSql:sql];
    [DescLRU getTableSql:sql];

    return [sql writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}

/**
 * ファイルから SQL を読みだして実行する
 */
- (BOOL)restoreDatabaseFromSql:(NSString *)path
{
    Database *db = [Database instance];

    // 先に VACUUM を実行しておく
    [db exec:@"VACUUM;"];

    // SQL をファイルから読み込む
    NSString *sql = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (sql == nil) {
        return NO;
    }

    // check ident
    int ver = [self getBackupFileIdentVersion:sql];
    if (ver < 0) {
        NSLog(@"Invalid backup data ident");
        return NO;
    }
    if (ver > BACKUP_FILE_VERSION) {
        NSLog(@"Backup file version too new");
        return NO;
    }

    // SQL 実行
    [db beginTransaction];
    if (![db exec:sql]) {
        [db rollbackTransaction];
        return NO;
    }
    [db commitTransaction];

    // 再度 VACUUM を実行
    [db exec:@"VACUUM;"];

    return YES;
}

@end
