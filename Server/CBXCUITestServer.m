#import "RoutingHTTPServer.h"
#import "RoutingConnection.h"
#import "CBXCUITestServer.h"
#import "UIDevice+Wifi_IP.h"
#import "UndefinedRoutes.h"
#import <objc/runtime.h>
#import "CBXProtocols.h"
#import "CBXConstants.h"
#import "CBXLogging.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "CBXOrientation.h"
#import "CBXRoute.h"
#import "FBTCPSocket.h"
#import "FBMjpegServer.h"

@interface CBXCUITestServer ()
@property (atomic, strong) RoutingHTTPServer *server;
@property (atomic, assign) BOOL isFinishedTesting;
@property (nonatomic, nullable) FBTCPSocket *screenshotsBroadcaster;

+ (CBXCUITestServer *)sharedServer;
- (id)init_private;

@end

@implementation CBXCUITestServer

+ (NSString*)valueFromArguments: (NSArray<NSString *> *)arguments forKey: (NSString*)key
{
  NSUInteger index = [arguments indexOfObject:key];
  if (index == NSNotFound || index == arguments.count - 1) {
    return nil;
  }
  return arguments[index + 1];
}

static NSString *serverName = @"CalabashXCUITestServer";

- (id)init {
    @throw [NSException exceptionWithName:@"SingletonException"
                                   reason:@"This is a singleton class. init is not available."
                                 userInfo:nil];
}

- (instancetype)init_private {
    self = [super init];
    if (self) {
        _isFinishedTesting = NO;
        _server = [[RoutingHTTPServer alloc] init];
        [_server setRouteQueue:dispatch_get_main_queue()];
        [_server setDefaultHeader:@"CalabusDriver"
                                        value:@"CalabashXCUITestServer/1.0"];
        [_server setDefaultHeader:@"Access-Control-Allow-Origin"
                                        value:@"*"];
        [_server setDefaultHeader:@"Access-Control-Allow-Headers"
                                        value:@"Content-Type, X-Requested-With"];
        [_server setConnectionClass:[RoutingConnection self]];
        [_server setType:@"_calabus._tcp."];

        NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString *token = [uuid componentsSeparatedByString:@"-"][0];
        NSString *serverName = [NSString stringWithFormat:@"CalabusDriver-%@", token];
        [_server setName:serverName];

        NSDictionary *capabilities =
        @{
          @"name" : [[UIDevice currentDevice] name]
          };

        [_server setTXTRecordDictionary:capabilities];
        [self registerRoutes];
    }
    return self;
}

+ (CBXCUITestServer *)sharedServer {
    static CBXCUITestServer *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CBXCUITestServer alloc] init_private];
    });
    return shared;
}


+ (void)start {
    [CBXLogging startLumberjackLogging];

    DDLogDebug(@"%@ built at %s %s", serverName, __DATE__, __TIME__);
    [[CBXCUITestServer sharedServer] start];

    [CBXOrientation setOrientation:UIDeviceOrientationPortrait
               secondsToSleepAfter:1.0];
}

- (void)start {
    NSError *error;
    BOOL serverStarted = NO;
    
    NSString *portNumberString = [CBXCUITestServer valueFromArguments: NSProcessInfo.processInfo.arguments
                                                   forKey: @"--port"];
    NSUInteger port = (NSUInteger)[portNumberString integerValue];
    
    if (port == 0) {
      [self.server setPort:CBX_DEFAULT_SERVER_PORT];
    } else {
        [self.server setPort:port];
    }
    
    NSString *mjpegPortNumberString = [CBXCUITestServer valueFromArguments: NSProcessInfo.processInfo.arguments
                                                   forKey: @"--mjpeg-server-port"];
    NSUInteger mjpegPort = (NSUInteger)[mjpegPortNumberString integerValue];
    
    
    DDLogDebug(@"Attempting to start the DeviceAgent server on port %@", @(port));
    serverStarted = [self attemptToStartWithError:&error];

    if (!serverStarted) {
        DDLogDebug(@"Attempt to start web server failed with error %@", [error description]);
        abort();
    }

    DDLogDebug(@"%@ started on http://%@:%hu",
          serverName,
          [UIDevice currentDevice].wifiIPAddress,
          [self.server port]);

    DDLogDebug(@"Disabling screenshots in NSUserDefaults");
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DisableScreenshots"];
    
    if (mjpegPort == 0) {
        [self initScreenshotsBroadcaster: CBX_DEFAULT_MJPEG_PORT];
    }
    else {
        [self initScreenshotsBroadcaster: mjpegPort];
    }
    
    while ([self.server isRunning] && !self.isFinishedTesting) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, CBX_RUNLOOP_INTERVAL, false);
    }
}

+ (void)stop {
    [[CBXCUITestServer sharedServer] stop];
}

- (void)stop {
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW,
                                         CBX_SERVER_SHUTDOWN_DELAY * NSEC_PER_SEC);
    dispatch_after(when, dispatch_get_main_queue(), ^{
        [self.server stop:NO];
        [self stopScreenshotsBroadcaster];
        if ([self.server isRunning]) {
            DDLogDebug(@"DeviceAgent server has retired.");
        } else {
            DDLogDebug(@"DeviceAgent server is still running.");
        }
        self.isFinishedTesting = YES;
    });
}

- (BOOL)attemptToStartWithError:(NSError **)error {
    NSError *innerError = nil;
    BOOL started = [self.server start:&innerError];
    if (!started) {
        if (!error) {
            return NO;
        }

        NSString *description = @"Unknown Error when Starting server";
        if ([innerError.domain isEqualToString:NSPOSIXErrorDomain] && innerError.code == EADDRINUSE) {
            description = [NSString stringWithFormat:@"Unable to start web server on port %ld", (long)self.server.port];
        }

        *error = [NSError errorWithDomain:CBXWebServerErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : description, NSUnderlyingErrorKey : innerError}];
        return NO;
    }
    return YES;
}

/*
 *  Use objc runtime to get all classes inheriting implementing CBRoute.
 *  call [Class addRoutesToServer:self.server] on all resulting classes.
 */
- (void)registerRoutes {
    unsigned int outCount;
    Class *classes = objc_copyClassList(&outCount);
    for (int i = 0; i < outCount; i++) {
        Class c = classes[i];
        if (class_conformsToProtocol(c, @protocol(CBRouteProvider))) {
            NSArray <CBXRoute *> *routes = [c performSelector:@selector(getRoutes)];
            for (CBXRoute *route in routes) {
                if ([route shouldAutoregister]) {
                    [self.server addRoute:route];
                }
            }
        }
    }
    free(classes);
    for (CBXRoute *route in [UndefinedRoutes getRoutes]) {
        [self.server addRoute:route];
    }
}

- (void)initScreenshotsBroadcaster:(NSUInteger)port
{
  self.screenshotsBroadcaster = [[FBTCPSocket alloc]
                                 initWithPort:(uint16_t)port];
  self.screenshotsBroadcaster.delegate = [[FBMjpegServer alloc] init];
  NSError *error;
  if (![self.screenshotsBroadcaster startWithError:&error]) {
    DDLogDebug(@"Cannot init screenshots broadcaster service on port %@. Original error: %@", @(port), error.description);
    self.screenshotsBroadcaster = nil;
  }
}

- (void)stopScreenshotsBroadcaster
{
  if (nil == self.screenshotsBroadcaster) {
    return;
  }

  [self.screenshotsBroadcaster stop];
}

@end
