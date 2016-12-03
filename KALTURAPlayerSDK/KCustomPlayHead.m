//
//  KCustomPlayHead.m
//  Pods
//
//  Created by Carlo Luis Martinez Bation on 29/11/16.
//
//

#import "IMAHandler.h"
#import "KCustomPlayHead.h"
#import <AVFoundation/AVFoundation.h>
@implementation KCustomPlayHead
@synthesize currentTime;

// Return current time of the video player set
- (NSTimeInterval)currentTime {
    if (self.player) {
        Float64 dur = CMTimeGetSeconds([self.player currentTime]);
        if (isnan(dur))
            return -1;
        return dur;
        
    }
    return -1;
}
@end
