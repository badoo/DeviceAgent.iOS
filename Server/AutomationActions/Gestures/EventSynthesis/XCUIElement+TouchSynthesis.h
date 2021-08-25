// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#import "XCUIElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface XCUIElement (TouchSynthesis)

/**
This is a workaround for cases on different iOS versions when trying to close abandoned alerts.
When trying to tap on an element (for example: a button - [button tap]), then sometimes on some iOS versions might get an error from XCTest.

Example of Xcode debug output:

    t =    16.42s Tap "Allow" Button
    t =    16.42s     Wait for com.apple.springboard to idle
    t =    16.43s     Find the "Allow" Button
    t =    16.45s     Check for interrupting elements affecting "Allow" Button
    ~/DeviceAgent.iOS/Server/Application/SpringBoard.m:117: error:
    [TestRunner testRunner] : Failed to get list of active applications: Accessibility error kAXErrorServerNotFound from AXUIElementCopyMultipleAttributeValues for 1102

This causes _XCTestCaseInterruptionException to be thrown, which in it's turn terminates DeviceAgent's test session.
In order to avoid exception, instead of using [element tap] method, synthesize event using coordinates of the element.
 */
- (NSError *)synthesizeTapEvent;

@end

NS_ASSUME_NONNULL_END
