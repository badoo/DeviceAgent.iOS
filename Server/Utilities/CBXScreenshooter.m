// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#import <Foundation/Foundation.h>
#import "CBXScreenshooter.h"
#import "XCTScreenshotRequest.h"
#import "XCTImage.h"
#import "XCTImageEncoding.h"
#import "CBXException.h"

@interface CBXScreenshooter()

@property (nonatomic, readonly) id<XCTMessagingRole_CapabilityExchange> testmanagerd;
@property (nonatomic, readonly) BOOL shouldUseScreenshotRequest;
@property (nonatomic, readonly) XCTScreenshotRequest *screenshotRequest;
@property (nonatomic, readonly) NSInteger displayID;
@property (nonatomic, readonly) CGFloat compression;
@property (nonatomic, readonly) NSString *typeIdentifier;

@end

@implementation CBXScreenshooter

- (instancetype)initWithTestmanagerd:(id<XCTMessagingRole_CapabilityExchange>)testmanagerd
                           displayID:(NSInteger)displayID
                         compression:(CGFloat)compression
                      typeIdentifier:(NSString*)typeIdentifier
{
  if ((self = [super init])){
    _testmanagerd = testmanagerd;
    _displayID = displayID;
    _compression = compression;
    _typeIdentifier = typeIdentifier;


    if (@available(iOS 15.0, *)) {
      _shouldUseScreenshotRequest = YES;
    } else {
      _shouldUseScreenshotRequest = NO;
    }

    if (_shouldUseScreenshotRequest) {
      XCTImageEncoding *imageEncoding = [[XCTImageEncoding alloc] initWithUniformTypeIdentifier:typeIdentifier
                                                                             compressionQuality:_compression];

      _screenshotRequest = [[XCTScreenshotRequest alloc] initWithScreenID:_displayID
                                                                     rect:CGRectNull
                                                                 encoding:imageEncoding];
    } else {
      _screenshotRequest = nil;
    }

  }

  return self;
}

- (NSData *)getScreenshotData
{
  __block NSData *screenshotData = nil;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);

  if (_shouldUseScreenshotRequest) {
    [_testmanagerd _XCT_requestScreenshot:_screenshotRequest
                                withReply:^(XCTImage *image, NSError *error){
      if (error != nil) {
        NSLog(@"Cannot take screenshot. Error: %@", [error description]);
//        @throw [CBXException withFormat:@"Cannot take screenshot. Error: %@", [error description]];
      }

      screenshotData = [image data];
      dispatch_semaphore_signal(sem);
    }];
  } else {
    [_testmanagerd _XCT_requestScreenshotOfScreenWithID:_displayID
                                               withRect:CGRectNull
                                                    uti:_typeIdentifier
                                     compressionQuality:_compression
                                              withReply:^(NSData *data, NSError *error) {
      if (error != nil) {
        NSLog(@"Cannot take screenshot. Error: %@", [error description]);
//        @throw [CBXException withFormat:@"Cannot take screenshot. Error: %@", [error description]];
      }
      screenshotData = data;
      dispatch_semaphore_signal(sem);
    }];
  }

  dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)));

  if (nil == screenshotData) {
    NSLog(@"Cannot take screenshot. ScreenshotData is nil.");
//    @throw [CBXException withFormat:@"Cannot take screenshot from the device"];
  }

  return screenshotData;
}

@end
