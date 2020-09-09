
#import "CBXMacros.h"
#import "Testmanagerd.h"
#import "HealthRoutes.h"
#import "CBXRoute.h"
static NSString* const CONTENT_TYPE_KEY = @"Content-Type";
static NSString* const CONTENT_TYPE_VALUE = @"application/json; charset=utf-8";
static NSData* statusData = nil;
static NSData* healthData = nil;
static NSData* pingData = nil;

@implementation HealthRoutes
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError* e = nil;
        statusData = [NSJSONSerialization dataWithJSONObject:@{@"status" : @"DeviceAgent is ready and waiting."} options:0 error:&e];
        healthData = [NSJSONSerialization dataWithJSONObject:@{@"status" : @"Calabash is ready and waiting."} options:0 error:&e];
        pingData = [NSJSONSerialization dataWithJSONObject:@{@"status" : @"honk"} options:0 error:&e];
    });
}

+ (NSArray<CBXRoute *> *)getRoutes {
    return @[
             [CBXRoute get:endpoint(@"/health", 1.0) withBlock:^(RouteRequest *request, NSDictionary *body, RouteResponse *response) {
                 [response setHeader:CONTENT_TYPE_KEY value:CONTENT_TYPE_VALUE];
                 [response respondWithData:healthData];

             }],
             
             [CBXRoute get:endpoint(@"/ping", 1.0) withBlock:^(RouteRequest *request, NSDictionary *body, RouteResponse *response) {
                 [response setHeader:CONTENT_TYPE_KEY value:CONTENT_TYPE_VALUE];
                 [response respondWithData:pingData];

             }],
             
             [CBXRoute get:endpoint(@"/status", 1.0) withBlock:^(RouteRequest *request, NSDictionary *body, RouteResponse *response) {
                 [response setHeader:CONTENT_TYPE_KEY value:CONTENT_TYPE_VALUE];
                 [response respondWithData:statusData];
             }],
           ];
}
@end
