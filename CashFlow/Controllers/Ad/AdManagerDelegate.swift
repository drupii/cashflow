/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

@objc protocol AdManagerDelegate {
    func showAd(adManager: AdManager, adView:UIView, adSize: CGSize)
    func removeAd(adManager: AdManager, adView:UIView, adSize: CGSize)
}
