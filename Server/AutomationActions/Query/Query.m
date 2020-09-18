
#import "Query.h"
#import "CBX-XCTest-Umbrella.h"
#import "XCTest+CBXAdditions.h"
#import "Application.h"
#import "CoordinateQueryConfiguration.h"
#import "QuerySpecifierFactory.h"
#import "CoordinateQuery.h"
#import "CBXException.h"
#import "JSONUtils.h"
#import "XCTest+CBXAdditions.h"

@implementation Query

+ (JSONKeyValidator *)validator {
    return [JSONKeyValidator withRequiredKeys:@[]
                                 optionalKeys:[QuerySpecifierFactory supportedSpecifierNames]];
}

- (BOOL)isCoordinateQuery {
    return NO;
}

- (CoordinateQuery *)asCoordinateQuery {
    return [CoordinateQuery withQueryConfiguration:self.queryConfiguration.asCoordinateQueryConfiguration];
}

+ (instancetype)withQueryConfiguration:(QueryConfiguration *)queryConfig {
    Query *e = [self new];
    e.queryConfiguration = queryConfig;
    return e;
}

- (NSArray<XCUIElement *> *)execute {
    if (self.queryConfiguration.selectors.count == 0) {
        @throw [CBXException withMessage:@"Query must have at least one "
                "specifier"];
    }

    if (![Application currentApplication]) {
        @throw [CBXException withMessage:@"Current application is nil. Cannot "
                "perform queries until POST /session route is called"];
    }

    XCUIApplication *application = [Application currentApplication];

    if (application.processID == 0 || application.state != XCUIApplicationStateRunningForeground) {
        @throw [CBXException withMessage:@"Current application is NOT running. Cannot "
                "perform queries until POST /session route is called"];
    }

    DDLogError(@"DA_DEBUG: Seaching for elements of current application of type any");
    NSDate *methodStart = [NSDate date];
    XCUIElementQuery *query = [application descendantsMatchingType:0];
    NSDate *methodFinish = [NSDate date];
    DDLogError(@"DA_DEBUG: DID Seach for elements of current application of type any. Execution time: %f",
               [methodFinish timeIntervalSinceDate:methodStart]);

    for (QuerySpecifier *specifier in self.queryConfiguration.selectors) {
        query = [specifier applyToQuery:query];
    }

    //TODO: if there's a child query, recurse
    //
    //if (childQuery) {
    //    return [childQuery execute];
    //} else {
    return [query allElementsBoundByIndex];
    //}
}

- (NSArray<XCUIElement *> *)executeWithApplication:(XCUIApplication *)application {
    if (self.queryConfiguration.selectors.count == 0) {
        @throw [CBXException withMessage:@"Query must have at least one "
                "specifier"];
    }

    if (application.processID == 0) {
        @throw [CBXException withMessage:
                [NSString stringWithFormat:@"Current application is NOT running. Cannot "
                "perform queries until POST /session route is called. App bundle ID: %@, PID: %ld", application.bundleID, application.processID]];
    }

    if (application.state != XCUIApplicationStateRunningForeground && application.state != XCUIApplicationStateRunningBackground) {
        @throw [CBXException withMessage:[NSString stringWithFormat:@"Current application is NOT running. Cannot "
                                         "perform queries until POST /session route is called. App bundle ID: %@, state: %ld", application.bundleID, application.state]];
    }

    DDLogError(@"DA_DEBUG: Seaching for elements of current application of type any");
    NSDate *methodStart = [NSDate date];
    XCUIElementQuery *query = [application descendantsMatchingType:0];
    NSDate *methodFinish = [NSDate date];
    DDLogError(@"DA_DEBUG: DID Seach for elements of current application of type any. Execution time: %f",
               [methodFinish timeIntervalSinceDate:methodStart]);

    for (QuerySpecifier *specifier in self.queryConfiguration.selectors) {
        query = [specifier applyToQuery:query];
    }

    return [query allElementsBoundByIndex];
}

- (NSArray<XCUIElement *> *)execute:(NSString *_Nullable)bundleId {
    if (self.queryConfiguration.selectors.count == 0) {
        @throw [CBXException withMessage:@"Query must have at least one "
                "specifier"];
    }

    XCUIApplication *application = [[XCUIApplication alloc] initWithBundleIdentifier:bundleId];

    if (application.processID == 0 || application.state != XCUIApplicationStateRunningForeground) {
        return [[NSArray alloc] init];
    }

    DDLogError(@"DA_DEBUG: Seaching for elements of application %@ of type any", bundleId);
    NSDate *methodStart = [NSDate date];
    XCUIElementQuery *query = [application descendantsMatchingType:0];
    DDLogError(@"DA_DEBUG: DID Seach for elements of application %@ of type any. Execution time: %f",
               bundleId, [[NSDate date] timeIntervalSinceDate:methodStart]);

    for (QuerySpecifier *specifier in self.queryConfiguration.selectors) {
        query = [specifier applyToQuery:query];
    }

    DDLogError(@"DA_DEBUG: Getting children elements of application %@", bundleId);
    NSDate *method2Start = [NSDate date];
    NSArray<XCUIElement *> *elements = [query allElementsBoundByIndex];
    DDLogError(@"DA_DEBUG: DID Get children elements of application %@. Execution time: %f",
               bundleId, [[NSDate date] timeIntervalSinceDate:method2Start]);

    return elements;
}


- (NSDictionary *)toDict {
    return self.queryConfiguration.raw;
}

- (NSString *)toJSONString {
    return [JSONUtils objToJSONString:[self toDict]];
}

- (NSString *)description {
    return [[self toDict] ?: @{} description];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return self.queryConfiguration[key];
}

@end
