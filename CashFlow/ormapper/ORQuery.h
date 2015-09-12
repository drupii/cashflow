// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <UIKit/UIKit.h>
#import "Database.h"

/**
   O/R query
 */
@interface ORQuery : NSObject

+ (ORQuery *)getWithClass:(Class)class tableName:(NSString *)tableName;

- (instancetype)initWithClass:(Class)class tableName:(NSString *)tableName NS_DESIGNATED_INITIALIZER;

- (ORQuery *)where:(NSString *)where arguments:(NSArray *)args;
- (ORQuery *)order:(NSString *)order;
- (ORQuery *)limit:(NSInteger)limit;
- (ORQuery *)offset:(NSInteger)limit;

@property (nonatomic, readonly, copy) NSMutableArray *all;
@property (nonatomic, readonly, strong) id first;

@end


