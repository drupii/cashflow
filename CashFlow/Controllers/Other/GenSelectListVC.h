// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GenSelectListViewController;

@protocol GenSelectListViewDelegate
- (BOOL)genSelectListViewChanged:(nonnull GenSelectListViewController*)vc identifier:(NSInteger)id;
@end

@interface GenSelectListViewController : UITableViewController

@property(nonatomic,unsafe_unretained,nonnull) id<GenSelectListViewDelegate> delegate;
@property(nonatomic,assign) NSInteger identifier;
@property(nonatomic,strong, nonnull) NSArray *items;
@property(nonatomic,assign) NSInteger selectedIndex;

+ (nonnull GenSelectListViewController *)create:(nonnull id<GenSelectListViewDelegate>)delegate items:(nonnull NSArray*)ary title:(nonnull NSString*)title identifier:(NSInteger)id;

@end
