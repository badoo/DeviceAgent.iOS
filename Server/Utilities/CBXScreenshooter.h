// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#import "XCTMessagingRole_CapabilityExchange-Protocol.h"

@interface CBXScreenshooter : NSObject
- (instancetype)initWithTestmanagerd:(id<XCTMessagingRole_CapabilityExchange>)testmanagerd
                           displayID:(NSInteger)displayID
                         compression:(CGFloat)compression
                      typeIdentifier:(NSString*)typeIdentifier;

- (NSData *)getScreenshotData;

@end
