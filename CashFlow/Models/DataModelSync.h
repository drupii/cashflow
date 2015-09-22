// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "Database.h"

@interface DataModel(Sync)

- (void)setLastSyncRemoteRev:(nonnull NSString *)rev;
- (BOOL)isRemoteModifiedAfterSync:(nonnull NSString *)currev;
- (void)setSyncFinished;
@property (nonatomic, getter=isModifiedAfterSync, readonly) BOOL modifiedAfterSync;

@end
