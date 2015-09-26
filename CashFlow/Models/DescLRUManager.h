// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "DescLRU.h"

@interface DescLRUManager : NSObject
+ (void)migrate;

+ (void)addDescLRU:(nonnull NSString *)description category:(NSInteger)category;
+ (void)addDescLRU:(nonnull NSString *)desc category:(NSInteger)category date:(nonnull NSDate*)date;
+ (nonnull NSArray<DescLRU *> *)getDescLRUs:(NSInteger)category;

@end


