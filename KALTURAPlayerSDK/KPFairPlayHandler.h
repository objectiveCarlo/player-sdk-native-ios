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

@interface KPFairPlayHandler : NSObject <KPAssetHandler>

@end
