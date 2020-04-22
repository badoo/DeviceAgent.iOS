
#import "QueryRoutes.h"
#import "CBX-XCTest-Umbrella.h"
#import "XCTest+CBXAdditions.h"
#import "QueryConfigurationFactory.h"
#import "Application.h"
#import "CBXConstants.h"
#import "QueryFactory.h"
#import "JSONUtils.h"
#import "Query.h"
#import "SpringBoard.h"
#import "CBXOrientation.h"
#import "CBXMacros.h"
#import "CBXRoute.h"
#import "CBXException.h"
#import "Testmanagerd.h"

@implementation QueryRoutes
static NSDictionary<NSString *, NSNumber *> *parametersForFastElementSnapshot;
static NSArray *axAttributes;

+ (void)initialize
{
  parametersForFastElementSnapshot = @{
    @"maxArrayCount": @INT_MAX,
    @"maxChildren": @INT_MAX,
    @"maxDepth": @(1),
    @"traverseFromParentsToChildren": @(1)
  };

  NSArray<NSString *> *propertyNames = @[
    @"identifier",
    @"value",
    @"label",
    @"elementType",
    @"frame",
  ];
  NSSet *attributes = [[XCElementSnapshot class] axAttributesForElementSnapshotKeyPaths:propertyNames
                                                                                isMacOS:NO];
  axAttributes = [attributes allObjects];
}

