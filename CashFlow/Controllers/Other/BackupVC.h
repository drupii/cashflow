// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

#import "DBLoadingView.h"
#import "DropboxBackup.h"

@class BackupViewController;

@protocol BackupViewDelegate
- (void)backupViewFinished:(BackupViewController *)backupViewController;
@end

@interface BackupViewController : UITableViewController <DropboxBackupDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

- (void)setDelegate:(id<BackupViewDelegate>)delegate;
- (IBAction)doneAction:(id)sender;

@end
