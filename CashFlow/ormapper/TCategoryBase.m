// DO NOT MODIFY!
// Generated by mb-ormapper generator ver 2.2
// https://github.com/tmurakam/mb-ormapper

#import "Database.h"
#import "TCategoryBase.h"

@interface TCategoryBase ()

- (void)_insert;
- (void)_update;
+ (NSString *)tableName;
- (void)_loadRow:(dbstmt *)stmt;
@end

@implementation TCategoryBase

- (instancetype)init
{
    self = [super init];
    return self;
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = @[
        @"name", @"TEXT",
        @"sorder", @"INTEGER",
        ];

    return [super migrate:columnTypes primaryKey:@"key"];
}

#pragma mark Read operations

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (nullable TCategory *)find:(NSInteger)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM Categories WHERE key = ?;"];
    [stmt bindInt:0 val:pid];

    return [self find_first_stmt:stmt];
}

/**
  finder with name

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (nullable TCategory*)find_by_name:(NSString*)key cond:(nullable NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE name = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE name = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (nullable TCategory*)find_by_name:(NSString*)key
{
    return [self find_by_name:key cond:nil];
}

/**
  finder with sorder

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (nullable TCategory*)find_by_sorder:(NSInteger)key cond:(nullable NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE sorder = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE sorder = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (nullable TCategory*)find_by_sorder:(NSInteger)key
{
    return [self find_by_sorder:key cond:nil];
}


/**
  Get first record matches the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (nullable TCategory *)find_first:(NSString *)cond
{
    if (cond == nil) {
        cond = @"LIMIT 1";
    } else {
        cond = [cond stringByAppendingString:@" LIMIT 1"];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    return  [self find_first_stmt:stmt];
}

/**
  Get all records match the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (nonnull NSMutableArray *)find_all:(NSString *)cond
{
    dbstmt *stmt = [self gen_stmt:cond];
    return  [self find_all_stmt:stmt];
}

/**
  @brief create dbstmt

  @param s condition
  @return dbstmt
*/
+ (nonnull dbstmt *)gen_stmt:(nullable NSString *)cond
{
    NSString *sql;
    if (cond == nil) {
        sql = @"SELECT * FROM Categories;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM Categories %@;", cond];
    }  
    dbstmt *stmt = [[Database instance] prepare:sql];
    return stmt;
}

/**
  Get first record matches the conditions

  @param stmt Statement
  @return array of records
*/
+ (nullable TCategory *)find_first_stmt:(nonnull dbstmt *)stmt
{
    if ([stmt step] == SQLITE_ROW) {
        TCategoryBase *e = [[self class] new];
        [e _loadRow:stmt];
        return (TCategory *)e;
    }
    return nil;
}

/**
  Get all records match the conditions

  @param stmt Statement
  @return array of records
*/
+ (nonnull NSMutableArray *)find_all_stmt:(nonnull dbstmt *)stmt
{
    NSMutableArray *array = [NSMutableArray new];

    while ([stmt step] == SQLITE_ROW) {
        TCategoryBase *e = [[self class] new];
        [e _loadRow:stmt];
        [array addObject:e];
    }
    return array;
}

- (void)_loadRow:(nonnull dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.name = [stmt colString:1];
    self.sorder = [stmt colInt:2];
}

#pragma mark Create operations

- (void)_insert
{
    [super _insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    //[db beginTransaction];
    stmt = [db prepare:@"INSERT INTO Categories VALUES(NULL,?,?);"];
    [stmt bindString:0 val:_name];
    [stmt bindInt:1 val:_sorder];
    [stmt step];

    self.pid = [db lastInsertRowId];

    //[db commitTransaction];

    [[Database instance] setModified];
}

#pragma mark Update operations

- (void)_update
{
    [super _update];

    Database *db = [Database instance];
    //[db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE Categories SET "
        "name = ?"
        ",sorder = ?"
        " WHERE key = ?;"];
    [stmt bindString:0 val:_name];
    [stmt bindInt:1 val:_sorder];
    [stmt bindInt:2 val:self.pid];

    [stmt step];
    //[db commitTransaction];

    [[Database instance] setModified];
}

#pragma mark Delete operations

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM Categories WHERE key = ?;"];
    [stmt bindInt:0 val:self.pid];
    [stmt step];

    [[Database instance] setModified];
}

/**
  @brief Delete all records
*/
+ (void)delete_cond:(nullable NSString *)cond
{
    Database *db = [Database instance];

    if (cond == nil) {
        cond = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Categories %@;", cond];
    [db exec:sql];

    [[Database instance] setModified];
}

+ (void)delete_all
{
    [TCategoryBase delete_cond:nil];
}

/**
 * get table sql
 */
+ (void)getTableSql:(nonnull NSMutableString *)s
{
    [s appendString:@"DROP TABLE Categories;\n"];
    [s appendString:@"CREATE TABLE Categories (key INTEGER PRIMARY KEY"];

    [s appendFormat:@", name TEXT"];
    [s appendFormat:@", sorder INTEGER"];
    
    [s appendString:@");\n"];

    NSMutableArray *ary = [self find_all:nil];
    for (TCategoryBase *e in ary) {
        [e getInsertSql:s];
        [s appendString:@"\n"];
    }
}

/**
 * get "INSERT" SQL
 */
- (void)getInsertSql:(nonnull NSMutableString *)s
{
    [s appendFormat:@"INSERT INTO Categories VALUES(%ld", (long)self.pid];
    [s appendString:@","];
    [s appendString:[self quoteSqlString:_name]];
    [s appendString:@","];
    [s appendString:[self quoteSqlString:[NSString stringWithFormat:@"%ld", (long)_sorder]]];
    [s appendString:@");"];
}

#pragma mark Internal functions

+ (NSString *)tableName
{
    return @"Categories";
}

@end
