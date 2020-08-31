//
//  IMAHandler.h
//  KALTURAPlayerSDK
//
//  Created by Nissim Pardo on 8/20/15.
//  Copyright (c) 2015 Kaltura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class IMACompanionAdSlot;
@protocol IMAContentPlayhead

/**
 *  Reflects the current playback time in seconds for the content.
 *  The property is key value observable.
 */
@property(nonatomic, readonly) NSTimeInterval currentTime;

@end

@protocol AdDisplayContainer <NSObject>

- (instancetype)initWithAdContainer:(UIView *)adContainer
                     viewController:(nullable UIViewController *)adContainerViewController
                     companionSlots:(nullable NSArray<IMACompanionAdSlot *> *)companionSlots;

@end

@protocol AdsRequest <NSObject>

- (instancetype)initWithAdTagUrl:(NSString *)adTagUrl
              adDisplayContainer:(id<AdDisplayContainer>)adDisplayContainer
                 contentPlayhead:(NSObject<IMAContentPlayhead> *)contentPlayhead
                     userContext:(id)userContext;

@end

@protocol Settings <NSObject>

@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign) BOOL enableOmidExperimentally;

@end

@protocol AdsLoader <NSObject>

@property (nonatomic, strong) id delegate;

- (instancetype)initWithSettings:(id<Settings>)settings;
- (void)requestAdsWithRequest:(id<AdsRequest>)request;
- (void)contentComplete;

@end



@protocol AdsRenderingSettings <NSObject>

@property (nonatomic, strong) id webOpenerPresentingController;
@property (nonatomic, strong) id webOpenerDelegate;

@end

@protocol AVPlayerContentPlayhead <NSObject>

- (instancetype)initWithAVPlayer:(AVPlayer *)player;

@end

@protocol AdsManager <NSObject>

@property (nonatomic, strong) id delegate;

- (void)initializeWithAdsRenderingSettings:(id<AdsRenderingSettings>)adsRenderingSettings;

- (void)start;
- (void)pause;
- (void)resume;
- (void)destroy;

@end



@protocol AdsLoadedData <NSObject>

@property (nonatomic, strong) id<AdsManager> adsManager;

@end

@protocol AdError <NSObject>

@property (nonatomic, copy) NSString *message;

@end

@protocol AdLoadingErrorData <NSObject>

@property (nonatomic, strong) id<AdError> adError;

@end

/**
 *  Different event types sent by the IMAAdsManager to its delegate.
 */
typedef NS_ENUM(NSInteger, IMAAdEventType){
  /**
   *  Ad break ready.
   */
  kIMAAdEvent_AD_BREAK_READY,
  /**
   *  Ad break will not play back any ads.
   */
  kIMAAdEvent_AD_BREAK_FETCH_ERROR,
  /**
   *  Ad break ended (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_BREAK_ENDED,
  /**
   *  Ad break started (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_BREAK_STARTED,
  /**
   *  Ad period ended (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_PERIOD_ENDED,
  /**
   *  Ad period started is fired when an ad period starts. This includes the
   *  entire ad break including slate as well. This event will be fired even for
   *  ads that are being replayed or when seeking to the middle of an ad break.
   *  (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_PERIOD_STARTED,
  /**
   *  All ads managed by the ads manager have completed.
   */
  kIMAAdEvent_ALL_ADS_COMPLETED,
  /**
   *  Ad clicked.
   */
  kIMAAdEvent_CLICKED,
  /**
   *  Single ad has finished.
   */
  kIMAAdEvent_COMPLETE,
  /**
   *  Cuepoints changed for VOD stream (only used for dynamic ad insertion).
   *  For this event, the <code>IMAAdEvent.adData</code> property contains a list of
   *  <code>IMACuepoint</code>s at <code>IMAAdEvent.adData[@"cuepoints"]</code>.
   */
  kIMAAdEvent_CUEPOINTS_CHANGED,
  /**
   *  First quartile of a linear ad was reached.
   */
  kIMAAdEvent_FIRST_QUARTILE,
  /**
   *  An ad was loaded.
   */
  kIMAAdEvent_LOADED,
  /**
   *  A log event for the ads being played. These are typically non fatal errors.
   */
  kIMAAdEvent_LOG,
  /**
   *  Midpoint of a linear ad was reached.
   */
  kIMAAdEvent_MIDPOINT,
  /**
   *  Ad paused.
   */
  kIMAAdEvent_PAUSE,
  /**
   *  Ad resumed.
   */
  kIMAAdEvent_RESUME,
  /**
   *  Ad has skipped.
   */
  kIMAAdEvent_SKIPPED,
  /**
   *  Ad has started.
   */
  kIMAAdEvent_STARTED,
  /**
   *  Stream request has loaded (only used for dynamic ad insertion).
   */
  kIMAAdEvent_STREAM_LOADED,
  /**
   *  Stream has started playing (only used for dynamic ad insertion). Start
   *  Picture-in-Picture here if applicable.
   */
  kIMAAdEvent_STREAM_STARTED,
  /**
   *  Ad tapped.
   */
  kIMAAdEvent_TAPPED,
  /**
   *  Third quartile of a linear ad was reached.
   */
  kIMAAdEvent_THIRD_QUARTILE
};

@protocol AdPodInfo <NSObject>

@property (nonatomic) int adPosition;

@end

@protocol Ad <NSObject>

@property (nonatomic) BOOL isLinear;
@property (nonatomic, copy) NSString *adId;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) id<AdPodInfo> adPodInfo;

@end

@protocol AdEvent <NSObject>

@property (nonatomic) IMAAdEventType type;
@property (nonatomic, strong) id<Ad> ad;

@end
