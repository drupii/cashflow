// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "CashflowDatabase.h"

@implementation Database(cashflow)

+ (Database *)instance
{
    Database *db = [self _instance];
    if (db == nil) {
        db = [CashflowDatabase new];
        [self _setInstance:db];
    }
    return db;
}

@end

@implementation CashflowDatabase
{
    NSDateFormatter *dateFormatter;
    DateFormatter2 *dateFormatter2;
    NSDateFormatter *dateFormatter3;
}

- (instancetype)init
{
    self = [super init];
    
    _needFixDateFormat = false;
	
    dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    
    // Set US locale, because JP locale for date formatter is buggy,
    // especially for 12 hour settings.
    NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"US"];
    dateFormatter.locale = us;

    // backward compat.
    dateFormatter2 = [DateFormatter2 new];
    dateFormatter2.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    dateFormatter2.dateFormat = @"yyyyMMddHHmm";
    
    // for broken data...
    dateFormatter3 = [DateFormatter2 new];
    dateFormatter3.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    dateFormatter3.dateFormat = @"yyyyMMdd";
    
    return self;
}


#pragma mark -
#pragma mark Utilities

// Override
- (NSDate *)dateFromString:(NSString *)str
{
    NSDate *date = nil;
    
    if (str.length == 14) { // yyyyMMddHHmmss
        date = [dateFormatter dateFromString:str];
    }
    if (date == nil) {
        // backward compat.
        _needFixDateFormat = true;
        date = [dateFormatter2 dateFromString:str];

        if (date == nil) {
            date = [dateFormatter3 dateFromString:str];
        }
        if (date == nil) {
            date = [dateFormatter dateFromString:@"20000101000000"]; // fallback
        }
    }
    return date;
}

// Override
- (NSString *)stringFromDate:(NSDate *)date
{
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}

@end
