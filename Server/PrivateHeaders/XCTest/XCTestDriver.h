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

#import "XCDebugLogDelegate-Protocol.h"
#import "XCTASDebugLogDelegate-Protocol.h"

@class NSMutableArray, NSString, XCTestConfiguration;

@interface XCTestDriver : NSObject <XCDebugLogDelegate, XCTASDebugLogDelegate>
{
    XCTestConfiguration *_testConfiguration;
    NSObject<OS_dispatch_queue> *_queue;
    NSMutableArray *_debugMessageBuffer;
    NSInteger _debugMessageBufferOverflow;
}

@property(retain) NSMutableArray *debugMessageBuffer;
@property NSInteger debugMessageBufferOverflow;
@property(retain) NSObject<OS_dispatch_queue> *queue;
@property(readonly) XCTestConfiguration *testConfiguration;

+ (double)IDEConnectionTimeout;
+ (id)sharedTestDriver;
- (void)_queue_flushDebugMessageBufferWithBlock:(CDUnknownBlockType)arg1;
- (id)_readyIDESession:(id *)arg1;
- (id)_transportForIDESession:(id *)arg1;
- (id)initWithTestConfiguration:(id)arg1;
- (void)logDebugMessage:(id)arg1;
- (void)logStartupInfo;
- (void)printBufferedDebugMessages;
- (void)reportStallOnMainThreadInTestCase:(id)arg1 method:(id)arg2 file:(id)arg3 line:(NSUInteger)arg4;
- (void)runTestConfiguration:(id)arg1 completionHandler:(CDUnknownBlockType)arg2;
- (void)runTestSuite:(id)arg1 completionHandler:(CDUnknownBlockType)arg2;
- (BOOL)runTestsAndReturnError:(id *)arg1;


@end
