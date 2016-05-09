//
//  KRouterManager.m
//  KALTURAPlayerSDK
//
//  Created by Eliza Sapir on 04/05/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "KRouterManager_Private.h"
#import "KPLog.h"

/**
 *  Constant for the storyboard ID for the device table view controller.
 */
static NSString * const kDeviceTableViewController = @"deviceTableViewController";

/**
 *  Constant for the storyboard ID for the expanded view Cast controller.
 */
NSString * const kCastViewController = @"castViewController";

@protocol KRouterManagerDelegateTemp <NSObject>

///TODO:: delete!
/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(id<KPGCDevice>)device;

/**
 *  Called when the device disconnects.
 */
- (void)didDisconnect;

/**
 * Called when Cast devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork;

/**
 * Called when Cast device is connecting
 */
- (void)castConnectingToDevice;

/**
 * Called when a request to load media has completed.
 */
- (void)didCompleteLoadWithSessionID:(NSInteger)sessionID;

/**
 * Called when updated player status information is received.
 */
- (void)didUpdateStatus:(id<KPGCMediaControlChannel>)mediaControlChannel;

@end

///TODO:: delete KRouterManagerDelegateTemp
@interface KRouterManager() <KPGCDeviceScannerListener, KRouterManagerDelegateTemp>

@property(nonatomic, weak) id<KRouterManagerDelegateTemp> delegate;
@end

@implementation KRouterManager

# pragma mark - Acessors

- (KPGCMediaPlayerState)playerState {
    return _mediaControlChannel.mediaStatus.playerState;
}

- (KPGCMediaPlayerIdleReason)playerIdleReason{
    return _mediaControlChannel.mediaStatus.idleReason;
}

- (NSTimeInterval)streamDuration {
    return _mediaInformation.streamDuration;
}

- (NSTimeInterval)streamPosition {
    self.lastPosition = [_mediaControlChannel approximateStreamPosition];
    return self.lastPosition;
}

- (void)setPlaybackPercent:(float)newPercent {
    newPercent = MAX(MIN(1.0, newPercent), 0.0);
    
    NSTimeInterval newTime = newPercent * self.streamDuration;
    if (newTime > 0 )// && _deviceManager.applicationConnectionState == GCKConnectionStateConnected) {
        [self.mediaControlChannel seekToTimeInterval:newTime];
    //}
}


/**
 *  Set the application ID and initialise a scan.
 *
 *  @param applicationID Cast application ID
 */
- (void)setApplicationID:(NSString *)applicationID {
    _applicationID = applicationID;
    self.deviceScanner = [NSClassFromString(@"GCKDeviceScanner") new];
    
    // Always start a scan as soon as we have an application ID.
    KPLogChromeCast(@"Starting Scan");
    [self.deviceScanner addListener:self];
    [self.deviceScanner startScan];
}

# pragma mark - UI Management

- (void)dismissDeviceTable {
    //  [self.controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateCastIconButtonStates {
    //  if (self.deviceManager.applicationConnectionState == GCKConnectionStateConnected) {
    //    _castIconButton.status = CIBCastConnected;
    //  } else if (self.deviceManager.applicationConnectionState == GCKConnectionStateConnecting) {
    //    _castIconButton.status = CIBCastConnecting;
    //  } else if (self.deviceScanner.devices.count == 0) {
    //    _castIconButton.status = CIBCastUnavailable;
    //  } else {
    //    _castIconButton.status = CIBCastAvailable;
    // Show cast icon. If this is the first time the cast icon is appearing, show an overlay with
    // instructions highlighting the cast icon.
    //    if (self.controller) {
    //      [CastInstructionsViewController showIfFirstTimeOverViewController:self.controller];
    //    }
    //  }
    
    //  if (self.manageToolbar) {
    //    [self updateToolbarForViewController:self.controller];
    //  }
}

- (void)initControls {
    //  self.castIconButton = [CastIconBarButtonItem barButtonItemWithTarget:self
    //                                                              selector:@selector(chooseDevice:)];
    //  self.castMiniController = [[CastMiniController alloc] initWithDelegate:self];
}

