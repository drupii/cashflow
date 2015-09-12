/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */
import Foundation

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    var window : UIWindow?

    var _application : UIApplication?

    var navigationController : UINavigationController?
    var splitViewController : UISplitViewController?

    var _detailNavigationController : UINavigationController?

    var _privacyView : UIView?

    //
    // バージョン番号文字列を返す
    //
    class func appVersion() -> String {
        let dict = NSBundle.mainBundle().infoDictionary!
        return dict["CFBundleShortVersionString"] as! String
    }

    class func isFreeVersion() -> Bool {
#if FREE_VERSION
        return true
#else
        return false
#endif
    }

    override init() {
        super.init()
    }

    //
    // 開始処理
    //
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptionschingWithOptions: [NSObject : AnyObject]?) -> Bool {
        println("application:didFinishLaunchingWithOptions")
        _application = application;

        // Crittercism or BugSense
        /*
#if FREE_VERSION
        let CRITTERCISM_API_KEY = "50cdc6bb86ef114132000002"
        let BUGSENSE_API_KEY = "70f8a5d3"
#else
        let CRITTERCISM_API_KEY = "50cdc6697e69a342c7000005"
        let BUGSENSE_API_KEY = "b64aaa9e"
#endif
        */

        //[Crittercism enableWithAppID:CRITTERCISM_API_KEY];
        //[BugSenseController sharedControllerWithBugSenseAPIKey:BUGSENSE_API_KEY];

        // Fabric
        Fabric.with([Crashlytics.sharedInstance()])

        // Dropbox config
        var dbSession = DBSession(appKey: DROPBOX_APP_KEY, appSecret: DROPBOX_APP_SECRET, root: kDBRootDropbox)
        //dbSession.delegate = self;
        DBSession.setSharedSession(dbSession);

        self.setupGoogleAnalytics()

        // Configure and show the window
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

        var assetListNavigationController = UIStoryboard(name: "AssetListView", bundle: nil).instantiateInitialViewController() as! UINavigationController

        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone) {
            // iPhone 版 : Window 生成
            _detailNavigationController = assetListNavigationController
            self.navigationController = assetListNavigationController
            self.window!.rootViewController = self.navigationController
        } else {
            // iPad 版 : Window 生成
            var masterNavigationController = assetListNavigationController
            var assetListViewController = masterNavigationController.topViewController as! AssetListViewController

            var transactionListViewController = TransactionListViewController.instantiate()
            _detailNavigationController = UINavigationController(rootViewController: transactionListViewController)

            assetListViewController.splitTransactionListViewController = transactionListViewController
            transactionListViewController.splitAssetListViewController = assetListViewController

            self.splitViewController = UISplitViewController()
            self.splitViewController!.delegate = transactionListViewController
            self.splitViewController!.viewControllers = [masterNavigationController, _detailNavigationController!]

            self.window!.rootViewController = self.splitViewController
        }
        self.window!.makeKeyAndVisible()

        // PIN チェック
        self.checkPin()

        // 乱数初期化
        srand(UInt32(NSDate().timeIntervalSinceReferenceDate))

        // 遅延実行
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "delayedLaunchProcess:", userInfo: nil, repeats: false)

        println("application:didFinishLaunchingWithOptions: done")
        return true
    }

    // Google Analytics 設定
    private func setupGoogleAnalytics() {
        // Google analytics
        var gai = GAI.sharedInstance()

        gai.trackUncaughtExceptions = true

        // デバッグログ
        //[gai.logger setLogLevel:kGAILogLevelVerbose];

        var tracker = gai.trackerWithTrackingId("UA-413697-25")

#if FREE_VERSION
        tracker.set(GAIFields.customDimensionForIndex(1), value: "ios-free")
#else
        tracker.set(GAIFields.customDimensionForIndex(1), value: "ios-std")
#endif

        // set custom dimensions
        var version = AppDelegate.appVersion()
        tracker.set(GAIFields.customDimensionForIndex(2), value: version)

        var dev = UIDevice.currentDevice()
        //var model = dev.model()
        var platform = dev.platform()
        var systemVersion = dev.systemVersion

        tracker.set(GAIFields.customDimensionForIndex(3), value: systemVersion)
        tracker.set(GAIFields.customDimensionForIndex(4), value: platform)
    }

    // プライバシービュー関連処理
    private func privacyView() -> UIView {
        if (_privacyView == nil) {
            _privacyView = UIView(frame: self.window!.frame)
            _privacyView!.backgroundColor = UIColor.whiteColor()
        }
        return _privacyView!;
    }

    private func showPrivacyView() {
        self.window!.addSubview(self.privacyView())
    }

    private func hidePrivacyView() {
        self.privacyView().removeFromSuperview()
    }

    // 起動時の遅延実行処理
    private func delayedLaunchProcess(timer: NSTimer) {
        println("delayedLaunchProcess")

        var tracker = GAI.sharedInstance().defaultTracker
        //TODO:tracker.send(GAIDictionaryBuilder.createEventWithCategory("Application", action: "launch", label: nil, value: nil).build())
    }

    func applicationWillResignActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("willResignActive", object: nil)
    }

    // Background に入る前の処理
    func applicationDidEnterBackground(application: UIApplication) {
        // Background に入るまえに PIN コード表示を行っておく
        // 復帰時だと、前の画面が一瞬表示されたあとで PIN 画面がでてしまうので遅い
        self.checkPin()

        if (PinController.sharedController().pin != nil) {
            // snapshot 保存しない (うまく動作しないようだが、一応)
            UIApplication.sharedApplication().ignoreSnapshotOnNextApplicationLaunch()

            // 画面を隠しておく
            //self.window.hidden = YES;
            self.showPrivacyView()
        }
    }

    // Background から復帰するときの処理
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("willEnterForeground", object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // 画面表示
        //self.window.hidden = NO;
        self.hidePrivacyView()
    }

    private func checkPin() {
        var pinController = PinController.sharedController()
        if (pinController != nil) {
            if (isIpad()) {
                pinController.firstPinCheck(self.splitViewController)
            } else {
                pinController.firstPinCheck(self.navigationController)
            }
        }
    }

    //
    // 終了処理 : データ保存
    //
    func applicationWillTerminate(application: UIApplication) {
        DataModel.finalize()
        Database.shutdown()
    }

    //
    // Dropbox link 完了時の処理
    //
    func application(application: UIApplication, handleOpenURL url:NSURL) -> Bool {
        //UIAlertView *v;
        if (DBSession.sharedSession().handleOpenURL(url)) {
            if (DBSession.sharedSession().isLinked()) {
                println("Dropbox linked successfully")
                var v = UIAlertView(title: "Dropbox", message: "Login successful, please retry backup or export.",
                        delegate: nil, cancelButtonTitle:"Close")
                v.show()
            } else {
                // TODO:
            }
            return true
        }
        return false
    }

    // MARK: - GoogleAnalytics
/*
+ (void)trackPageview:(NSString *)url
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker sendView:url];
}
 */

    class func trackEvent(category: String, action: String, label: String, value: Int) {
        var tracker = GAI.sharedInstance().defaultTracker
        var dict = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value).build()
        tracker.send(dict as [NSObject : AnyObject])
    }


    // MARK: - Debug
    class func AssertFailed(filename: String, lineno: Int) {
        var v = UIAlertView(title: "Assersion Failed", message: "\(filename) line \(lineno)", delegate: nil, cancelButtonTitle: "Close")
        v.show()
    }
}
