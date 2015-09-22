// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

// 日時モード
typedef NS_ENUM(NSInteger, DateTimeMode) {
    DateTimeModeWithTime = 0,  // 日＋時
    DateTimeModeWithTime5min = 1,  // 日＋時
    DateTimeModeDateOnly = 2  // 日のみ
};
