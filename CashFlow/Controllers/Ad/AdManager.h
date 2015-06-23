// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

#if FREE_VERSION
@import GoogleMobileAds;
//#import "GADBannerView.h"
//#import "DFPBannerView.h"

//#define ADMOB_PUBLISHER_ID  @"a14a8b599ca8e92"  // CashFlow Free
//#define ADMOB_MEDIATION_ID @"ca-app-pub-4621925249922081/9133593505"
//#define ADUNIT_ID   ADMOB_MEDIATION_ID

#define DFP_ADUNIT_ID @"/86480491/CashFlowFree_iOS_320x50"
#define ADUNIT_ID     DFP_ADUNIT_ID

//#define DFP_TEST_ID @"/86480491/TestUnit_iOS_320x50"
//#define ADUNIT_ID     DFP_TEST_ID

@class AdManager;

/**
 *  AdMob 表示用ラッパクラス。xxxBannerView を継承。
 */
@interface AdView : DFPBannerView <GADBannerViewDelegate>
//@interface AdView : GADBannerView <GADBannerViewDelegate>
@end

//
// AdManager からの通知用インタフェース
//
@protocol AdManagerDelegate
- (void)adManager:(AdManager*)adManager showAd:(AdView *)adView adSize:(CGSize)adSize;
- (void)adManager:(AdManager*)adManager removeAd:(AdView *)adView adSize:(CGSize)adSize;
@end

//
// AdManager : 広告表示用マネージャ
//
@interface AdManager : NSObject <GADBannerViewDelegate>

@property(nonatomic,assign) BOOL isShowAdSucceeded;

+ (AdManager *)sharedInstance;

- (void)attach:(id<AdManagerDelegate>)delegate rootViewController:(UIViewController *)rootViewController;
- (void)detach;
- (BOOL)requestShowAd;

@end

#endif // FREE_VERSION

