// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

@class EditMemoViewController;

@protocol EditMemoViewDelegate
- (void)editMemoViewChanged:(EditMemoViewController *)vc identifier:(NSInteger)id;
@end

@interface EditMemoViewController : UIViewController <UITextViewDelegate>

@property(nonatomic,unsafe_unretained) id<EditMemoViewDelegate> delegate;
@property(nonatomic,assign) NSInteger identifier;
@property(nonatomic,strong) NSString *text;

+ (EditMemoViewController *)editMemoViewController:(id<EditMemoViewDelegate>)delegate title:(NSString*)title identifier:(NSInteger)id;

@end
