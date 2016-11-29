//
//  KCustomPlayHead.h
//  Pods
//
//  Created by Carlo Luis Martinez Bation on 29/11/16.
//
//

#import <Foundation/Foundation.h>
@protocol IMAContentPlayhead;
@class AVPlayer;

@interface KCustomPlayHead : NSObject<IMAContentPlayhead>
@property(nonatomic, weak)AVPlayer *player;

@end
