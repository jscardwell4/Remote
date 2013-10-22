//
//  NSValue+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 10/11/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSKitGeometryFunctions.h"

#define NSValueWithCGPoint(p)           [NSValue valueWithCGPoint:p]
#define NSValueWithCGSize(s)            [NSValue valueWithCGSize:s]
#define NSValueWithCGRect(r)            [NSValue valueWithCGRect:r]
#define NSValueWithCGAffineTransform(t) [NSValue valueWithCGAffineTransform:t]
#define NSValueWithUIEdgeInsets(i)      [NSValue valueWithUIEdgeInsets:i]
#define NSValueWithNSRange(r)           [NSValue valueWithRange:r]
#define NSValueWithPointer(p)           [NSValue valueWithPointer:p]
#define NSValueWithObjectPointer(p)     [NSValue valueWithPointer:(__bridge const void *)p]

#define CGPointValue(v)           [v CGPointValue]
#define CGSizeValue(v)            [v CGSizeValue]
#define CGRectValue(v)            [v CGRectValue]
#define CGAffineTransformValue(v) [v CGAffineTransformValue]
#define UIEdgeInsetsValue(v)      [v UIEdgeInsetsValue]
#define NSRangeValue(v)           [v rangeValue]
#define CGFloatValue(v)           [(NSNumber *)v floatValue]
#define NSIntegerValue(v)         [v integerValue]
#define NSUIntegerValue(v)        [v unsignedIntegerValue]
#define BOOLValue(v)              [v boolValue]
#define INTValue(v)               [v intValue]
#define PointerValue(v)           [v pointerValue]

@interface NSValue (MSKitAdditions)

+ (NSValue *)valueWithMSBoundary:(MSBoundary)boundary;
- (MSBoundary)MSBoundaryValue;

@end