- (void)displayCurrentlyPlayingMedia {
    //  if (self.controller) {
    //    CastViewController *vc =
    //        [_storyboard instantiateViewControllerWithIdentifier:kCastViewController];
    //    [vc setMediaToPlay:self.mediaInformation];
    //    [self.controller.navigationController pushViewController:vc animated:YES];
    //  }
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(id<KPGCDeviceManager>)deviceManager {
    //  BOOL appMatch = [deviceManager.applicationMetadata.applicationID isEqualToString:_applicationID];
    //  if (!_isReconnecting || !appMatch) {
    //    // Explicit connect request when a different app (or none) is Casting.
    [self.deviceManager launchApplication:_applicationID];
    //  } else if (_isReconnecting &&
    //             deviceManager.applicationMetadata.applicationID &&
    //             !appMatch) {
    //    // Implicit reconnect but an application other than ours is playing, disconnect.
    //    [deviceManager disconnect];
    //  } else {
    //    // Reconnect, or our app is playing. Attempt to join our session if there.
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    NSString* lastSessionID = [defaults valueForKey:@"lastSessionID"];
    //    [self.deviceManager joinApplication:_applicationID sessionID:lastSessionID];
    //  }
    //  [self updateCastIconButtonStates];
}

- (void)deviceManager:(id<KPGCDeviceManager>)deviceManager
didConnectToCastApplication:(id<KPGCApplicationMetadata>)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
    self.mediaControlChannel = [[NSClassFromString(@"GCKMediaControlChannel") alloc] init];
    self.mediaControlChannel.delegate = self;
    [self.deviceManager addChannel:self.mediaControlChannel];
    [self.mediaControlChannel requestStatus];
    
    //  [self updateCastIconButtonStates];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castApplicationConnected"
                                                        object:self];
    
    if ([_delegate respondsToSelector:@selector(didConnectToDevice:)]) {
        [_delegate didConnectToDevice:deviceManager.device];
    }
    
    self.isReconnecting = NO;
    // Store sessionID in case of restart
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sessionID forKey:@"lastSessionID"];
    [defaults setObject:deviceManager.device.deviceID forKey:@"lastDeviceID"];
    [defaults synchronize];
}

- (void)deviceManager:(id<KPGCDeviceManager>)deviceManager
volumeDidChangeToLevel:(float)volumeLevel
              isMuted:(BOOL)isMuted {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castVolumeChanged" object:self];
}

- (void)deviceManager:(id<KPGCDeviceManager>)deviceManager
didFailToConnectToApplicationWithError:(NSError *)error {
    [self updateCastIconButtonStates];
}

- (void)deviceManager:(id<KPGCDeviceManager>)deviceManager
didFailToConnectWithError:(id<KPGCError>)error {
    [self clearPreviousSession];
    
    [self updateCastIconButtonStates];
}

- (void)deviceManager:(id<KPGCDeviceManager>)deviceManager didDisconnectWithError:(id<KPGCError>)error {
    KPLogChromeCast(@"Received notification that device disconnected");
    
    if (!error || (
                   error.code == KPGCErrorCodeDeviceAuthenticationFailure ||
                   error.code == KPGCErrorCodeDisconnected ||
                   error.code == KPGCErrorCodeApplicationNotFound)) {
        [self clearPreviousSession];
    }
    
    _mediaInformation = nil;
    [self updateCastIconButtonStates];
    
    if ([_delegate respondsToSelector:@selector(didDisconnect)]) {
        [_delegate didDisconnect];
    }
}

- (void)deviceManager:(id<KPGCDeviceManager>)deviceManager
didDisconnectFromApplicationWithError:(NSError *)error {
    KPLogChromeCast(@"Received notification that app disconnected");
    
    if (error) {
        KPLogChromeCast(@"Application disconnected with error: %@", error);
    }
    
    // If we've lost the app connection, tear down the device connection.
    [deviceManager disconnect];
}

# pragma mark - Reconnection

- (void)clearPreviousSession {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"lastDeviceID"];
    [defaults synchronize];
}

- (NSTimeInterval)streamPositionForPreviouslyCastMedia:(NSString *)contentID {
    if ([contentID isEqualToString:_lastContentID]) {
        return _lastPosition;
    }
    return 0;
}

#pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(id<KPGCDevice>)device {
    KPLogChromeCast(@"device found - %@", device.friendlyName);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* lastDeviceID = [defaults objectForKey:@"lastDeviceID"];
    if(lastDeviceID != nil && [[device deviceID] isEqualToString:lastDeviceID]){
        self.isReconnecting = YES;
        [self connectToDevice:device];
    }
    
    if ([_delegate respondsToSelector:@selector(didDiscoverDeviceOnNetwork)]) {
        [_delegate didDiscoverDeviceOnNetwork];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castScanStatusUpdated" object:self];
    [self updateCastIconButtonStates];
}

- (void)deviceDidGoOffline:(id<KPGCDevice>)device {
    KPLogChromeCast(@"device went offline - %@", device.friendlyName);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castScanStatusUpdated" object:self];
    [self updateCastIconButtonStates];
}

- (void)deviceDidChange:(id<KPGCDevice>)device {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castScanStatusUpdated" object:self];
}

#pragma mark - GCKMediaControlChannelDelegate methods

- (void)mediaControlChannelDidUpdateStatus:(id<KPGCMediaControlChannel>)mediaControlChannel {
    KPLogChromeCast(@"Media control channel status changed");
    _mediaInformation = mediaControlChannel.mediaStatus.mediaInformation;
    self.lastContentID = _mediaInformation.contentID;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castMediaStatusChange" object:self];
    
    if ([_delegate respondsToSelector:@selector(didUpdateStatus:)]) {
        [_delegate didUpdateStatus:mediaControlChannel];
    }
    
    //    [self updateCastIconButtonStates];
}

- (void)mediaControlChannelDidUpdateMetadata:(id<KPGCMediaControlChannel>)mediaControlChannel {
    KPLogChromeCast(@"Media control channel metadata changed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castMediaStatusChange" object:self];
}

- (void)mediaControlChannel:(id<KPGCMediaControlChannel>)mediaControlChannel didCompleteLoadWithSessionID:(NSInteger)sessionID {
    /// @todo maybe better use delegate
    KPLogChromeCast(@"Media control channel metadata changed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castApplicationCompleteLoadWithSessionID"
                                                        object:@{@"sessionID":@(sessionID)}];
    
    if ([_delegate respondsToSelector:@selector(didCompleteLoadWithSessionID:)]) {
        [_delegate didCompleteLoadWithSessionID:sessionID];
    }
}

# pragma mark - Device & Media Management

- (void)connectToDevice:(id<KPGCDevice>)device {
    KPLogChromeCast(@"Connecting to device address: %@:%d", device.ipAddress, (unsigned int)device.servicePort);
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appIdentifier = [info objectForKey:@"CFBundleIdentifier"];
    self.deviceManager =
    [[NSClassFromString(@"GCKDeviceManager") alloc] initWithDevice:device clientPackageName:appIdentifier];
    self.deviceManager.delegate = self;
    [self.deviceManager connect];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"castConnectingToDevice"
                                                        object:nil];
    
    if ([_delegate respondsToSelector:@selector(castConnectingToDevice)]) {
        [_delegate castConnectingToDevice];
    }
}

- (BOOL)loadMedia:(id<KPGCMediaInformation>)media
        startTime:(NSTimeInterval)startTime
         autoPlay:(BOOL)autoPlay {
    //  if (!self.deviceManager || self.deviceManager.connectionState != GCKConnectionStateConnected ) {
    //    return NO;
    //}
    
    _mediaInformation = media;
    [self.mediaControlChannel loadMedia:media autoplay:autoPlay playPosition:startTime];
    
    return YES;
}

//- (void)decorateViewController:(UIViewController *)controller {
//  self.controller = controller;
//  if (_controller) {
//    self.manageToolbar = false;
//    _controller.navigationItem.rightBarButtonItem = _castIconButton;
//    }
//  }
//
//- (void)updateToolbarForViewController:(UIViewController *)viewController {
//  self.manageToolbar = YES;
//  [self.castMiniController updateToolbarStateIn:viewController
//                            forMediaInformation:self.mediaInformation
//                                    playerState:self.playerState];
//    }

#pragma mark - GCKLoggerDelegate implementation

- (void)enableLogging {
    [[NSClassFromString(@"GCKLogger") sharedInstance] setDelegate:self];
}

- (void)logFromFunction:(const char *)function message:(NSString *)message {
    // Send SDK’s log messages directly to the console, as an example.
    KPLogChromeCast(@"%s  %@", function, message);
}

@end