+ (NSArray <CBXRoute *> *)getRoutes {
    return
    @[
      [CBXRoute get:endpoint(@"/tree", 1.0) withBlock:^(RouteRequest *request,
                                                        NSDictionary *data,
                                                        RouteResponse *response) {
          [[SpringBoard application] handleAlertsOrThrow];
          [response respondWithJSON:[Application tree]];
      }],

      [CBXRoute get:endpoint(@"/tree_app", 1.0) withBlock:^(RouteRequest *request,
                                                        NSDictionary *data,
                                                        RouteResponse *response) {

          NSArray* bundleIds = [request.params[CBX_BUNDLE_ID_KEY] componentsSeparatedByString:@","];

          NSMutableArray* resultsArray = [[NSMutableArray alloc] initWithCapacity:bundleIds.count];

          for (NSString *bundleId in bundleIds) {
              [resultsArray addObject:[Application tree:bundleId]];
          }

          [response respondWithJSON:@{@"result" : resultsArray}];
      }],

      [CBXRoute post:endpoint(@"/query", 1.0) withBlock:^(RouteRequest *request,
                                                          NSDictionary *body,
                                                          RouteResponse *response) {
          [[SpringBoard application] handleAlertsOrThrow];
          QueryConfiguration *config;
          config = [QueryConfigurationFactory configWithJSON:body
                                                   validator:[Query validator]];
          Query *query = [QueryFactory queryWithQueryConfiguration:config];

          NSArray <XCUIElement *> *elements = [query execute];

          /*
           Format and return the results
           */
          NSMutableArray *results = [NSMutableArray arrayWithCapacity:elements.count];
          for (XCUIElement *el in elements) {
              NSDictionary *json = [JSONUtils snapshotOrElementToJSON:el];
              [results addObject:json];
          }
          [response respondWithJSON:@{@"result" : results}];
      }],

      [CBXRoute post:endpoint(@"/query_all", 1.0) withBlock:^(RouteRequest *request,
                                                          NSDictionary *body,
                                                          RouteResponse *response) {
          // [[SpringBoard application] handleAlertsOrThrow];
          QueryConfiguration *config;
          config = [QueryConfigurationFactory configWithJSON:body
                                                   validator:[Query validator]];
          Query *query = [QueryFactory queryWithQueryConfiguration:config];

          NSArray* bundleIds = [request.params[CBX_BUNDLE_ID_KEY] componentsSeparatedByString:@","];
          NSArray <XCUIElement *> *elements= nil;
          NSMutableArray *finalResults = [[NSMutableArray alloc] initWithCapacity:bundleIds.count];;

          for (NSString *bundleId in bundleIds) {
              elements = [query execute: bundleId];

              /*
               Format and return the results
               */
              NSMutableArray *results = [NSMutableArray arrayWithCapacity:elements.count];
              for (XCUIElement *el in elements) {
                  NSDictionary *json = [JSONUtils snapshotOrElementToJSON:el];
                  [results addObject:json];
              }
              [finalResults addObject:results];
          }

          [response respondWithJSON:@{@"result" : finalResults}];
      }],

      [CBXRoute get:endpoint(@"/springboard-alert", 1.0) withBlock:^(RouteRequest *request,
                                                                     NSDictionary *data,
                                                                     RouteResponse *response) {
          XCUIElement *alert = [[SpringBoard application] queryForAlert];
          NSDictionary *results;

          if (alert && alert.exists) {
              NSString *alertTitle = alert.label;
              XCUIElementQuery *query = [alert descendantsMatchingType:XCUIElementTypeButton];
              NSArray<XCUIElement *> *buttons = [query allElementsBoundByIndex];

              NSMutableArray *mutable = [NSMutableArray arrayWithCapacity:buttons.count];

              for (XCUIElement *button in buttons) {
                  if (button.exists) {
                      NSString *name = button.label;
                      if (name) {
                          [mutable addObject:name];
                      }
                  }
              }

              NSArray *alertButtonTitles = [NSArray arrayWithArray:mutable];
              NSMutableDictionary *alertJSON;
              alertJSON = [NSMutableDictionary dictionaryWithDictionary:[JSONUtils snapshotOrElementToJSON:alert]];
              alertJSON[@"is_springboard_alert"] = @(YES);
              alertJSON[@"button_titles"] = alertButtonTitles;
              alertJSON[@"alert_title" ] = alertTitle;

              results = [NSDictionary dictionaryWithDictionary:alertJSON];
          } else {
              results = @{};
          }

          [response respondWithJSON:results];
      }],

      [CBXRoute get:endpoint(@"/orientations", 1.0) withBlock:^(RouteRequest *request,
                                                                NSDictionary *data,
                                                                RouteResponse *response) {
          [response respondWithJSON:[CBXOrientation orientations]];
      }],

      [CBXRoute get:endpoint(@"/element-types", 1.0) withBlock:^(RouteRequest *request,
                                                                 NSDictionary *data,
                                                                 RouteResponse *response) {
          [response respondWithJSON:@{ @"types": [JSONUtils elementTypes] }];
      }],


      [CBXRoute get:endpoint(@"/element-at-coords", 1.0) withBlock:^(RouteRequest *request,
                                                                 NSDictionary *data,
                                                                 RouteResponse *response) {
          CGFloat x = [[request param:@"x"] floatValue];
          CGFloat y = [[request param:@"y"] floatValue];
          CGPoint screenPoint = CGPointMake(x, y);
          __block XCAccessibilityElement *elementAtPoint;
          __block NSError *elementRequestError;
          dispatch_semaphore_t sem = dispatch_semaphore_create(0);
          [[Testmanagerd get] _XCT_requestElementAtPoint:screenPoint
                                      reply:^(XCAccessibilityElement *element, NSError *error) {
                                        if (error == nil) {
                                          elementAtPoint = element;
                                        } else {
                                          elementRequestError = error;
                                        }
                                        dispatch_semaphore_signal(sem);
                                      }];
          dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)));

          if (elementRequestError != nil) {
              @throw [CBXException withFormat:@"Error getting element at coords:\n%@",
                      [elementRequestError localizedDescription]];
          }

          XCElementSnapshot *snap = [self fastElementSnapshot:elementAtPoint];
          NSDictionary *result = @{
            @"type":  [NSString stringWithFormat:@"%@", [JSONUtils stringForElementType:snap.elementType]],
            @"value": [NSString stringWithFormat:@"%@", snap.value],
            @"label": [NSString stringWithFormat:@"%@", snap.label],
            @"frame": NSStringFromCGRect(snap.frame)
          };

          [response respondWithJSON:@{@"result": result}];
      }]
      ];
}

+(XCElementSnapshot *)fastElementSnapshot:(XCAccessibilityElement *)element
{
  __block XCElementSnapshot *snapshotWithAttributes = nil;
  __block NSError *innerError = nil;
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);

  [[Testmanagerd get] _XCT_requestSnapshotForElement:element
                             attributes:axAttributes
                             parameters:parametersForFastElementSnapshot
                                  reply:^(XCElementSnapshot *snapshot, NSError *error) {
                                    if (nil == error) {
                                      snapshotWithAttributes = snapshot;
                                    } else {
                                      innerError = error;
                                      NSLog(@"ERROR while getting _XCT_requestSnapshotForElement: %@", error);
                                    }
                                    dispatch_semaphore_signal(sem);
                                  }];

    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)));

  return snapshotWithAttributes;
}

@end
