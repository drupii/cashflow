// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

#import "Database.h"

@interface DataModel(Backup)

// sql backup operation
- (BOOL)backupDatabaseToSql:(nonnull NSString *)path;
- (BOOL)restoreDatabaseFromSql:(nonnull NSString *)path;
@property (nonatomic, getter=getBackupSqlPath, readonly, copy, nonnull) NSString *backupSqlPath;

@end
