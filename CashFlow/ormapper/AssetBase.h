// Generated by O/R mapper generator ver 0.1

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@interface AssetBase : ORRecord {
    NSString* name;
    int type;
    double initialBalance;
    int sorder;
}

@property(nonatomic,retain) NSString* name;
@property(nonatomic,assign) int type;
@property(nonatomic,assign) double initialBalance;
@property(nonatomic,assign) int sorder;

+ (BOOL)migrate;

+ (id)allocator;
+ (NSMutableArray *)find_cond:(NSString *)cond;
+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (NSMutableArray *)find_stmt:(dbstmt *)cond;
+ (AssetBase *)find:(int)pid;
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// internal functions
+ (NSString *)tableName;
- (void)insert;
- (void)update;
- (void)_loadRow:(dbstmt *)stmt;

@end
