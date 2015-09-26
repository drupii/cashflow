// DO NOT MODIFY!
// Generated by mb-ormapper generator ver 2.2
// https://github.com/tmurakam/mb-ormapper

@import UIKit;

#import "ORRecord.h"

@class Transaction;

NS_ASSUME_NONNULL_BEGIN

@interface TransactionBase : ORRecord

@property(nonatomic,assign) NSInteger asset;
@property(nonatomic,assign) NSInteger dstAsset;
@property(nonatomic,strong) NSDate* date;
@property(nonatomic,assign) NSInteger type;
@property(nonatomic,assign) NSInteger category;
@property(nonatomic,assign) double value;
@property(nonatomic,strong) NSString* desc;
@property(nonatomic,strong) NSString* memo;
@property(nonatomic,strong) NSString* identifier;

+ (BOOL)migrate;

// CRUD (Create/Read/Update/Delete) operations

// Read operations (Finder)
+ (nullable Transaction *)find:(NSInteger)pid;

+ (nullable Transaction *)find_by_asset:(NSInteger)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_asset:(NSInteger)key;
+ (nullable Transaction *)find_by_dst_asset:(NSInteger)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_dst_asset:(NSInteger)key;
+ (nullable Transaction *)find_by_date:(NSDate*)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_date:(NSDate*)key;
+ (nullable Transaction *)find_by_type:(NSInteger)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_type:(NSInteger)key;
+ (nullable Transaction *)find_by_category:(NSInteger)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_category:(NSInteger)key;
+ (nullable Transaction *)find_by_value:(double)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_value:(double)key;
+ (nullable Transaction *)find_by_description:(NSString*)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_description:(NSString*)key;
+ (nullable Transaction *)find_by_memo:(NSString*)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_memo:(NSString*)key;
+ (nullable Transaction *)find_by_identifier:(NSString*)key cond:(nullable NSString*)cond;
+ (nullable Transaction *)find_by_identifier:(NSString*)key;

+ (NSArray<Transaction *> *)find_all:(nullable NSString *)cond;

+ (dbstmt *)gen_stmt:(nullable NSString *)cond;
+ (nullable Transaction *)find_first_stmt:(dbstmt *)stmt;
+ (NSArray<Transaction *> *)find_all_stmt:(dbstmt *)stmt;

// Delete operations
- (void)delete;
+ (void)delete_cond:(nullable NSString *)cond;
+ (void)delete_all;

// Dump SQL
+ (void)getTableSql:(NSMutableString *)s;
- (void)getInsertSql:(NSMutableString *)s;

@end

NS_ASSUME_NONNULL_END
