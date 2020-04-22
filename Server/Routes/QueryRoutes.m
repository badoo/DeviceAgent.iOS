
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

@implementation QueryRoutes
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
      }]
      ];
}

@end
