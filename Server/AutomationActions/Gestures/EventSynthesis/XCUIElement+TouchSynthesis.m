// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#import "XCUIElement+TouchSynthesis.h"
#import "Touch.h"
#import "Coordinate.h"
#import "Testmanagerd.h"
#import "CBXTouchEvent.h"
#import "ThreadUtils.h"
#import "XCUICoordinate.h"

@implementation XCUIElement (TouchSynthesis)

- (NSError *)synthesizeTapEvent
{
    CGPoint point = [[self hitPointCoordinate] screenPoint];
    NSArray<Coordinate *> *coords = @[[Coordinate fromRaw:point]];
    Touch *touch = [[Touch alloc] init];
    CBXTouchEvent *touchEvent = [touch cbxEventWithCoordinates:coords];

    __block NSError *touchEventError;

    [ThreadUtils runSync:^(BOOL *setToTrueWhenDone) {
        [[Testmanagerd_EventSynthesis get] _XCT_synthesizeEvent:touchEvent.event
                                                     completion:^(NSError *e) {
            touchEventError = e;
            *setToTrueWhenDone = YES;
        }];
    }];

    return touchEventError;
}

@end
