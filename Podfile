source 'https://github.com/CocoaPods/Specs.git'
platform :ios,'8.0'

link_with ['CashFlow', 'CashFlowFree', 'UnitTests']

pod 'Dropbox-iOS-SDK'

#pod 'CrashlyticsFramework'
pod 'Fabric'
pod 'Crashlytics'
#pod 'BugSense'
#pod 'CrittercismSDK'

#pod 'GoogleAnalytics-iOS-SDK'
pod 'Google/Analytics', '~> 1.0.0'

pod 'RDVCalendarView', '~> 1.0.7'

target :free do
  link_with 'CashFlowFree'

  pod 'Google-Mobile-Ads-SDK'
  pod 'AdMobMediationAdapterIAd'

  pod 'NendSDK_iOS'
  pod 'NendSDK_iOS_MediationAdapter'

  ### うまく動作しないため、一旦解除
  #pod 'InMobiSDK'
  #pod 'AdMobMediationAdapterInMobi', :podspec => './podspecs/AdMobMediationAdapterInMobi.podspec'
  #pod 'AdMobMediationAdapterInMobi'

  # Adapter iMobile deps
  #pod 'ASIHTTPRequest'
  #pod 'JSONKit'
end

# XCode7.1 向け一時対応
# see: https://github.com/CocoaPods/CocoaPods/issues/4420
post_install do |installer|
  `find Pods -regex 'Pods/Google.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)GoogleMobileAds\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end
