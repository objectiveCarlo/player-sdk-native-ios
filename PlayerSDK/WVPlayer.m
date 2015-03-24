//
//  WVPlayer.m
//  KALTURAPlayerSDK
//
//  Created by Nissim Pardo on 3/24/15.
//  Copyright (c) 2015 Kaltura. All rights reserved.
//

#import "WVPlayer.h"
#import "WViPhoneAPI.h"
#import "KPLog.h"

static NSString *kPortalKey = @"kaltura";

@implementation WVPlayer
@synthesize DRMKey;
- (void)setPlayerSource:(NSURL *)playerSource {
    [self.class DRMSource:playerSource.absoluteString key:self.DRMKey completion:^(NSString *drmUrl) {
        super.playerSource = [NSURL URLWithString:drmUrl];
    }];
}


+ (void)DRMSource:(NSString *)src key:(NSString *)key completion:(void (^)(NSString *))completion {
    WV_Initialize(WVCallback, @{WVDRMServerKey: key, WVPortalKey: kPortalKey});
    [self performSelector:@selector(fetchDRMParams:) withObject:@[src, completion] afterDelay:0.1];
}

+ (void)fetchDRMParams:(NSArray *)params {
    NSMutableString *responseUrl = [NSMutableString string];
    WViOsApiStatus status = WV_Play(params[0], responseUrl, 0);
    KPLogDebug(@"widevine response url: %@", responseUrl);
    if ( status != WViOsApiStatus_OK ) {
        KPLogError(@"ERROR: %u",status);
        return;
    }
    ((void(^)(NSString *))params[1])(responseUrl);
}


WViOsApiStatus WVCallback( WViOsApiEvent event, NSDictionary *attributes ) {
    KPLogTrace(@"Enter");
    KPLogInfo( @"callback %d %@\n", event, NSStringFromWViOsApiEvent( event ) );
    
    KPLogTrace(@"Exit");
    return WViOsApiStatus_OK;
}

@end
