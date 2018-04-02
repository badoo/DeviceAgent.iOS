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

@class NSArray, NSDictionary, NSNumber, NSString, NSURL, NSUUID, XCAccessibilityElement, XCDeviceEvent, XCSynthesizedEventRecord;

@class XCTSerializedTransportWrapper;
@class XCElementSnapshot;
@class NSXPCListenerEndpoint;

@protocol XCTestManager_ManagerInterface
- (void)_XCT_enableFauxCollectionViewCells:(void (^)(BOOL, NSError *))arg1;
- (void)_XCT_exchangeProtocolVersion:(NSUInteger)arg1 reply:(void (^)(NSUInteger))arg2;
- (void)_XCT_fetchAttributes:(NSArray *)arg1 forElement:(XCAccessibilityElement *)arg2 reply:(void (^)(NSDictionary *, NSError *))arg3;
- (void)_XCT_fetchAttributesForElement:(XCAccessibilityElement *)arg1 attributes:(NSArray *)arg2 reply:(void (^)(NSDictionary *, NSError *))arg3;
- (void)_XCT_fetchParameterizedAttribute:(NSString *)arg1 forElement:(XCAccessibilityElement *)arg2 parameter:(id)arg3 reply:(void (^)(id, NSError *))arg4;
- (void)_XCT_fetchParameterizedAttributeForElement:(XCAccessibilityElement *)arg1 attributes:(NSNumber *)arg2 parameter:(id)arg3 reply:(void (^)(id, NSError *))arg4;
- (void)_XCT_getDeviceOrientationWithCompletion:(void (^)(NSNumber *, NSError *))arg1;
- (void)_XCT_injectAssistantRecognitionStrings:(NSArray *)arg1 completion:(void (^)(BOOL, NSError *))arg2;
- (void)_XCT_injectVoiceRecognitionAudioInputPaths:(NSArray *)arg1 completion:(void (^)(BOOL, NSError *))arg2;
- (void)_XCT_launchApplicationWithBundleID:(NSString *)arg1 arguments:(NSArray *)arg2 environment:(NSDictionary *)arg3 completion:(void (^)(NSError *))arg4;
- (void)_XCT_loadAccessibilityWithTimeout:(double)arg1 reply:(void (^)(BOOL, NSError *))arg2;
- (void)_XCT_performAccessibilityAction:(NSInteger)arg1 onElement:(XCAccessibilityElement *)arg2 withValue:(id)arg3 reply:(void (^)(NSError *))arg4;
- (void)_XCT_performDeviceEvent:(XCDeviceEvent *)arg1 completion:(void (^)(NSError *))arg2;
- (void)_XCT_registerForAccessibilityNotification:(NSInteger)arg1 reply:(void (^)(NSNumber *, NSError *))arg2;
- (void)_XCT_requestBackgroundAssertionForPID:(NSInteger)arg1 reply:(void (^)(BOOL))arg2;
- (void)_XCT_requestBackgroundAssertionWithReply:(void (^)(void))arg1;
- (void)_XCT_requestBundleIDForPID:(NSInteger)arg1 reply:(void (^)(NSString *, NSError *))arg2;
- (void)_XCT_requestDTServiceHubConnectionWithReply:(void (^)(NSXPCListenerEndpoint *, NSError *))arg1;
- (void)_XCT_requestElementAtPoint:(CGPoint)arg1 reply:(void (^)(XCAccessibilityElement *, NSError *))arg2;
- (void)_XCT_requestEndpointForTestTargetWithPID:(NSInteger)arg1 preferredBackendPath:(NSString *)arg2 reply:(void (^)(NSXPCListenerEndpoint *, NSError *))arg3;
- (void)_XCT_requestScreenshotOfScreenWithID:(NSUInteger)arg1 withRect:(CGRect)arg2 uti:(NSString *)arg3 compressionQuality:(double)arg4 withReply:(void (^)(NSData *, NSError *))arg5;
- (void)_XCT_requestScreenshotOfScreenWithID:(NSUInteger)arg1 withRect:(CGRect)arg2 withReply:(void (^)(NSData *, NSError *))arg3;
- (void)_XCT_requestScreenshotWithReply:(void (^)(NSData *, NSError *))arg1;
- (void)_XCT_requestSerializedTransportWrapperForIDESessionWithIdentifier:(NSUUID *)arg1 reply:(void (^)(XCTSerializedTransportWrapper *))arg2;
- (void)_XCT_requestSiriEnabledStatus:(void (^)(BOOL, NSError *))arg1;
- (void)_XCT_requestSnapshotForElement:(XCAccessibilityElement *)arg1 attributes:(NSArray *)arg2 parameters:(NSDictionary *)arg3 reply:(void (^)(XCElementSnapshot *, NSError *))arg4;
- (void)_XCT_requestSocketForSessionIdentifier:(NSUUID *)arg1 reply:(void (^)(NSFileHandle *))arg2;
- (void)_XCT_sendString:(NSString *)arg1 maximumFrequency:(NSUInteger)arg2 completion:(void (^)(NSError *))arg3;
- (void)_XCT_setAXTimeout:(double)arg1 reply:(void (^)(NSInteger))arg2;
- (void)_XCT_setAttribute:(NSNumber *)arg1 value:(id)arg2 element:(XCAccessibilityElement *)arg3 reply:(void (^)(BOOL, NSError *))arg4;
- (void)_XCT_setLocalizableStringsDataGatheringEnabled:(BOOL)arg1 reply:(void (^)(BOOL, NSError *))arg2;
- (void)_XCT_snapshotForElement:(XCAccessibilityElement *)arg1 attributes:(NSArray *)arg2 parameters:(NSDictionary *)arg3 reply:(void (^)(XCElementSnapshot *, NSError *))arg4;
- (void)_XCT_startMonitoringApplicationWithBundleID:(NSString *)arg1;
- (void)_XCT_startSiriUIRequestWithAudioFileURL:(NSURL *)arg1 completion:(void (^)(BOOL, NSError *))arg2;
- (void)_XCT_startSiriUIRequestWithText:(NSString *)arg1 completion:(void (^)(BOOL, NSError *))arg2;
- (void)_XCT_synthesizeEvent:(XCSynthesizedEventRecord *)arg1 completion:(void (^)(NSError *))arg2;
- (void)_XCT_terminateApplicationWithBundleID:(NSString *)arg1 completion:(void (^)(NSError *))arg2;
- (void)_XCT_unregisterForAccessibilityNotification:(NSInteger)arg1 withRegistrationToken:(NSNumber *)arg2 reply:(void (^)(NSError *))arg3;
- (void)_XCT_updateDeviceOrientation:(NSInteger)arg1 completion:(void (^)(NSError *))arg2;
@end

