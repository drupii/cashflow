/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

import GoogleMobileAds

/**
*  AdMob 表示用ラッパクラス。xxxBannerView を継承。
*/
class AdView : DFPBannerView, GADBannerViewDelegate {
    override init(adSize: GADAdSize) {
        super.init(adSize: adSize)
        self.delegate = self
    }
    
    convenience init() {
        var adSize: GADAdSize
        
        if isIpad() {
            // 320 x 50 固定。こうしないと在庫でない模様
            adSize = kGADAdSizeBanner
            
            //adSize = kGADAdSizeSmartBannerPortrait
        } else {
            adSize = kGADAdSizeBanner
            
            // option 2
            //adSize = GADAdSizeFullWidthPortraitWithHeight(50);
            
            // option 3 : SmartBanner
            //adSize = kGADAdSizeSmartBannerPortrait
        }
        self.init(adSize: adSize)
        //print(self.frame.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}