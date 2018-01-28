//
//  FairPlayHandler.m
//  KALTURAPlayerSDK
//
//  Created by Noam Tamim on 22/02/2016.
//  Copyright © 2016 Kaltura. All rights reserved.
//

#import "KPFairPlayHandler.h"
#import "KPAssetBuilder.h"
#import "KPLog.h"
#import "NSString+Utilities.h"

NSString* const SKD_URL_SCHEME_NAME = @"skd";

NSString* const TAG = @"com.kaltura.playersdk.drm.fps";


NSString* const FAIRPLAY_LICENSE_WILL_LOAD = @"FAIRPLAY_LICENSE_WILL_LOAD";
NSString* const FAIRPLAY_LICENSE_LOADED = @"FAIRPLAY_LICENSE_LOADED";

@interface KPFairPlayHandler () <AVAssetResourceLoaderDelegate>
@property (nonatomic, copy) NSString* licenseUri;
@property (nonatomic, copy) KPAssetReadyCallback assetReadyCallback;
@property (nonatomic, copy) NSData* certificate;
@end

static dispatch_queue_t	globalNotificationQueue( void )
{
    static dispatch_queue_t globalQueue = 0;
    static dispatch_once_t getQueueOnce = 0;
    dispatch_once(&getQueueOnce, ^{
        globalQueue = dispatch_queue_create("fairplay notify queue", NULL);
    });
    return globalQueue;
}



@implementation KPFairPlayHandler

- (dispatch_queue_t)getDefaultQueue {
    return globalNotificationQueue();
}

-(void)setAssetParam:(NSString*)key toValue:(id)value {
    switch (key.attributeEnumFromString) {
        case fpsCertificate:
            // value is a base64-encoded string
            _certificate = [[NSData alloc] initWithBase64EncodedString:value options:0];
            break;
            
        default:
            KPLogWarn(@"Ignoring unknown asset param %@", key);
            break;
    }
}

-(instancetype)initWithAssetReadyCallback:(KPAssetReadyCallback)callback {
    self = [super init];
    if (self) {
        self.assetReadyCallback = callback;
    }
    return self;
}

-(void)setContentUrl:(NSString*)url {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:nil];
    
    [asset.resourceLoader setDelegate:self queue:globalNotificationQueue()];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _assetReadyCallback(asset);
    });
}

- (NSData *)getContentKeyAndLeaseExpiryfromKeyServerModuleWithRequest:(NSData *)requestBytes contentIdentifierHost:(NSString *)assetStr leaseExpiryDuration:(NSTimeInterval *)expiryDuration error:(NSError **)errorOut {
    
    NSString* licenseUri = _licenseUri;
    
    NSURL* reqUrl = [NSURL URLWithString:licenseUri];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:reqUrl];
    request.HTTPMethod=@"POST";
    request.HTTPBody=[requestBytes base64EncodedDataWithOptions:0];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    
    NSHTTPURLResponse* response = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:FAIRPLAY_LICENSE_WILL_LOAD object:nil];
    KPLogDebug(@"Sending license request");
    NSTimeInterval licenseResponseTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:errorOut];
    
    licenseResponseTime = [NSDate timeIntervalSinceReferenceDate] - licenseResponseTime;
    KPLogDebug(@"Received license response (%.3f)", licenseResponseTime);
    [[NSNotificationCenter defaultCenter] postNotificationName:FAIRPLAY_LICENSE_LOADED object:nil];
    
    if (!responseData) {
        KPLogError(@"No license response, error=%@", *errorOut);
        return nil;
    }
        
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:errorOut];
    if (!dict) {
        KPLogError(@"Invalid license response, error=%@", *errorOut);
        return nil;
    }
    
    NSString* errMessage = dict[@"message"];
    if (errMessage) {
        *errorOut = [NSError errorWithDomain:TAG code:'CKCE' userInfo:@{@"ServerMessage": errMessage}];
        KPLogError(@"Error message from license server: %@", errMessage);
        return nil;
    }
    NSString* ckc = dict[@"ckc"];
    NSString* expiry = dict[@"expiry"];
    
    if (!ckc) {
        *errorOut = [NSError errorWithDomain:TAG code:'NCKC' userInfo:nil];
        KPLogError(@"No CKC in license response");
        return nil;
    }

    NSData* ckcData = [[NSData alloc] initWithBase64EncodedString:ckc options:0];
    
    if (!ckcData) {
        *errorOut = [NSError errorWithDomain:TAG code:'ICKC' userInfo:nil];
        KPLogError(@"Invalid CKC in license response");
        return nil;
    }
    
    *expiryDuration = [expiry floatValue];
    
    return ckcData;
}


