// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

#import "DataModel.h"
#import "GenEditTextVC.h"

@class CategoryListViewController;

@protocol CategoryListViewDelegate
- (void)categoryListViewChanged:(CategoryListViewController *)vc;
@end

@interface CategoryListViewController : UITableViewController
    <GenEditTextViewDelegate>

@property(nonatomic,assign) BOOL isSelectMode;
@property(nonatomic,assign) NSInteger selectedIndex;
@property(nonatomic,unsafe_unretained) id<CategoryListViewDelegate> delegate;

@end
