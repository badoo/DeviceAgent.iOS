
#import "GestureFactory.h"
#import "GestureRoutes.h"
#import "CBXConstants.h"
#import "JSONUtils.h"
#import "CBXMacros.h"
#import "SpringBoard.h"
#import "InvalidArgumentException.h"
#import "CBXRoute.h"

@implementation GestureRoutes
+ (NSArray<CBXRoute *> *)getRoutes {
    return @[
             [CBXRoute post:endpoint(@"/gesture", 1.0) withBlock:^(RouteRequest *request, NSDictionary *body, RouteResponse *response) {

                 // SpringBoard alerts block gestures.
                 [[SpringBoard application] handleAlertsOrThrow];

                 [GestureFactory executeGestureWithJSON:body completion:^(NSError *e) {
                     if (e) {
                         [response respondWithJSON:@{ @"error" : e.localizedDescription }];
                     } else {
                         [response respondWithJSON:@{ @"status" : @"success" }];
                     }
                 }];
             }],

             [CBXRoute post:endpoint(@"/dismiss-springboard-alerts", 1.0) withBlock:^(RouteRequest *request,
                                                                                      NSDictionary *body,
                                                                                      RouteResponse *response) {
                 [[SpringBoard application] handleAlertsOrThrow];
                 [response respondWithJSON:@{ @"status" : @"no alerts" }];
             }],

             [CBXRoute post:endpoint(@"/dismiss-springboard-alert", 1.0) withBlock:^(RouteRequest *request,
                                                                                     NSDictionary *body,
                                                                                     RouteResponse *response) {
                 NSString *buttonTitle = body[@"button_title"];

                 if (!buttonTitle) {
                     @throw [InvalidArgumentException
                             withMessage:@"Request body is missing required key: 'button_title'"
                             userInfo:@{@"received_body" : body}];
                 }

                 SpringBoardDismissAlertResult result;
                 result = [[SpringBoard application]
                           dismissAlertByTappingButtonWithTitle:buttonTitle];

                 NSDictionary *responseBody;
                 NSString *message = @"";
                 switch (result) {
                     case SpringBoardDismissAlertNoAlert: {
                         responseBody =
                         @{
                           @"error": @"There is no SpringBoard alert."
                           };
                         break;
                     }

                     case SpringBoardDismissAlertNoMatchingButton: {
                         message = [NSString stringWithFormat:@"There was no SpringBoard "
                                    "alert button matching '%@'", buttonTitle];
                         responseBody =
                         @{
                           @"error" : message
                           };
                         break;
                     }

                     case SpringBoardDismissAlertDismissTouchFailed: {
                         message = [NSString stringWithFormat:@"Failed to touch SpringBoard "
                                    "alert button with title '%@'", buttonTitle];
                         responseBody =
                         @{
                           @"error" : message
                           };
                         break;
                     }

                     case SpringBoardDismissAlertDismissedAlert: {
                         responseBody = @{ @"status" : @"success" };
                         break;
                     }
                 }

                 [response respondWithJSON:responseBody];
             }],
             
             [CBXRoute post:endpoint(@"/preferable-autodismiss-springboard-alert", 1.0) withBlock:^(RouteRequest *request,
                                                                                                  NSDictionary *body,
                                                                                                  RouteResponse *response) {
                 NSArray<NSString *> *buttons = body[@"preferable_buttons"];
                 if (buttons == nil) {
                     @throw [InvalidArgumentException
                             withMessage:@"Request body is missing required key: 'preferable_buttons'"
                             userInfo:@{@"received_body" : body}];
                 }
                 
                 if ([buttons count] == 0) {
                     @throw [InvalidArgumentException
                             withMessage:@"Request body is missing required value for key 'preferable_buttons'"
                             userInfo:@{@"received_body" : body}];
                 }

                 NSString *result = [[SpringBoard application] autodismissAlertWithPreferences:buttons];

                 [response respondWithJSON:@{ @"status" : result }];
             }]

             ];
}


@end
