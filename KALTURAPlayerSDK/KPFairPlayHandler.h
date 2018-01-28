//
//  FairPlayHandler.h
//  KALTURAPlayerSDK
//
//  Created by Noam Tamim on 22/02/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

@import Foundation;
@import AVFoundation;

#import "KPAssetHandler.h"
extern NSString *const FAIRPLAY_LICENSE_WILL_LOAD;
extern NSString *const FAIRPLAY_LICENSE_LOADED;
@protocol KPFairPlayLocalStorage,KPFairPlayLocalListener;
@interface KPFairPlayHandler : NSObject <KPAssetHandler, AVAssetResourceLoaderDelegate>

@property (nonatomic, assign) BOOL forOffline;
@property (nonatomic, strong) NSString *forOfflineListenerKey;
@property (nonatomic, strong) NSString *forOfflineAssetId;
@property (nonatomic, assign) id<KPFairPlayLocalStorage> localStorage;
@property (nonatomic, assign) id<KPFairPlayLocalListener> localListener;


- (dispatch_queue_t) getDefaultQueue;

@end

@protocol KPFairPlayLocalStorage <NSObject>
- (NSData *)load:(NSString *)key;
- (void)save:(NSString *)key value:(NSData *)data;
@end

@protocol KPFairPlayLocalListener <NSObject>
- (void)localListenerOK:(NSString *)key expiration:(NSTimeInterval)expiration localKey:(NSString *)localKey;
- (void)localListenerNotOK:(NSString *)key localKey:(NSString *)localKey;
@end
