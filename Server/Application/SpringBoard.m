/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "SpringBoard.h"
#import "CBX-XCTest-Umbrella.h"
#import "XCTest+CBXAdditions.h"
#import "Application.h"
#import "SpringBoardAlert.h"
#import "SpringBoardAlerts.h"
#import "GestureFactory.h"
#import "CBXException.h"
#import <UIKit/UIKit.h>
#import "CBXConstants.h"
#import "XCTest+CBXAdditions.h"
#import "CBXMachClock.h"
#import "XCUIElement+TouchSynthesis.h"

typedef enum : NSUInteger {
    SpringBoardAlertHandlerIgnoringAlerts = 0,
    SpringBoardAlertHandlerNoAlert,
    SpringBoardAlertHandlerDismissedAlert,
    SpringBoardAlertHandlerUnrecognizedAlert,
    SpringBoardAlertHandlerFailed
} SpringBoardAlertHandlerResult;

@interface SpringBoard ()

- (BOOL)shouldDismissAlertsAutomatically;
- (SpringBoardAlertHandlerResult)handleAlert;

@end

@implementation SpringBoard

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier {
    self = [super initWithBundleIdentifier:bundleIdentifier];
    if (self) {
        _shouldDismissAlertsAutomatically = NO;
    }
    return self;
}

+ (instancetype)application {
    static SpringBoard *_springBoard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _springBoard = [[SpringBoard alloc]
                        initWithBundleIdentifier:@"com.apple.springboard"];
    });
    return _springBoard;
}

- (XCUIElement *)queryForAlert {
    @synchronized (self) {
        XCUIElement *alert = nil;
            
        // Collect timing info
        NSTimeInterval startTime = [[CBXMachClock sharedClock] absoluteTime];
        
        XCUIElementQuery *query = [self descendantsMatchingType:XCUIElementTypeAlert];
        NSArray <XCUIElement *> *elements = [query allElementsBoundByIndex];

        if ([elements count] != 0) {
            alert = elements[0];
        }

        NSTimeInterval elapsedSeconds = [[CBXMachClock sharedClock] absoluteTime] - startTime;
        DDLogDebug(@"SpringBoard.queryForAlert took %@ seconds", @(elapsedSeconds));

        return alert;
    }
}

- (void)handleAlertsOrThrow {

    @synchronized (self) {

        if (![self shouldDismissAlertsAutomatically]) { return; }

        [self autodismissAlertWithPreferences:@[@"Cancel", @"OK"]];
    }
}

- (NSString *)autodismissAlertWithPreferences: (NSArray<NSString *> *) preferableButtons {
    XCUIApplication *app = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    XCUIElementQuery *alerts = [app alerts];

    if ([alerts count] == 0) {
        return @"Alert is not found. Skip dismiss alert button action.";
    }
    else {
        DDLogDebug(@"Found alerts: '%lu'", (unsigned long)alerts.count);
    }

    XCUIElement *actualAlert = [alerts element];

    return [self autodismissAlert:actualAlert preferableButtons:preferableButtons];
}

- (NSString *)autodismissAlert: (XCUIElement *) alert preferableButtons: (NSArray<NSString *> *) preferableButtons {
    NSString *alertLabel = alert.label;
    DDLogDebug(@"Autodismiss the alert = '%@' using preferable buttons: '%@'",
               alertLabel, preferableButtons);

    for (NSString *preferableButton in preferableButtons) {
        XCUIElement *button = alert.buttons[preferableButton];
        if ([button exists]) {
            NSError *tapEventError = [button synthesizeTapEvent];
            if (tapEventError) {
                NSString *errorMessage = [NSString stringWithFormat:@"Failed to synthesize touch event. Error: '%@'",
                                          [tapEventError localizedDescription]];
                DDLogDebug(@"%@", errorMessage);
                return errorMessage;
            } else {
                DDLogDebug(@"Successfully synthesized touch event.");
                return [NSString stringWithFormat:@"Alert '%@' is found. Tap on the preferable button '%@'.",
                        alertLabel, preferableButton];
            }
        }
    }

    // INFO: Dismiss first button in case preferable button is not found
    XCUIElement *firstButton = alert.buttons.firstMatch;
    NSString *firstButtonLabel = firstButton.label;

    NSError *tapEventError = [firstButton synthesizeTapEvent];
    if (tapEventError) {
        NSString *errorMessage = [NSString stringWithFormat:@"Failed to synthesize touch event on element with label %@. Error: '%@'",
        firstButtonLabel, [tapEventError localizedDescription]];
        DDLogDebug(@"%@", errorMessage);
        return errorMessage;
    } else {
        return [NSString stringWithFormat:@"Alert '%@' is found without preferable buttons. Tap on the first button '%@'.",
                alertLabel, firstButtonLabel];
    }
}