- (NSString *)localKey:(NSString *)assetId {
    return [NSString stringWithFormat:@"FAIRPLAY2:%@", assetId];
}
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
    NSURL *url = loadingRequest.request.URL;
    NSError *error = nil;
    BOOL handled = NO;
    
    // Must be a non-standard URI scheme for AVFoundation to invoke your AVAssetResourceLoader delegate
    // for help in loading it.
    if (![[url scheme] isEqual:SKD_URL_SCHEME_NAME] && !self.forOfflineAssetId) {
        return NO;
    }
    
    // Use the SKD URL as assetId.
    NSString *assetId = url.host;
    
    if (self.forOfflineAssetId) {
        assetId = self.forOfflineAssetId;
    }
    
    // Wait for licenseUri and certificate, up to 5 seconds. In particular, the certificate might not be ready yet.
    // TODO: a better way of doing it is semaphores of some kind. 
    for (int i=0; i < 5*1000/50 && !(_certificate && _licenseUri); i++) {
        struct timespec delay;
        delay.tv_nsec = 50*1000*1000; // 50 millisec
        delay.tv_sec = 0;
        nanosleep(&delay, &delay);
    }
    
    if (!self.certificate) {
        KPLogError(@"Certificate is invalid or not set, can't continue");
        return NO;
    }
    
    NSDictionary *options = nil;
    if (self.forOffline) {
        
        if (loadingRequest.contentInformationRequest) {
            loadingRequest.contentInformationRequest.contentType = AVStreamingKeyDeliveryPersistentContentKeyType;
        }
        
        options = [NSDictionary dictionaryWithObjectsAndKeys:@YES, AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey, nil];
        
        
    }
    
    
    if (self.localStorage && !self.localListener) {
        NSData *cachedLicense = [self.localStorage load:[self localKey:assetId]];
        
        if (cachedLicense && dataRequest) {
            [dataRequest respondWithData:cachedLicense];
            [loadingRequest finishLoading];
            return YES;
        }
    }
    
    // Get SPC
    NSData *requestBytes = [loadingRequest streamingContentKeyRequestDataForApp:self.certificate
                                                      contentIdentifier:[assetId dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:options
                                                                  error:&error];
    
    NSTimeInterval expiryDuration = 0.0;
    
    if (error) {
        NSLog(@"%@",error);
    
    }
    
    // Send the SPC message to the Key Server.
    NSData *responseData = [self getContentKeyAndLeaseExpiryfromKeyServerModuleWithRequest:requestBytes
                                                             contentIdentifierHost:assetId
                                                               leaseExpiryDuration:&expiryDuration
                                                                             error:&error];

    
    // The Key Server returns the CK inside an encrypted Content Key Context (CKC) message in response to
    // the app’s SPC message.  This CKC message, containing the CK, was constructed from the SPC by a
    // Key Security Module in the Key Server’s software.
    if (responseData != nil) {
        
           if (self.forOffline) {
               
                NSError *error = nil;
                NSData *offlineData = [loadingRequest persistentContentKeyFromKeyVendorResponse:responseData options:nil error:&error];
               
               if (error) {
                   NSLog(@"%@",error);
                   if (self.localListener) {
                       [self.localListener localListenerNotOK:self.forOfflineListenerKey localKey:assetId];
                   }
               } else {
                   if (offlineData && self.localStorage) {
                       [self.localStorage save:[self localKey:assetId] value: offlineData];
                       [dataRequest respondWithData:offlineData];
                       if (self.localListener) {
                           [self.localListener localListenerOK:self.forOfflineListenerKey expiration:expiryDuration localKey:assetId];
                       }
                   }
               }
               
            
           } else {
        
        // Provide the CKC message (containing the CK) to the loading request.
               [dataRequest respondWithData:responseData];
           }
        
//        // Get the CK expiration time from the CKC. This is used to enforce the expiration of the CK.
//        if (expiryDuration != 0.0) {
//            
//            AVAssetResourceLoadingContentInformationRequest *infoRequest = loadingRequest.contentInformationRequest;
//            if (infoRequest) {
//                
//                // Set the date at which a renewal should be triggered.
//                // Before you finish loading an AVAssetResourceLoadingRequest, if the resource
//                // is prone to expiry you should set the value of this property to the date at
//                // which a renewal should be triggered. This value should be set sufficiently
//                // early enough to allow an AVAssetResourceRenewalRequest, delivered to your
//                // delegate via -resourceLoader:shouldWaitForRenewalOfRequestedResource:, to
//                // finish before the actual expiry time. Otherwise media playback may fail.
//                infoRequest.renewalDate = [NSDate dateWithTimeIntervalSinceNow:expiryDuration];
//                
//                infoRequest.contentType = @"application/octet-stream";
//                infoRequest.contentLength = responseData.length;
//                infoRequest.byteRangeAccessSupported = NO;
//            }
//        }
        [loadingRequest finishLoading]; // Treat the processing of the request as complete.
    }
    else {
        [loadingRequest finishLoadingWithError:error];
        
        if (self.localListener) {
            [self.localListener localListenerNotOK:self.forOfflineListenerKey localKey:assetId];
        }
    }
    
    handled = YES;	// Request has been handled regardless of whether server returned an error.
    
    return handled;
}


/* -----------------------------------------------------------------------------
 **
 ** resourceLoader: shouldWaitForRenewalOfRequestedResource:
 **
 ** Delegates receive this message when assistance is required of the application
 ** to renew a resource previously loaded by
 ** resourceLoader:shouldWaitForLoadingOfRequestedResource:. For example, this
 ** method is invoked to renew decryption keys that require renewal, as indicated
 ** in a response to a prior invocation of
 ** resourceLoader:shouldWaitForLoadingOfRequestedResource:. If the result is
 ** YES, the resource loader expects invocation, either subsequently or
 ** immediately, of either -[AVAssetResourceRenewalRequest finishLoading] or
 ** -[AVAssetResourceRenewalRequest finishLoadingWithError:]. If you intend to
 ** finish loading the resource after your handling of this message returns, you
 ** must retain the instance of AVAssetResourceRenewalRequest until after loading
 ** is finished. If the result is NO, the resource loader treats the loading of
 ** the resource as having failed. Note that if the delegate's implementation of
 ** -resourceLoader:shouldWaitForRenewalOfRequestedResource: returns YES without
 ** finishing the loading request immediately, it may be invoked again with
 ** another loading request before the prior request is finished; therefore in
 ** such cases the delegate should be prepared to manage multiple loading
 ** requests.
 **
 ** -------------------------------------------------------------------------- */

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
    return [self resourceLoader:resourceLoader shouldWaitForLoadingOfRequestedResource:renewalRequest];
}

@end
