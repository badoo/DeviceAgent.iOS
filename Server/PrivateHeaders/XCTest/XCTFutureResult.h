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

#import "XCTResult.h"

@class XCTPromise, XCTWaiter;

@interface XCTFutureResult : XCTResult
{
    BOOL _hasWaited;
    BOOL _hasFinished;
    double _deadline;
    XCTPromise *_promise;
    XCTWaiter *_waiter;
    NSObject<OS_dispatch_queue> *_queue;
}

@property(readonly) double deadline;
@property BOOL hasFinished;
@property BOOL hasWaited;
@property(readonly) XCTPromise *promise;
@property(readonly) NSObject<OS_dispatch_queue> *queue;
@property(readonly) XCTWaiter *waiter;

- (void)_waitForFulfillment;
- (id)error;
- (id)initWithTimeout:(double)arg1 description:(id)arg2;
- (void)setError:(id)arg1;
- (void)setValue:(id)arg1;
- (id)value;

@end

