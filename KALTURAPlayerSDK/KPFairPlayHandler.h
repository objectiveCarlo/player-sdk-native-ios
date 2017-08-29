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
@protocol KPFairPlayLocalStorage;
@interface KPFairPlayHandler : NSObject <KPAssetHandler>

@property (nonatomic, assign) BOOL forOffline;
@property (nonatomic, assign) id<KPFairPlayLocalStorage> localStorage;

@end

@protocol KPFairPlayLocalStorage <NSObject>
- (NSData *)load:(NSString *)key;
- (void)save:(NSString *)key value:(NSData *)data;
@end
