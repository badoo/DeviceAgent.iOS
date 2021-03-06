
#import "Gesture+Options.h"
#import "CBXConstants.h"
#import "GestureConfiguration.h"

@implementation Gesture (Options)

- (int)repetitions {
    return [self getInt:CBX_REPETITIONS_KEY default:CBX_DEFAULT_REPETITIONS];
}

- (int)numFingers {
    return [self getInt:CBX_NUM_FINGERS_KEY default:CBX_DEFAULT_NUM_FINGERS];
}

- (float)duration {
    return [self getFloat:CBX_DURATION_KEY default:CBX_DEFAULT_DURATION];
}

- (float)dragFirstTouchHoldDuration {
    return [self getFloat:CBX_FIRST_TOUCH_HOLD_DURATION_DRAG_KEY default:0.0];
}

- (BOOL)allowDragToHaveInertia {
    return [self boolForKey:CBX_ALLOW_INERTIA_DRAG_KEY
                    default:CBX_DEFAULT_ALLOW_INERTIA_IN_DRAG];
}

- (float)rotateDuration {
    return [self getFloat:CBX_DURATION_KEY default:CBX_DEFAULT_ROTATE_DURATION];
}

- (float)pinchAmount {
    return [self getFloat:CBX_PINCH_AMOUNT_KEY default:CBX_DEFAULT_PINCH_AMOUNT];
}

- (float)degrees {
    return [self getFloat:CBX_DEGREES_KEY default:CBX_DEFAULT_DEGREES];
}

- (float)radius {
    return [self getFloat:CBX_RADIUS_KEY default:CBX_DEFAULT_RADIUS];
}

- (float)rotationStart {
    return [self getFloat:CBX_ROTATION_START_KEY default:CBX_DEFAULT_ROTATION_START];
}

- (NSString *)pinchDirection {
    return [self getString:CBX_PINCH_DIRECTION_KEY default:CBX_DEFAULT_PINCH_DIRECTION];
}

- (NSString *)rotateDirection {
    return [self getString:CBX_ROTATION_DIRECTION_KEY default:CBX_DEFAULT_ROTATION_DIRECTION];
}


#pragma mark - Helpers

- (float)getFloat:(NSString *)key default:(float)defaultValue {
    return [self.gestureConfiguration has:key] ?
    [self.gestureConfiguration[key] floatValue] :
    defaultValue;
}

- (int)getInt:(NSString *)key default:(int)defaultValue {
    return [self.gestureConfiguration has:key] ?
    [self.gestureConfiguration[key] intValue] :
    defaultValue;
}

- (NSString *)getString:(NSString *)key default:(NSString *)defaultValue {
    return [self.gestureConfiguration has:key] ?
    self.gestureConfiguration[key] :
    defaultValue;
}

- (BOOL)boolForKey:(NSString *)key default:(BOOL)defaultValue {
    return [self.gestureConfiguration has:key] ?
    [self.gestureConfiguration[key] boolValue] :
    defaultValue;
}

@end
