
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

#import <Foundation/Foundation.h>

@class XCSynthesizedEventRecord;
@class TouchPath;

/**
 Wrapper class to abstract XCTouchGesture and XCSynthesizedEventRecord, since they 
 share a very similar interface.
 
 See also TouchPath
 */
@interface CBXTouchEvent : NSObject

/**
 Static initializer.
 @param path The (first) touch path to perform.
 @return A new CBXTouchEvent instance filled with the `path`
 */
+ (instancetype)withTouchPath:(TouchPath *)path;

/**
 Adds an additional touch path to the gesture. 
 @param path New TouchPath to add
 */
- (void)addTouchPath:(TouchPath *)path;

/**
 Expose the underlying XCSynthesizedEventRecord object.
 @return XCSynthesizedEventRecord filled with the paths provided
 */
- (XCSynthesizedEventRecord *)event;
@end
