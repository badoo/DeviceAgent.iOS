
#import "QuerySelectorProperty.h"

@implementation QuerySelectorProperty
+ (NSDictionary <NSString *, id> *)parseValue:(id)value {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    if ([value isKindOfClass:[NSString class]]) {
        NSArray *components = [value componentsSeparatedByString:@"="];
        if (components.count < 2) {
            @throw [CBInvalidArgumentException withFormat:@"Malformed property selector. Expected 'key=val', got '%@'", value];
        }
        if ([components[0] isEqualToString:@""]) {
            @throw [CBInvalidArgumentException withMessage:@"Invalid property selector (can not use empty string as 'key')."];
        }
        ret[CB_KEY_KEY] = components[0];
        ret[CB_VALUE_KEY] = components[1];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        ret[CB_KEY_KEY] = value[CB_KEY_KEY] ?: value[@"property"] ?: value[@"using"] ?: CB_EMPTY_STRING;
        ret[CB_VALUE_KEY] = value[CB_VALUE_KEY] ?: CB_EMPTY_STRING;
    }
    return ret;
}

+ (NSString *)name { return @"property"; }

- (XCUIElementQuery *)applyInternal:(XCUIElementQuery *)query {
    NSMutableString *predString = [NSMutableString string];
    NSDictionary *val = [QuerySelectorProperty parseValue:self.value];
    
    [predString appendFormat:@"%@ == '%@'", val[@"key"], val[@"value"]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    return [query matchingPredicate:predicate];
}
@end
