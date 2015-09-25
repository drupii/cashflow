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
        } else {
            adSize = kGADAdSizeBanner
            //以下のようにiPhone 6 横幅に自動で合わせたいが、これをやると Nend の広告がでない！
            //adSize = GADAdSizeFullWidthPortraitWithHeight(GAD_SIZE_320x50.height);
        }
        self.init(adSize: adSize)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/**
 * 広告マネージャ
 *
 * Note: 広告の状態は以下のとおり
 * 1) View未アタッチ状態 (_bannerView == nil)
 * 2) 広告ロード前 (_isAdMobShowing, _isAdLoaded ともに false)
 * 3) 広告ロード済み、未表示 (_isAdLoaded が true)
 * 4) 広告表示中 (_isAdShowing が true)
 */
class AdManager : NSObject, GADBannerViewDelegate {
    private static let DFP_ADUNIT_ID = "/86480491/CashFlowFree_iOS_320x50"
    private static let ADUNIT_ID = DFP_ADUNIT_ID

    // 広告リクエスト間隔 (画面遷移時のみ)
    private let AD_REQUEST_INTERVAL = 30.0

    private var isShowAdSucceeded: Bool = false
    
    private var delegate: AdManagerDelegate?
    private weak var rootViewController: UIViewController?
    
    // 広告ビュー
    private var bannerView: AdView?
    
    // 広告サイズ
    private var adSize: CGSize?

    // 広告ロード済み状態
    private var isAdLoaded: Bool = false

    // 広告表示中状態
    private var isAdShowing: Bool = false

    // 最後に広告をリクエストした日時
    private var lastAdRequestDate: NSDate?

    private static var theAdManager: AdManager? = nil

    static func sharedInstance() -> AdManager? {
        if (theAdManager == nil) {
            theAdManager = AdManager()
        }
        return theAdManager;
    }

    override init() {
        super.init()
    }

    deinit {
        // singleton なのでここには原則こない
        self.releaseAdView()
        self.detach()
    }

    /**
     * 広告を ViewController に attach する
     */
    func attach(delegate: AdManagerDelegate, rootViewController:UIViewController) {
        self.delegate = delegate
        self.rootViewController = rootViewController
        self.isAdShowing = false
    }

    func detach() {
        self.delegate = nil
        self.rootViewController = nil
    
        // 広告を root view から抜く
        if (self.bannerView != nil) {
            self.bannerView!.rootViewController = nil // TODO これ大丈夫？
            self.bannerView!.removeFromSuperview()
        }
        self.isAdShowing = false

        // view controller からデタッチされた場合、
        // 次回は必ずリロードする
        self.lastAdRequestDate = nil
    }

    /**
    * 広告表示を要求する
    */
    func requestShowAd() -> Bool {
        if self.delegate == nil {
            return false // デタッチ状態
        }

        if self.bannerView == nil {
            self.createAdView()
        }
        self.bannerView!.rootViewController = self.rootViewController
    
        var forceRequest = false
    
        if (!self.isAdShowing) {
            // 広告未表示の場合
            if (self.isAdLoaded) {
                // ロード済みの場合、表示する
                print("showAd: show loaded ad");
                self.delegate!.showAd(self, adView: self.bannerView!, adSize: self.adSize!)
                self.isAdShowing = true
            } else {
                // ロード済みでない場合は、すぐに広告リクエストを発行する
                forceRequest = true
            }
        }
    
        return self.requestAd(forceRequest)
    }

    /**
     * 広告リクエストを発行する
     */
    private func requestAd(forceRequest: Bool) -> Bool {
        // 一定時間経過していない場合、リクエストは発行しない
        if (!forceRequest) {
            if (!self.isAdTimerTimeout()) {
                print("requestAd: do not request ad (within ad interval)")
                return false
            }
        }
    
        // 広告リクエストを開始する
        print("requestAd: start request new ad.")
        let req = GADRequest()
        req.testDevices = [
                        //"7f201a0d427175b074ea55a63a482388", // ip6
                        //"f887d54080341da8df23060f8146ba79", // ipm
                        //GAD_SIMULATOR_ID
                        ]
        
        self.bannerView!.loadRequest(req)

        // リクエスト時刻を保存
        self.lastAdRequestDate = NSDate()
        return true
    }

    func isAdTimerTimeout() -> Bool {
        if self.lastAdRequestDate != nil {
            let now = NSDate()
            let diff = now.timeIntervalSinceDate(self.lastAdRequestDate!)
            if diff < AD_REQUEST_INTERVAL {
                return false
            }
        }
        return true
    }

    // MARK: - Internal

    /**
    * 広告作成
    */
    private func createAdView() {
        print("create Ad view")
    
        //let adSize = kGADAdSizeBanner
        //let adSize = GAD_SIZE_320x50
        let adSize = GADAdSizeFromCGSize(CGSizeMake(320.0, 50.0))
    
        /* Note: Mediation では標準サイズバナーのみ
        if (IS_IPAD) {
            gadSize = kGADAdSizeFullBanner;
            mAdMobSize = GAD_SIZE_468x60;
        }
        */

        let view = AdView()
        view.delegate = self
    
        print("AdUnit = \(AdManager.ADUNIT_ID)")
        view.adUnitID = AdManager.ADUNIT_ID
        view.rootViewController = nil // この時点では不明
        view.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin]

        // まだリクエストは発行しない

        self.bannerView = view
    }

    /**
     * 広告解放
     */
    private func releaseAdView() {
        print("release Ad view")
        self.isAdLoaded = false

        if (self.bannerView != nil) {
            self.bannerView!.delegate = nil
            self.bannerView!.rootViewController = nil
            self.bannerView = nil
        }
    }

    // MARK: - GADBannerViewDelegate

    func adViewDidReceiveAd(view: GADBannerView) {
        print("Ad loaded : class = \(view.adNetworkClassName)")
        self.isAdLoaded = true

        self.adSize = view.frame.size
    
        if (self.delegate != nil && !self.isAdShowing) {
            self.isAdShowing = true
            self.delegate!.showAd(self, adView: self.bannerView!, adSize: self.adSize!)
        }
    }

    func adView(view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        if self.bannerView == nil {
            return
        }
    
        var msg: String
        if self.bannerView!.hasAutoRefreshed {
            // auto refresh failed, but previous ad is effective.    
            msg = "Ad auto refresh failed"
        } else {
            msg = "Ad load failed"
        }
        let errorDesc = error.localizedDescription
        print("\(msg) : <<\(errorDesc)>>")
    
        /*
         AdMob SDK バグ対応。ネットワーク未接続状態で広告取得失敗した場合、
         view を残しておくとクラッシュを引き起こすため、一旦削除して作りなおす。
         */
        self.isAdLoaded = false
        self.delegate!.removeAd(self, adView: self.bannerView!, adSize: self.adSize!)
        self.isAdShowing = false

        self.releaseAdView()

        if self.lastAdRequestDate != nil && self.isAdTimerTimeout() {
            // 再試行
            self.requestShowAd()
        } else {
            // タイマリセット
            //self.lastAdRequestDate = nil
        }
    }
}
