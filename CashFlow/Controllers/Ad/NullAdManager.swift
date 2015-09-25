/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

class AdView : UIView {
}

class AdManager : NSObject {
    static func sharedInstance() -> AdManager? {
        return nil
    }

    func attach(delegate: AdManagerDelegate, rootViewController:UIViewController) {
    }

    func detach() {
    }

    func requestShowAd() -> Bool {
        return false
    }
}
