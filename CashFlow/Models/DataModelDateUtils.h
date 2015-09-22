// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

@interface DataModel(DateUtils)

+ (nonnull NSDateFormatter *)dateFormatter;
+ (nonnull NSDateFormatter *)dateFormatter:(BOOL)withDayOfWeek;
+ (nonnull NSDateFormatter *)dateFormatter:(NSDateFormatterStyle)timeStyle withDayOfWeek:(BOOL)withDayOfWeek;

@end
