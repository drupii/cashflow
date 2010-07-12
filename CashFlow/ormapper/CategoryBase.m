// Generated by O/R mapper generator ver 0.1

#import "Database.h"
#import "CategoryBase.h"

@implementation CategoryBase

@synthesize name;
@synthesize sorder;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [name release];
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
        @"name", @"TEXT",
        @"sorder", @"INTEGER",
        nil];

    return [super migrate:columnTypes];
}

/**
  @brief allocate entry
*/
+ (id)allocator
{
    id e = [[CategoryBase alloc] init];
    return e;
}

/**
  @brief get all records matche the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (NSMutableArray *)find_cond:(NSString *)cond
{
    dbstmt *stmt = [self gen_stmt:cond];
    NSMutableArray *array = [self find_stmt:stmt];
    return array;
}

/**
  @brief create dbstmt

  @param s condition
  @return dbstmt
*/
+ (dbstmt *)gen_stmt:(NSString *)cond
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
  @brief get all records matche the conditions

  @param stmt Statement
  @return array of records
*/
+ (NSMutableArray *)find_stmt:(dbstmt *)stmt
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

    while ([stmt step] == SQLITE_ROW) {
        CategoryBase *e = [[self allocator] autorelease];
        [e _loadRow:stmt];
        [array addObject:e];
    }
    return array;
}

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (CategoryBase *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM Categories WHERE key = ?;"];
    [stmt bindInt:0 val:pid];
    if ([stmt step] != SQLITE_ROW) {
        return nil;
    }

    CategoryBase *e = [[self allocator] autorelease];
    [e _loadRow:stmt];
 
    return e;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.name = [stmt colString:1];
    self.sorder = [stmt colInt:2];

    isInserted = YES;
}

+ (NSString *)tableName
{
    return @"Categories";
}

- (void)insert
{
    [super insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    [db beginTransaction];
    stmt = [db prepare:@"INSERT INTO Categories VALUES(NULL,?,?);"];

    [stmt bindString:0 val:name];
    [stmt bindInt:1 val:sorder];
    [stmt step];

    self.pid = [db lastInsertRowId];

    [db commitTransaction];
    isInserted = YES;
}

- (void)update
{
    [super update];

    Database *db = [Database instance];
    [db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE Categories SET "
        "name = ?"
        ",sorder = ?"
        " WHERE key = ?;"];
    [stmt bindString:0 val:name];
    [stmt bindInt:1 val:sorder];
    [stmt bindInt:2 val:pid];

    [stmt step];
    [db commitTransaction];
}

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM Categories WHERE key = ?;"];
    [stmt bindInt:0 val:pid];
    [stmt step];
}

/**
  @brief Delete all records
*/
+ (void)delete_cond:(NSString *)cond
{
    Database *db = [Database instance];

    if (cond == nil) {
        cond = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Categories %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [CategoryBase delete_cond:nil];
}

@end
