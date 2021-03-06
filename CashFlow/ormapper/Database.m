// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  O/R Mapper library for iOS

  Copyright (c) 2010-2013, Takuya Murakami. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "Database.h"

@interface Database() {
    BOOL _isDirty;
    NSString *_dbPath; ///< Current database file path
}
@end

@implementation Database

/** Singleton */
static Database *sDatabase = nil;

/**
   Return the database instance (singleton)

   @return Database singleton instance
   @note If you want to modify this class, use category.
*/
+ (nonnull Database *)instance
{
    if (sDatabase == nil) {
        sDatabase = [[self class] new];
    }
    return sDatabase;
}

+ (Database *)_instance
{
    return sDatabase;
}

+ (void)_setInstance:(Database *)database
{
    if (sDatabase != nil) {
        NSLog(@"WARNING: Old Database instance was released.");
    }
    sDatabase = database;
}

/**
   Shutdown the database
*/
+ (void)shutdown
{
    sDatabase = nil;
}

/**
   Constructor
*/
- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _handle = nil;
        _isDirty = false;
    }
    return self;
}

/**
   Destructor
*/
- (void)dealloc
{
    if (self == sDatabase) {
        sDatabase = nil;
    } else {
        NSLog(@"WARNING: database instance was released, but it didn't match the singleton");
    }

    if (_handle != nil) {
        sqlite3_close(_handle);
    }
}

/**
   Open database

   @return Returns YES if database exists, otherwise create database and returns NO.
*/
- (BOOL)open:(NSString *)dbname
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Load from DB
    _dbPath = [self dbPath:dbname];
    BOOL isExistedDb = [fileManager fileExistsAtPath:_dbPath];

    if (sqlite3_open(_dbPath.UTF8String, &_handle) != 0) {
        // ouch!
        // re-create database
        [fileManager removeItemAtPath:_dbPath error:NULL];
        sqlite3_open(_dbPath.UTF8String, &_handle);

        isExistedDb = NO;
    }

    NSLog(@"Database:open: %d", isExistedDb);
    return isExistedDb;
}

/**
   Execute SQL statement
*/
- (BOOL)exec:(NSString *)sql
{
    //ASSERT(mHandle != 0);

    //LOG(@"SQL: %s", sql);
    NSInteger result = sqlite3_exec(_handle, sql.UTF8String, NULL, NULL, NULL);
    if (result != SQLITE_OK) {
        //LOG(@"sqlite3: %s", sqlite3_errmsg(mHandle));
        return NO;
    }
    return YES;
}

/**
   Prepare statement

   @param[in] sql SQL statement
   @return dbstmt instance
*/
- (dbstmt *)prepare:(NSString *)sql
{
    sqlite3_stmt *stmt;
    NSInteger result = sqlite3_prepare_v2(_handle, sql.UTF8String, -1, &stmt, NULL);
    if (result != SQLITE_OK) {
        //LOG(@"sqlite3: %s", sqlite3_errmsg(mHandle));
        //ASSERT(0);
    }

    dbstmt *dbs = [[dbstmt alloc] initWithStmt:stmt];
    //dbs.handle = self.handle;
    return dbs;
}

/**
   Get last inserted row id
*/
- (NSInteger)lastInsertRowId
{
    return sqlite3_last_insert_rowid(_handle);
}

/**
   Start transaction
*/
- (void)beginTransaction
{
    [self exec:@"BEGIN;"];
}

/**
   Commit transaction
*/
- (void)commitTransaction
{
    [self exec:@"COMMIT;"];
}

/**
   Rollback transaction
*/
- (void)rollbackTransaction
{
    [self exec:@"ROLLBACK;"];
}

/**
   Return database file path

   @param dbname Database file name, if it is nil, data folder name will be return.
   @return Full path of the file name or directory path.
*/
- (NSString*)dbPath:(NSString *)dbname
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *dataDir = paths[0];
    NSString *dbPath;

    if (dbname == nil) {
        dbPath = dataDir;
    } else {
        dbPath = [dataDir stringByAppendingPathComponent:dbname];
    }

    NSLog(@"dbPath = %@", dbPath);
    return dbPath;
}

/**
   Modification hook
*/
- (void)setModified
{
    _isDirty = YES;
}

/**
   Update modification date of database
*/
- (void)updateModificationDate
{
    if (_isDirty) {
        _isDirty = NO;

        NSFileManager *m = [NSFileManager defaultManager];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[m attributesOfItemAtPath:_dbPath error:nil]];
        dict[NSFileModificationDate] = [NSDate new];
        [m setAttributes:dict ofItemAtPath:_dbPath error:nil];
    }
}

#pragma mark -
#pragma mark Utilities

/**
   Return NSDateFormatter instance to format DATE field

   @note You can override this.
 */
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        dateFormatter.dateFormat = @"yyyyMMddHHmmss";

        // Avoid trivial bug for 'AM/PM' handling for some locales.
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"US"];
    }
    return dateFormatter;
}

/**
   Convert date string to NSDate

   @param str Date string
   @return date

   @note You can override this.
*/
- (NSDate *)dateFromString:(NSString *)str
{
    // default impl.
    NSDate *date = [[self dateFormatter] dateFromString:str];
    if (date == nil) {
        date = [[self dateFormatter] dateFromString:@"20000101000000"]; // fallback
    }
    return date;
}

/**
   Convert NSDate to string

   @parem date NSDate
   @return Date string

   @note You can override this.
*/
- (NSString *)stringFromDate:(NSDate *)date
{
    // default impl.
    return [[self dateFormatter] stringFromDate:date];
}

@end
