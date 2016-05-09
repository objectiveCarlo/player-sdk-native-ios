//
//  CCKPlayer.h
//  KALTURAPlayerSDK
//
//  Created by Eliza Sapir on 6/14/15.
//  Copyright (c) 2015 Kaltura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPlayerFactory.h"
#import "KRouterManager.h"
//#import "ChromecastDeviceController.h"

@interface KCCPlayer : NSObject <KPlayer, KRouterManagerDelegate>

/* The device manager used for the currently casting media. */
@property(strong, nonatomic) KRouterManager *chromecastDeviceController;

@end
