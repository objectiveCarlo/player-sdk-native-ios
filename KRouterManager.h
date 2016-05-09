//
//  KRouterManager.h
//  KALTURAPlayerSDK
//
//  Created by Eliza Sapir on 04/05/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRouterInfo.h"

@protocol KRouterManagerDelegate <NSObject>

- (void)castButtonDidClick;
- (void)castStatusDidChange:(BOOL)isConnected;
- (void)shouldPresentCastIcon:(BOOL)didDetect;
- (void)didDiscoverCastDevice:(KRouterInfo *)info;
- (void)didRemoveCastDevice:(KRouterInfo *)info;

@end

@interface KRouterManager : NSObject

/**
 *  Whehter we are automatically adding the toolbar.
 */
@property(nonatomic) BOOL manageToolbar;

/**
 *  Whether or not we are attempting reconnect.
 */
@property(nonatomic) BOOL isReconnecting;

/**
 *  The last played content identifier.
 */
@property(nonatomic) NSString *lastContentID;

/**
 *  The last known playback position of the last played content.
 */
@property(nonatomic) NSTimeInterval lastPosition;

/*
*  The delegate for this object.
*/
@property(nonatomic, weak) id<KRouterManagerDelegate> delegateOrg;

/**
 *  Enable basic logging of all GCKLogger messages to the console.
 */
- (void)enableLogging;

@end
