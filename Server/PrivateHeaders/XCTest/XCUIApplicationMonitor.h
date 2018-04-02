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

#import "XCTUIApplicationMonitor-Protocol.h"
#import "XCUIApplicationProcessTracker-Protocol.h"

@class NSMutableDictionary, NSMutableSet, NSString, XCUIApplicationImplDepot, XCUIApplicationRegistry;

@interface XCUIApplicationMonitor : NSObject <XCTUIApplicationMonitor, XCUIApplicationProcessTracker>
{
    XCUIApplicationRegistry *_applicationRegistry;
    NSObject<OS_dispatch_queue> *_queue;
    XCUIApplicationImplDepot *_applicationImplDepot;
    NSMutableSet *_trackedBundleIDs;
    NSMutableDictionary *_applicationProcessesForPID;
    NSMutableDictionary *_applicationProcessesForToken;
    NSMutableSet *_launchedApplications;
}

@property(readonly, copy) XCUIApplicationImplDepot *applicationImplDepot;
@property(readonly, copy) NSMutableDictionary *applicationProcessesForPID;
@property(readonly, copy) NSMutableDictionary *applicationProcessesForToken;
@property(readonly) XCUIApplicationRegistry *applicationRegistry;
@property(readonly, copy) NSMutableSet *launchedApplications;
@property(retain) NSObject<OS_dispatch_queue> *queue;
@property(readonly, copy) NSMutableSet *trackedBundleIDs;

+ (id)sharedMonitor;
- (id)_appFromSet:(id)arg1 thatTransitionedToNotRunningDuringTimeInterval:(double)arg2;
- (void)_beginMonitoringApplication:(id)arg1;
- (BOOL)_isTrackingBundleID:(id)arg1;
- (void)_setIsTrackingForBundleID:(id)arg1;
- (void)_terminateApplicationProcess:(id)arg1;
- (void)_waitForCrashReportOrCleanExitStatusOfApp:(id)arg1;
- (void)acquireBackgroundAssertionForPID:(NSInteger)arg1 reply:(CDUnknownBlockType)arg2;
- (id)applicationImplementationForApplicationAtPath:(id)arg1 bundleID:(id)arg2;
- (id)applicationProcessWithPID:(NSInteger)arg1;
- (id)applicationProcessWithToken:(id)arg1;
- (void)applicationWithBundleID:(id)arg1 didUpdatePID:(NSInteger)arg2 state:(NSUInteger)arg3;
- (void)crashInProcessWithBundleID:(id)arg1 path:(id)arg2 pid:(NSInteger)arg3 symbol:(id)arg4;
- (void)launchRequestedForApplicationProcess:(id)arg1;
- (id)monitoredApplicationWithProcessIdentifier:(NSInteger)arg1;
- (void)processWithToken:(id)arg1 exitedWithStatus:(NSInteger)arg2;
- (void)requestAutomationSessionForTestTargetWithPID:(NSInteger)arg1 reply:(CDUnknownBlockType)arg2;
- (void)setApplicationProcess:(id)arg1 forPID:(NSInteger)arg2;
- (void)setApplicationProcess:(id)arg1 forToken:(id)arg2;
- (void)stopTrackingProcessWithToken:(id)arg1;
- (void)terminateApplicationProcess:(id)arg1 withToken:(id)arg2;
- (void)terminationTrackedForApplicationProcess:(id)arg1;
- (void)updatedApplicationStateSnapshot:(id)arg1;
- (void)waitForUnrequestedTerminationOfLaunchedApplicationsWithTimeout:(double)arg1;


@end

