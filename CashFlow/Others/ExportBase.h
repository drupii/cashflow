// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;
@import MessageUI;

#import <DropboxSDK/DropboxSDK.h>

#import "ExportServer.h"
#import "Asset.h"
#import "DBLoadingView.h"

#define REPLACE(from, to) \
  [str replaceOccurrencesOfString: from withString: to \
  options:NSLiteralSearch range:NSMakeRange(0, [str length])]
	
@interface ExportBase : NSObject <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, DBRestClientDelegate>

@property(nonatomic,strong) NSDate *firstDate;
@property(nonatomic,unsafe_unretained) NSArray *assets;

@property(nonatomic,readonly) DBRestClient *restClient;

// public methods
- (BOOL)sendMail:(UIViewController*)parent error:(NSError**)error;
- (BOOL)sendToDropbox:(UIViewController*)parent error:(NSError**)error;
@property (nonatomic, readonly) BOOL sendWithWebServer;

// You must override following methods
@property (nonatomic, readonly, copy) NSString *mailSubject;
@property (nonatomic, readonly, copy) NSString *fileName;
@property (nonatomic, readonly, copy) NSString *mimeType;
@property (nonatomic, readonly, copy) NSString *contentType;
@property (nonatomic, readonly, copy) NSData *generateBody;

@end

