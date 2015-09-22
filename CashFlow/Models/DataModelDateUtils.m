// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "CashFlow-Swift.h"

#import <Foundation/Foundation.h>
#import "DataModel.h"
#import "DataModelDateUtils.h"

@implementation DataModel(DateUtils)

//
// DateFormatter
//

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dfDateOnly = nil;
    static NSDateFormatter *dfDateTime = nil;
    
    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        if (dfDateOnly == nil) {
            dfDateOnly = [self dateFormatter:NSDateFormatterNoStyle withDayOfWeek:YES];
        }
        return dfDateOnly;
    } else {
        if (dfDateTime == nil) {
            dfDateTime = [self dateFormatter:NSDateFormatterShortStyle withDayOfWeek:YES];
        }
        return dfDateTime;
    }
}

+ (NSDateFormatter *)dateFormatter:(BOOL)withDayOfWeek
{
    if ([Config instance].dateTimeMode == DateTimeModeDateOnly) {
        return [self dateFormatter:NSDateFormatterNoStyle withDayOfWeek:withDayOfWeek];
    } else {
        return [self dateFormatter:NSDateFormatterShortStyle withDayOfWeek:withDayOfWeek];
    }
}

+ (NSDateFormatter *)dateFormatter:(NSDateFormatterStyle)timeStyle withDayOfWeek:(BOOL)withDayOfWeek
{
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateStyle = NSDateFormatterMediumStyle;
    df.timeStyle = timeStyle;
    
    NSMutableString *s = [NSMutableString stringWithCapacity:30];
    [s setString:df.dateFormat];
    
    if (withDayOfWeek) {
        [s replaceOccurrencesOfString:@"MMM d, y" withString:@"EEE, MMM d, y" options:NSLiteralSearch range:NSMakeRange(0, s.length)];
        [s replaceOccurrencesOfString:@"yyyy/MM/dd" withString:@"yyyy/MM/dd(EEEEE)" options:NSLiteralSearch range:NSMakeRange(0, s.length)];
    }
    
    df.dateFormat = s;
    return df;
}

@end
