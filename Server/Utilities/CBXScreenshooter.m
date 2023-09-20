// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#import <Foundation/Foundation.h>
#import "CBXScreenshooter.h"
#import "CBXException.h"
#import "XCTImage.h"

@class XCTImageEncoding;
@class XCTScreenshotRequest;

@interface CBXScreenshooter()

@property (nonatomic, readonly) id<XCTMessagingRole_CapabilityExchange> testmanagerd;
@property (nonatomic, readonly) Class testmanagerdСlass;
@property (nonatomic, readonly) SEL screenshotSelector;
@property (nonatomic, readonly) NSMethodSignature *screenshotMethodSignature;
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
    _testmanagerdСlass = [((NSObject *)_testmanagerd) class];

    if (@available(iOS 15.0, *)) {
      _shouldUseScreenshotRequest = YES;
    } else {
      _shouldUseScreenshotRequest = NO;
    }

    if (_shouldUseScreenshotRequest) {
      _screenshotRequest = [self createScreenshotRequest:[self creatImageEncodingWithCompression:compression typeIdentifier:typeIdentifier]];
      _screenshotSelector = NSSelectorFromString(@"_XCT_requestScreenshot:withReply:");
      _screenshotMethodSignature = [_testmanagerdСlass instanceMethodSignatureForSelector:_screenshotSelector];
    } else {
      _screenshotRequest = nil;
      _screenshotSelector = NSSelectorFromString(@"_XCT_requestScreenshotOfScreenWithID:withRect:uti:compressionQuality:withReply:");
      _screenshotMethodSignature = [_testmanagerdСlass instanceMethodSignatureForSelector:_screenshotSelector];
    }
  }

  return self;
}

- (NSData *)getScreenshotData
{
  __block NSData *screenshotData = nil;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);

  if (_shouldUseScreenshotRequest) {
      void (^callBack)(XCTImage *, NSError *) = ^(XCTImage *image, NSError *error){
          if (error != nil) {
              NSLog(@"Cannot take screenshot. Error: %@", [error description]);
          }

          screenshotData = [image data];
          dispatch_semaphore_signal(sem);
      };

      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:_screenshotMethodSignature];
      invocation.target = _testmanagerd;
      invocation.selector = _screenshotSelector;
      [invocation setArgument:&_screenshotRequest atIndex:2];
      [invocation setArgument:&callBack atIndex:3];
      [invocation invoke];
  } else {
      void (^callBack)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
          if (error != nil) {
            NSLog(@"Cannot take screenshot. Error: %@", [error description]);
          }
          screenshotData = data;
          dispatch_semaphore_signal(sem);
      };

      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:_screenshotMethodSignature];
      invocation.target = _testmanagerd;
      invocation.selector = _screenshotSelector;
      [invocation setArgument:&_displayID atIndex:2];
      [invocation setArgument:&CGRectNull atIndex:3];
      [invocation setArgument:&_typeIdentifier atIndex:4];
      [invocation setArgument:&_compression atIndex:5];
      [invocation setArgument:&callBack atIndex:6];
      [invocation invoke];
  }

  dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)));

  if (nil == screenshotData) {
    NSLog(@"Cannot take screenshot. ScreenshotData is nil.");
  }

  return screenshotData;
}

- (XCTScreenshotRequest *)createScreenshotRequest:(XCTImageEncoding *)imageEncoding {
    Class screenshotRequestClass = NSClassFromString(@"XCTScreenshotRequest");
    id screenshotRequestInstance = [screenshotRequestClass alloc];
    SEL selector = NSSelectorFromString(@"initWithScreenID:rect:encoding:");
    NSMethodSignature *signature = [screenshotRequestClass instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = screenshotRequestInstance;
    invocation.selector = selector;
    [invocation setArgument:&_displayID atIndex:2];
    [invocation setArgument:&CGRectNull atIndex:3];
    [invocation setArgument:&imageEncoding atIndex:4];

    void *buffer;
    [invocation invoke];
    [invocation getReturnValue:&buffer];
    XCTScreenshotRequest *request = (__bridge XCTScreenshotRequest *)buffer;
    return request;
}

- (XCTImageEncoding *)creatImageEncodingWithCompression:(CGFloat)compression
                                         typeIdentifier:(NSString*)typeIdentifier {
    Class class = NSClassFromString(@"XCTImageEncoding");
    id instance = [class alloc];
    SEL selector = NSSelectorFromString(@"initWithUniformTypeIdentifier:compressionQuality:");
    NSMethodSignature *signature = [class instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = instance;
    invocation.selector = selector;
    [invocation setArgument:&typeIdentifier atIndex:2];
    [invocation setArgument:&compression atIndex:3];
    [invocation invoke];

    void *buffer;
    [invocation invoke];
    [invocation getReturnValue:&buffer];
    XCTImageEncoding *encoding = (__bridge XCTImageEncoding *)buffer;
    return encoding;
}

@end
