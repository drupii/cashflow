// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class GenEditTextViewController;

@protocol GenEditTextViewDelegate
- (void)genEditTextViewChanged:(GenEditTextViewController *)vc identifier:(NSInteger)id;
@end

@interface GenEditTextViewController : UIViewController

@property(nonatomic,unsafe_unretained) id<GenEditTextViewDelegate> delegate;
@property(nonatomic,assign) NSInteger identifier;
@property(nonatomic,strong) NSString *text;

+ (nonnull GenEditTextViewController *)create:(id<GenEditTextViewDelegate>)delegate title:(NSString*)title identifier:(NSInteger)id;
@end
