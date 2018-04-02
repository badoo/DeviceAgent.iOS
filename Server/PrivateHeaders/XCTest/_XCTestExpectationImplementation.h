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

@class NSArray, NSString;


@protocol XCTestExpectationDelegate;

@interface _XCTestExpectationImplementation : NSObject
{
    BOOL _fulfilled;
    NSString *_expectationDescription;
    id <XCTestExpectationDelegate> _delegate;
    BOOL _hasBeenWaitedOn;
    NSUInteger _expectedFulfillmentCount;
    NSUInteger _numberOfFulfillments;
    NSUInteger _creationToken;
    NSUInteger _fulfillmentToken;
    NSArray *_creationCallStackReturnAddresses;
    NSArray *_fulfillCallStackReturnAddresses;
    BOOL _inverted;
    BOOL _assertForOverFulfill;
    NSObject<OS_dispatch_queue> *_queue;
    NSObject<OS_dispatch_queue> *_delegateQueue;
}

@property BOOL assertForOverFulfill;
@property(copy) NSArray *creationCallStackReturnAddresses;
@property NSUInteger creationToken;
@property(retain) id <XCTestExpectationDelegate> delegate;
@property(readonly, nonatomic) NSObject<OS_dispatch_queue> *delegateQueue;
@property(copy) NSString *expectationDescription;
@property(nonatomic) NSUInteger expectedFulfillmentCount;
@property(copy) NSArray *fulfillCallStackReturnAddresses;
@property BOOL fulfilled;
@property NSUInteger fulfillmentToken;
@property BOOL hasBeenWaitedOn;
@property BOOL inverted;
@property(nonatomic) NSUInteger numberOfFulfillments;
@property(readonly, nonatomic) NSObject<OS_dispatch_queue> *queue;


@end

