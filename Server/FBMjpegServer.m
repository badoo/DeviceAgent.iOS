/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBMjpegServer.h"

#import <mach/mach_time.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GCDAsyncSocket.h"
#import "Application.h"
#import "Testmanagerd.h"
#import "XCUIScreen.h"
#import "CBXScreenshooter.h"
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

static const NSUInteger MAX_FPS = 60;
static NSString *const SERVER_NAME = @"WDA MJPEG Server";
static const char *QUEUE_NAME = "JPEG Screenshots Provider Queue";
static const CGFloat COMPRESSION_QUALITY = 0.8;
static const CGFloat SCREENSHOT_MAX_WIDTH = 450.0;
static const uint64_t SCREENSHOT_INTERVAL = (uint64_t)(0.2 * NSEC_PER_SEC);

@interface FBMjpegServer()

@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;
@property (nonatomic, readonly) NSMutableArray<GCDAsyncSocket *> *listeningClients;
@property (nonatomic, readonly) mach_timebase_info_data_t timebaseInfo;
@property (nonatomic, readonly) CBXScreenshooter *screenshooter;
@property (nonatomic, readonly) CGSize scaledSize;

@end

@implementation FBMjpegServer

- (instancetype)init
{
  if ((self = [super init])) {
    _listeningClients = [NSMutableArray array];
    dispatch_queue_attr_t queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
    _backgroundQueue = dispatch_queue_create(QUEUE_NAME, queueAttributes);
    mach_timebase_info(&_timebaseInfo);
    dispatch_async(_backgroundQueue, ^{
      [self streamScreenshot];
    });

    _screenshooter = [[CBXScreenshooter alloc] initWithTestmanagerd:[Testmanagerd_CapabilityExchange get]
                                                          displayID:[[XCUIScreen mainScreen] displayID]
                                                        compression:1.0f
                                                     typeIdentifier:@"JPEG" //(__bridge id)kUTTypeJPEG
    ];

    UIImage *image = [UIImage imageWithData:[_screenshooter getScreenshotData]];
    CGFloat screenWidth = image.size.width;
    CGFloat screenHeight = image.size.height;
    CGFloat scalingFactor = (screenWidth > SCREENSHOT_MAX_WIDTH) ? SCREENSHOT_MAX_WIDTH / screenWidth : 1.0;
    _scaledSize = CGSizeMake(screenWidth * scalingFactor, screenHeight * scalingFactor);
  }
  return self;
}


- (void)scheduleNextScreenshotWithInterval:(uint64_t)timerInterval timeStarted:(uint64_t)timeStarted
{
  uint64_t timeElapsed = mach_absolute_time() - timeStarted;
  int64_t nextTickDelta = timerInterval - timeElapsed * self.timebaseInfo.numer / self.timebaseInfo.denom;
  if (nextTickDelta > 0) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, nextTickDelta), self.backgroundQueue, ^{
      [self streamScreenshot];
    });
  } else {
    // Try to do our best to keep the FPS at a decent level
    dispatch_async(self.backgroundQueue, ^{
      [self streamScreenshot];
    });
  }
}

- (void)streamScreenshot
{
  uint64_t timeStarted = mach_absolute_time();
  @synchronized (self.listeningClients) {
    if (0 == self.listeningClients.count) {
      [self scheduleNextScreenshotWithInterval:SCREENSHOT_INTERVAL timeStarted:timeStarted];
      return;
    }
  }

  @try {
      UIImage *image = [UIImage imageWithData:[_screenshooter getScreenshotData]];
      dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
      __block UIImage *scaledImage = nil;
      [image prepareThumbnailOfSize:self.scaledSize completionHandler:^(UIImage * _Nullable thumbnail) {
        scaledImage = thumbnail;
        dispatch_semaphore_signal(semaphore);
      }];
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

      if (nil == scaledImage) {
          NSLog(@"Screenshot exception: Failed to scale image using prepareThumbnailOfSize");
      } else {
        NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, COMPRESSION_QUALITY);
          if (nil == scaledImageData) {
            NSLog(@"Screenshot exception: Failed to scale image using UIImageJPEGRepresentation");
          } else {
            [self sendScreenshot:scaledImageData];
          }
      }
  } @catch (NSException *exception) {
    NSLog(@"Screenshot exception: %@, %@", exception.name, exception.reason);
  }

  [self scheduleNextScreenshotWithInterval:SCREENSHOT_INTERVAL timeStarted:timeStarted];
}

- (void)sendScreenshot:(NSData *)screenshotData {
  NSString *chunkHeader = [NSString stringWithFormat:@"--BoundaryString\r\nContent-type: image/jpg\r\nContent-Length: %@\r\n\r\n", @(screenshotData.length)];
  NSMutableData *chunk = [[chunkHeader dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
  [chunk appendData:screenshotData];
  [chunk appendData:(id)[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  @synchronized (self.listeningClients) {
    for (GCDAsyncSocket *client in self.listeningClients) {
      [client writeData:chunk withTimeout:-1 tag:0];
    }
  }
}

- (void)didClientConnect:(GCDAsyncSocket *)newClient
{
  DDLogError(@"Got screenshots broadcast client connection at %@:%d", newClient.connectedHost, newClient.connectedPort);
  // Start broadcast only after there is any data from the client
  [newClient readDataWithTimeout:-1 tag:0];
}

- (void)didClientSendData:(GCDAsyncSocket *)client
{
  @synchronized (self.listeningClients) {
    if ([self.listeningClients containsObject:client]) {
      return;
    }
  }

  DDLogError(@"Starting screenshots broadcast for the client at %@:%d", client.connectedHost, client.connectedPort);
  NSString *streamHeader = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nServer: %@\r\nConnection: close\r\nMax-Age: 0\r\nExpires: 0\r\nCache-Control: no-cache, private\r\nPragma: no-cache\r\nContent-Type: multipart/x-mixed-replace; boundary=--BoundaryString\r\n\r\n", SERVER_NAME];
  [client writeData:(id)[streamHeader dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
  @synchronized (self.listeningClients) {
    [self.listeningClients addObject:client];
  }
}

- (void)didClientDisconnect:(GCDAsyncSocket *)client
{
  @synchronized (self.listeningClients) {
    [self.listeningClients removeObject:client];
  }
  DDLogError(@"Disconnected a client from screenshots broadcast");
}

@end
