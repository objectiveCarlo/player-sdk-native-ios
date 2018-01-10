#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CastProviderInternalDelegate.h"
#import "DeviceParamsHandler.h"
#import "EmailStrategy.h"
#import "FacebookStrategy.h"
#import "GoogleplusStrategy.h"
#import "IMAHandler.h"
#import "KCacheManager.h"
#import "KCastDevice.h"
#import "KCastMediaRemoteControl.h"
#import "KCastProvider.h"
#import "KChromecastPlayer.h"
#import "KChromeCastWrapper.h"
#import "KCustomPlayHead.h"
#import "KMediaPlayerDefines.h"
#import "KPAssetBuilder.h"
#import "KPAssetHandler.h"
#import "KPBrowserViewController.h"
#import "KPCacheConfig.h"
#import "KPController.h"
#import "KPController_Private.h"
#import "KPControlsUIWebView.h"
#import "KPControlsView.h"
#import "KPControlsWKWebView.h"
#import "KPFairPlayHandler.h"
#import "KPIMAPlayerViewController.h"
#import "KPlayer.h"
#import "KPlayerFactory.h"
#import "KPLocalAssetsManager.h"
#import "KPLog.h"
#import "KPLogManager.h"
#import "KPMediaPlayback.h"
#import "KPPlayerConfig.h"
#import "KPPlayerConfig_Private.h"
#import "KPShareManager.h"
#import "KPURLProtocol.h"
#import "KPViewController.h"
#import "KPViewControllerProtocols.h"
#import "KPWebKitBrowserViewController.h"
#import "KPWidevineClassicHandler.h"
#import "linkedinStrategy.h"
#import "NSBundle+Kaltura.h"
#import "NSDictionary+Cache.h"
#import "NSDictionary+Strategy.h"
#import "NSDictionary+Utilities.h"
#import "NSMutableArray+QueryItems.h"
#import "NSMutableArray+QueueAdditions.h"
#import "NSMutableDictionary+AdSupport.h"
#import "NSMutableDictionary+Cache.h"
#import "NSString+Utilities.h"
#import "SmsStrategy.h"
#import "TwitterStrategy.h"
#import "Utilities.h"
#import "WidevineClassicCDM.h"
#import "WViPhoneAPI.h"

FOUNDATION_EXPORT double KalturaPlayerSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char KalturaPlayerSDKVersionString[];