- (XCUIElement *)findDismissButtonOnAlert: (XCUIElement *) alert marks: (NSArray *) marks {
    XCUIElement *button = nil;
    for (NSString *mark in marks) {
        button = alert.buttons[mark];

        // Resolve before asking if the button exists.
        [button cbx_resolve];

        if (button && button.exists) {
            return button;
        }
    }
    
    return button;
}

// If something goes wrong, SpringBoardAlertHandlerNoAlert is returned.
// This method is not protected by a lock!  It should only be called by
// handleAlertsOrThrow
- (SpringBoardAlertHandlerResult)handleAlert {

    XCUIElement *alert = [self queryForAlert];

    // There is not alert.
    if (!alert || !alert.exists) {
        return SpringBoardAlertHandlerNoAlert;
    }

    // .label is the title for English and German.  Hopefully for others too.
    NSString *title = alert.label;
    SpringBoardAlert *springBoardAlert;
    springBoardAlert = [[SpringBoardAlerts shared] alertMatchingTitle:title];

    // We don't know about this alert.
    if (!springBoardAlert) {
        return SpringBoardAlertHandlerUnrecognizedAlert;
    }

    XCUIElement *button = nil;
    NSArray *marks = springBoardAlert.defaultDismissButtonMarks;

    // Alert is now gone? It can happen...
    if (!alert.exists) {
        return SpringBoardAlertHandlerNoAlert;
    }
        
    button = [self findDismissButtonOnAlert: alert marks: marks];

    // A button with the expected title does not exist.
    // It probably changed after an iOS update.
    if (!button || !button.exists) {
        button = nil;
    }

    // Use the default accept/deny button, but only if we recognize this alert.
    if (!button) {

        if (!alert.exists) {
            return SpringBoardAlertHandlerNoAlert;
        }

        XCUIElementQuery *query = [alert descendantsMatchingType:XCUIElementTypeButton];
        NSArray<XCUIElement *> *buttons = [query allElementsBoundByIndex];

        if ([buttons count] == 0) {
            return SpringBoardAlertHandlerNoAlert;
        }

        if (springBoardAlert.shouldAccept) {
            switch ([buttons count]) {

                case 1: {
                    // Single button alert
                    button = buttons[0];
                    break;
                }
                case 2: {
                    // Two button alert
                    button = buttons[1];
                    break;
                }
                case 3: {
                    // Three button alert
                    // Allow Location Always notification started popping this
                    // alert in iOS 11.
                    button = buttons[1];
                    break;
                }

                default: {
                    button = buttons.lastObject;
                    break;
                }

            }

        } else {
            button = buttons.firstObject;
        }
    }

    // Resolve before asking if the button exists.
    [button cbx_resolve];

    if (!button || !button.exists) {
        return SpringBoardAlertHandlerNoAlert;
    }
    @try {
        [button tap];
    } @catch (NSException *e) {
        DDLogError(@"Caught an exception '%@': '%@'.", [e name], [e reason]);
        return SpringBoardAlertHandlerFailed;
    }

    return SpringBoardAlertHandlerDismissedAlert;
}

- (SpringBoardDismissAlertResult)dismissAlertByTappingButtonWithTitle:(NSString *)title {
    @synchronized (self) {
        XCUIElement *alert = [self queryForAlert];

        if (!alert) {
            return SpringBoardDismissAlertNoAlert;
        } else {
            XCUIElement *button = alert.buttons[title];
            [button cbx_resolve];

            if (!button || !button.exists) {
                return SpringBoardDismissAlertNoMatchingButton;
            }

            [button tap];

            return SpringBoardDismissAlertDismissedAlert;
        }
    }
}

@end
