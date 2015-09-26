// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

#import <DropboxSDK/DropboxSDK.h>
#import "DataModel.h"

typedef NS_ENUM(NSInteger, BackupMode) {
    BackupModeBackup = 0,
    BackupModeRestore = 1,
    BackupModeSync = 2
};

@protocol DropboxBackupDelegate
- (void)dropboxBackupStarted:(BackupMode)mode;
- (void)dropboxBackupFinished;
- (void)dropboxBackupConflicted;
@end

@interface DropboxBackup : NSObject <DBRestClientDelegate, DataModelDelegate>

@property(strong,readonly) DBRestClient *restClient;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)init:(id<DropboxBackupDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (void)doSync:(UIViewController *)viewController;
- (void)doBackup:(UIViewController *)viewController;
- (void)doRestore:(UIViewController *)viewController;
- (void)unlink;

@end
