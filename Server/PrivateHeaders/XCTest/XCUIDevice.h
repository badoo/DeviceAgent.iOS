// class-dump results processed by bin/class-dump/dump.rb
//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <XCTest/XCUIElementTypes.h>
#import "CDStructures.h"
@protocol OS_dispatch_queue;
@protocol OS_xpc_object;

#import <UIKit/UIDevice.h>

@class XCUISiriService;

@interface XCUIDevice : NSObject
{
}

@property(nonatomic) UIDeviceOrientation orientation;
@property(readonly) XCUISiriService *siriService;

+ (XCUIDevice *)sharedDevice;
- (void)_dispatchEventWithPage:(NSUInteger)arg1 usage:(NSUInteger)arg2 duration:(double)arg3;
- (void)_silentPressButton:(NSInteger)arg1;
- (void)holdHomeButtonForDuration:(double)arg1;
- (void)pressButton:(NSInteger)arg1;
- (void)pressLockButton;

@end

