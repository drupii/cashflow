// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

#import <DropboxSDK/DropboxSDK.h>

#import "DataModel.h"
//#import "DataModelDateUtils.h"
#import "DataModelBackup.h"
#import "DataModelSync.h"

#define DBNAME  @"CashFlow.db"

// Utility
#define _L(msg)  NSLocalizedString(msg, @"")

void AssertFailed(const char *filename, int lineno);
#ifdef NDEBUG
#define ASSERT(x)  if (!(x)) AssertFailed(__FILE__, __LINE__)
#else
#define ASSERT(x) /**/
#endif

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

