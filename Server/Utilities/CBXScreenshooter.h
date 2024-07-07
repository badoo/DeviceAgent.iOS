// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#import "CBX-XCTest-Umbrella.h"
#import "XCTImage.h"

@protocol XCTMessagingRole_CapabilityExchange;

@interface CBXScreenshooter : NSObject
- (instancetype)initWithTestmanagerd:(id<XCTMessagingRole_CapabilityExchange>)testmanagerd
                           displayID:(NSInteger)displayID
                         compression:(double)compression
                      typeIdentifier:(NSString*)typeIdentifier;

- (XCTImage *)getScreenshot;

@end
