// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "Report.h"
#import "ReportEntry.h"
#import "CatReport.h"

@implementation CatReport

- (instancetype)initWithCategory:(NSInteger)category withAsset:(NSInteger)assetKey
{
    self = [super init];
    if (self != nil) {
        _category = category;
        _assetKey = assetKey;
        _transactions = [NSMutableArray new];
        _sum = 0.0;
    }
    return self;
}


- (void)addTransaction:(Transaction*)t
{
    if (self.assetKey >= 0 && t.dstAsset == self.assetKey) {
        _sum += -t.value; // 資産間移動の移動先
    } else {
        _sum += t.value;
    }

    [_transactions addObject:t];
}

- (NSString *)title
{
    if (self.category < 0) {
        return _L(@"No category");
    }
    return [[DataModel categories] categoryStringWithKey:self.category];
}

@end
