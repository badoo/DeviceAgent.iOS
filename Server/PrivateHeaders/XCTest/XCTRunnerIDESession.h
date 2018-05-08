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

#import "XCTTestRunSessionDelegate-Protocol.h"
#import "XCTestDriverInterface-Protocol.h"
#import "XCTestObservation-Protocol.h"
#import "XCUIXcodeApplicationManaging-Protocol.h"

@class DTXConnection, NSString, XCTestRun;


@protocol XCTestManager_IDEInterface;
@protocol XCTUIApplicationMonitor;

@interface XCTRunnerIDESession : NSObject <XCTestObservation, XCTestDriverInterface, XCTTestRunSessionDelegate, XCUIXcodeApplicationManaging>
{
    NSObject<OS_dispatch_queue> *_queue;
    DTXConnection *_IDEConnection;
    id <XCTestManager_IDEInterface> _IDEProxy;
    NSInteger _IDEProtocolVersion;
    id <XCTUIApplicationMonitor> _applicationMonitor;
    XCTestRun *_currentTestRun;
    CDUnknownBlockType _readinessReply;
}

@property(retain) DTXConnection *IDEConnection;
@property NSInteger IDEProtocolVersion;
@property(retain) id <XCTestManager_IDEInterface> IDEProxy;
@property __weak id <XCTUIApplicationMonitor> applicationMonitor;
@property(retain) NSObject<OS_dispatch_queue> *queue;
@property(copy) CDUnknownBlockType readinessReply;
@property(readonly) BOOL reportsCrashes;
@property(readonly) BOOL supportsVariableScreenshotFormats;

+ (void)setSharedSession:(id)arg1;
+ (id)sharedSession;
+ (id)sharedSessionQueue;
+ (id)transportForLocalPath:(id)arg1 error:(id *)arg2;
- (id)_IDE_processWithBundleID:(id)arg1 path:(id)arg2 pid:(id)arg3 crashedUnderSymbol:(id)arg4;
- (id)_IDE_processWithToken:(id)arg1 exitedWithStatus:(id)arg2;
- (id)_IDE_startExecutingTestPlanWithProtocolVersion:(id)arg1;
- (id)_IDE_stopTrackingProcessWithToken:(id)arg1;
- (void)_testCase:(id)arg1 didFinishActivity:(id)arg2;
- (void)_testCase:(id)arg1 didMeasureValues:(id)arg2 forPerformanceMetricID:(id)arg3 name:(id)arg4 unitsOfMeasurement:(id)arg5 baselineName:(id)arg6 baselineAverage:(id)arg7 maxPercentRegression:(id)arg8 maxPercentRelativeStandardDeviation:(id)arg9 maxRegression:(id)arg10 maxStandardDeviation:(id)arg11 file:(id)arg12 line:(NSUInteger)arg13;
- (void)_testCase:(id)arg1 willStartActivity:(id)arg2;
- (id)initWithTransport:(id)arg1;
- (void)launchProcessWithPath:(id)arg1 bundleID:(id)arg2 arguments:(id)arg3 environmentVariables:(id)arg4 completion:(CDUnknownBlockType)arg5;
- (void)logDebugMessage:(id)arg1;
- (void)reportSelfDiagnosisIssue:(id)arg1 description:(id)arg2;
- (void)reportStallOnMainThreadInTestCase:(id)arg1 method:(id)arg2 file:(id)arg3 line:(NSUInteger)arg4;
- (void)requestLaunchProgressForProcessWithToken:(id)arg1 completion:(CDUnknownBlockType)arg2;
- (void)requestReadinessForTesting:(CDUnknownBlockType)arg1;
- (void)terminateProcessWithToken:(id)arg1 completion:(CDUnknownBlockType)arg2;
- (void)testBundleDidFinish:(id)arg1;
- (void)testBundleWillStart:(id)arg1;
- (void)testCase:(id)arg1 didFailWithDescription:(id)arg2 inFile:(id)arg3 atLine:(NSUInteger)arg4;
- (void)testCaseDidFinish:(id)arg1;
- (void)testCaseWillStart:(id)arg1;
- (void)testRunSession:(id)arg1 initializationForUITestingDidFailWithError:(id)arg2;
- (void)testRunSessionDidBeginExecutingTestPlan:(id)arg1;
- (void)testRunSessionDidBeginInitializingForUITesting:(id)arg1;
- (void)testRunSessionDidFinishExecutingTestPlan:(id)arg1 reply:(CDUnknownBlockType)arg2;
- (void)testSuite:(id)arg1 didFailWithDescription:(id)arg2 inFile:(id)arg3 atLine:(NSUInteger)arg4;
- (void)testSuiteDidFinish:(id)arg1;
- (void)testSuiteWillStart:(id)arg1;


@end
