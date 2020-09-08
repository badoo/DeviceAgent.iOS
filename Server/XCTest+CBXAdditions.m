
#import "XCTest+CBXAdditions.h"
#import "CBX-XCTest-Umbrella.h"
#import "CBXException.h"

// This implementation does not implement all the methods in the category
// interface.  This is by design - the category is used to expose private
// methods.  It is safe to ignore these warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation XCUIApplication (CBXAdditions)

+ (NSString *_Nonnull)cbxStringForApplicationState:(XCUIApplicationState)state {
    switch (state) {
        case XCUIApplicationStateUnknown: { return @"unknown"; }
        case XCUIApplicationStateNotRunning: { return @"not running"; }
        case XCUIApplicationStateRunningBackgroundSuspended: {
            return @"background suspended";
        }
        case XCUIApplicationStateRunningBackground: { return @"background"; }
        case XCUIApplicationStateRunningForeground: { return @"foreground"; }
        default: {
            @throw [CBXException withFormat:@"Cannot find string for "
                    "application state: %@", @(state)];
        }
    }
}

+ (id _Nullable)cbxQuery:(XCUIApplication *)xcuiApplication {
    SEL selector = NSSelectorFromString(@"query");

    NSMethodSignature *signature;
    Class klass = NSClassFromString(@"XCUIApplication");
    signature = [klass instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation;

    invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = xcuiApplication;
    invocation.selector = selector;

    id query = nil;
    void *buffer = nil;
    [invocation invoke];
    [invocation getReturnValue:&buffer];
    query = (__bridge id)buffer;
    return query;
}

@end

@implementation XCUIElement (CBXAdditions)
- (void)cbx_resolve {
    if ([self respondsToSelector:@selector(resolve)]) {
        [self resolve];
    } else {
        NSError *error = nil;
        if (![self resolveOrRaiseTestFailure:NO error:&error]) {
            DDLogWarn(@"Encountered an error resolving element '%@':\n%@",
                    self, [error localizedDescription]);
        }
    }
}
@end

@implementation XCUIElementQuery (CBXAdditions)

- (XCElementSnapshot *)cbx_elementSnapshotForDebugDescription {
    DDLogError(@"DA_DEBUG: cbx_elementSnapshotForDebugDescription");
    NSDate *methodStart = [NSDate date];

    XCElementSnapshot *snapshot = nil;

    if ([self respondsToSelector:@selector(elementSnapshotForDebugDescription)]) {
        DDLogError(@"DA_DEBUG: elementSnapshotForDebugDescription");
        snapshot = [self elementSnapshotForDebugDescription];
    } else if ([self respondsToSelector:@selector(elementSnapshotForDebugDescriptionWithNoMatchesMessage:)]) {
        DDLogError(@"DA_DEBUG: elementSnapshotForDebugDescriptionWithNoMatchesMessage");
        snapshot = [self elementSnapshotForDebugDescriptionWithNoMatchesMessage:nil];
    } else {
        @throw [CBXException withFormat:@"Cannot retrieve element snapshot"];
    }

    DDLogError(@"DA_DEBUG: DID cbx_elementSnapshotForDebugDescription. Execution time: %f",
               [[NSDate date] timeIntervalSinceDate:methodStart]);

    return snapshot;
}

@end

#pragma clang diagnostic pop
