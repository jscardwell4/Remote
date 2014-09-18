//
//  MSKitGeometryFunctions.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "MSKitDefines.h"
@import CoreText;
@import CoreGraphics;
@import QuartzCore;
#import "NSString+MSKitAdditions.h"

MSSTATIC_INLINE NSString *NSStringFromCATransform3D(CATransform3D transform)
{
    NSUInteger       fieldWidth = 10;
    NSMutableArray * strings    = [NSMutableArray arrayWithCapacity:16];

    for (NSUInteger i = 0; i < 16; i++)
    {
        CGFloat   n = 0;

        switch (i)
        {
            case 0:
                n = transform.m11;
                break;

            case 1:
                n = transform.m12;
                break;

            case 2:
                n = transform.m13;
                break;

            case 3:
                n = transform.m14;
                break;

            case 4:
                n = transform.m21;
                break;

            case 5:
                n = transform.m22;
                break;

            case 6:
                n = transform.m23;
                break;

            case 7:
                n = transform.m24;
                break;

            case 8:
                n = transform.m31;
                break;

            case 9:
                n = transform.m32;
                break;

            case 10:
                n = transform.m33;
                break;

            case 11:
                n = transform.m34;
                break;

            case 12:
                n = transform.m41;
                break;

            case 13:
                n = transform.m42;
                break;

            case 14:
                n = transform.m43;
                break;

            case 15:
                n = transform.m44;
                break;
        }

        NSString * nString;

        if (fmod(n, 1) == 0)
            nString = [NSString stringWithFormat:@"% .0f", n];
        else
            nString = [NSString stringWithFormat:@"% .*f", (int)fieldWidth - 4, n];

        if (nString.length > fieldWidth)
            nString = [nString substringToIndex:fieldWidth];

        if (n != 0)
        {
            NSRange   trailingZeroRange = [nString rangeOfRegEx:@"0+$"];

            if (trailingZeroRange.location != NSNotFound)
                nString = [nString stringByReplacingCharactersInRange:trailingZeroRange withString:@""];
        }

        NSUInteger   padding      = fieldWidth - nString.length;
        NSUInteger   leftPadding  = padding/2;
        char         padCharacter = ' ';
        NSUInteger   rightPadding = padding - leftPadding;
        [strings addObject:[NSString stringWithFormat:@"%@%@%@",
                            [NSString stringWithCharacter:padCharacter count:leftPadding],
                            nString,
                            [NSString stringWithCharacter:padCharacter count:rightPadding]]];
    }

    NSArray * row1 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
    NSArray * row2 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 4)]];
    NSArray * row3 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(8, 4)]];
    NSArray * row4 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(12, 4)]];

    NSString * row1String = [row1 componentsJoinedByString:@"  "];
    NSString * row2String = [row2 componentsJoinedByString:@"  "];
    NSString * row3String = [row3 componentsJoinedByString:@"  "];
    NSString * row4String = [row4 componentsJoinedByString:@"  "];

    return [NSString stringWithFormat:
            @"%@\n%@\n%@\n%@", row1String, row2String, row3String, row4String];
}

MSSTATIC_INLINE NSString *NSStringFromCATransform3DT(CATransform3D transform)
{
    NSUInteger       fieldWidth = 10;
    NSMutableArray * strings    = [NSMutableArray arrayWithCapacity:16];

    for (NSUInteger i = 0; i < 16; i++)
    {
        CGFloat   n = 0;

        switch (i)
        {
            case 0:
                n = transform.m11;
                break;

            case 1:
                n = transform.m21;
                break;

            case 2:
                n = transform.m31;
                break;

            case 3:
                n = transform.m41;
                break;

            case 4:
                n = transform.m12;
                break;

            case 5:
                n = transform.m22;
                break;

            case 6:
                n = transform.m32;
                break;

            case 7:
                n = transform.m42;
                break;

            case 8:
                n = transform.m13;
                break;

            case 9:
                n = transform.m23;
                break;

            case 10:
                n = transform.m33;
                break;

            case 11:
                n = transform.m43;
                break;

            case 12:
                n = transform.m14;
                break;

            case 13:
                n = transform.m24;
                break;

            case 14:
                n = transform.m34;
                break;

            case 15:
                n = transform.m44;
                break;
        }

        NSString * nString;

        if (fmod(n, 1) == 0)
            nString = [NSString stringWithFormat:@"%.0f", n];
        else
            nString = [NSString stringWithFormat:@"% .*f", (int)fieldWidth-4, n];

        if (nString.length > fieldWidth)
            nString = [nString substringToIndex:fieldWidth];

        if (n != 0)
        {
            NSRange   trailingZeroRange = [nString rangeOfRegEx:@"0+$"];

            if (trailingZeroRange.location != NSNotFound)
                nString = [nString stringByReplacingCharactersInRange:trailingZeroRange withString:@""];
        }

        NSString * leftPaddingString  = @"";
        NSString * rightPaddingString = @"";

        if (nString.length < fieldWidth)
        {
            NSUInteger   padding      = fieldWidth - nString.length;
            NSUInteger   rightPadding = padding/2;
            NSUInteger   leftPadding  = padding - rightPadding;
            char         padCharacter = ' ';
            leftPaddingString = (leftPadding > 0
                                 ?[NSString stringWithCharacter:padCharacter
                                                          count:leftPadding]
                                 : @"");

            rightPaddingString = (rightPadding > 0
                                  ?[NSString stringWithCharacter:padCharacter
                                                           count:leftPadding]
                                  : @"");
        }

        [strings addObject:[NSString stringWithFormat:@"%@%@%@",
                            leftPaddingString,
                            nString,
                            rightPaddingString]];
    }

    NSArray * row1 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)]];
    NSArray * row2 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 4)]];
    NSArray * row3 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(8, 4)]];
    NSArray * row4 = [strings objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(12, 4)]];

    NSString * row1String = [row1 componentsJoinedByString:@"  "];
    NSString * row2String = [row2 componentsJoinedByString:@"  "];
    NSString * row3String = [row3 componentsJoinedByString:@"  "];
    NSString * row4String = [row4 componentsJoinedByString:@"  "];

    return [NSString stringWithFormat:
            @"%@\n%@\n%@\n%@", row1String, row2String, row3String, row4String];
}

typedef struct MSBoundary_s { CGFloat   lower, upper; } MSBoundary;

MSSTATIC_INLINE MSBoundary MSBoundaryMake(CGFloat lower, CGFloat upper)
{
    return (MSBoundary){lower,upper };
}

MSSTATIC_INLINE BOOL MSValueInBounds(CGFloat value, MSBoundary boundary)
{
    return (value >= boundary.lower && value <= boundary.upper);
}

MSSTATIC_INLINE NSUInteger MSBoundarySizeOfBoundary(MSBoundary boundary)
{
    return (MAX(boundary.upper,boundary.lower) - MIN(boundary.upper, boundary.lower));
}

MSSTATIC_INLINE NSString *NSStringFromMSBoundary(MSBoundary boundary)
{
    return [NSString stringWithFormat:@"(MSBoundary){.lower = %f, .upper = %f}",
            boundary.lower, boundary.upper];
}

typedef struct MSAspectRatio_s { CGFloat   x, y; } MSAspectRatio;

MSSTATIC_INLINE MSAspectRatio MSAspectRatioMake(CGFloat x, CGFloat y)
{
    return (MSAspectRatio){x,y };
}

MSSTATIC_INLINE MSAspectRatio MSAspectRatioFromSizeOverSize(CGSize a, CGSize b)
{
    return MSAspectRatioMake(a.width / b.width, a.height / b.height);
}

MSSTATIC_INLINE MSAspectRatio MSAspectRatioWithMinAxis(MSAspectRatio r)
{
    CGFloat   a = MIN(r.x, r.y);
    return MSAspectRatioMake(a, a);
}

MSSTATIC_INLINE MSAspectRatio MSAspectRatioWithMaxAxis(MSAspectRatio r)
{
    CGFloat   a = MAX(r.x, r.y);
    return MSAspectRatioMake(a, a);
}

#define MSAspectRatioOneToOne MSAspectRatioMake(1.0f, 1.0f)
#define MSAspectRatioUnpack(a) a.x, a.y

#define M_PI_3  M_PI/3.0        // 60º
#define M_PI_6  M_PI/6.0        // 30º
#define M_PI_12 M_PI/12.0    // 15º
#define M_PI_18 M_PI/18.0    // 10º
#define M_PI_36 M_PI/36.0    // 5º

MSSTATIC_INLINE CGFloat Delta(CGFloat a, CGFloat b)
{
    return a - b;
}

MSSTATIC_INLINE CGFloat CGPointGetDeltaX(CGPoint a, CGPoint b)
{
    return Delta(a.x, b.x);
}

MSSTATIC_INLINE CGFloat CGPointGetDeltaY(CGPoint a, CGPoint b)
{
    return Delta(a.y, b.y);
}

MSSTATIC_INLINE CGPoint CGPointGetDelta(CGPoint a, CGPoint b)
{
    return (CGPoint){.x = CGPointGetDeltaX(a, b), .y = CGPointGetDeltaY(a, b) };
}

#define CGPointDeltaPoint(a, b) CGPointGetDelta(a, b)

MSSTATIC_INLINE CGFloat DeltaABS(CGFloat a, CGFloat b)
{
    return ABS(a - b);
}

MSSTATIC_INLINE CGFloat CGPointGetDeltaXABS(CGPoint a, CGPoint b)
{
    return DeltaABS(a.x, b.x);
}

MSSTATIC_INLINE CGFloat CGPointGetDeltaYABS(CGPoint a, CGPoint b)
{
    return DeltaABS(a.y, b.y);
}

MSSTATIC_INLINE CGPoint CGPointGetDeltaABS(CGPoint a, CGPoint b)
{
    return (CGPoint){.x = CGPointGetDeltaXABS(a, b), .y = CGPointGetDeltaYABS(a, b) };
}

#define CGPointDeltaPointABS(a, b) CGPointGetDeltaABS(a, b)

MSSTATIC_INLINE CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

MSSTATIC_INLINE CGPoint CGPointOriginForSizeCenter(CGSize size, CGPoint center)
{
    return CGPointMake(center.x - size.width/2.0, center.y - size.height/2.0);
}

MSSTATIC_INLINE CGRect CGRectReposition(CGRect rect, CGPoint origin)
{
    return (CGRect){.origin = origin, .size = rect.size };
}

MSSTATIC_INLINE CGRect CGRectResize(CGRect rect, CGSize size)
{
    CGRect   newRect;
    newRect.origin = rect.origin;
    newRect.size   = size;

    return newRect;
}

MSSTATIC_INLINE CGRect CGRectSetHeight(CGRect rect, CGFloat h)
{
    return (CGRect){.origin = rect.origin, .size = CGSizeMake(rect.size.width, h) };
}

MSSTATIC_INLINE CGRect CGRectSetWidth(CGRect rect, CGFloat w)
{
    return (CGRect){.origin = rect.origin, .size = CGSizeMake(w, rect.size.height) };
}

MSSTATIC_INLINE CGRect CGRectAnchoredResize(CGRect rect, CGSize size)
{
    CGPoint   rectCenter = CGRectGetCenter(rect);
    CGRect    newRect    = CGRectResize(rect, size);
    CGPoint   newCenter  = CGRectGetCenter(newRect);

    CGFloat   xDiff = rectCenter.x - newCenter.x;
    CGFloat   yDiff = rectCenter.y - newCenter.y;

    return CGRectOffset(newRect, xDiff, yDiff);
}

MSSTATIC_INLINE CGRect CGRectWithSizeAndCenter(CGSize size, CGPoint center)
{
    return (CGRect){.origin = CGPointOriginForSizeCenter(size, center), .size = size };
}

MSSTATIC_INLINE CGRect CGRectCenteredOnPoint(CGRect rect, CGPoint point)
{
    return (CGRect) {
               .origin = CGPointOriginForSizeCenter(rect.size, point),
               .size   = rect.size
    };
}

#define CGSizeMax CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
#define CGSizeUnpack(s)  s.width, s.height
#define CGPointUnpack(p) p.x, p.y

MSSTATIC_INLINE CGSize CGSizeAddedToSize(CGSize a, CGSize b)
{
    return (CGSize){.width = a.width + b.width, .height = a.height + b.height };
}

MSSTATIC_INLINE CGSize CGSizeApplyScale(CGSize size, CGFloat scale)
{
    return CGSizeMake(size.width*scale, size.height*scale);
}

MSSTATIC_INLINE BOOL CGSizeContainsSize(CGSize a, CGSize b)
{
    return (a.width >= b.width && a.height >= b.height);
}

/*
 * MSSTATIC_INLINE CGSize CGSizeFitToSize(CGSize s1, CGSize s2) {
 *  if (CGSizeContainsSize(s2, s1)) return s1;
 *  CGSize s = s1;
 *  if (s1.height > s2.height) {
 *      CGFloat scale = s2.height / s1.height;
 *      s.width *= scale;
 *      s.height *= scale;
 *  }
 *
 *  if (s1.width >= s2.width) {
 *      CGFloat scale = s2.width / s1.width;
 *      s.width *= scale;
 *      s.height *= scale;
 *  }
 *  return s;
 * }
 */

/*
MSSTATIC_INLINE CGSize CGSizeFitToSize(CGSize s1, CGSize s2)
{
    if (CGSizeContainsSize(s2, s1)) return s1;

    CGSize   s = s1;

    if (s1.height > s2.height)
    {
        CGFloat   scale = s2.height / s1.height;
        s.width  *= scale;
        s.height *= scale;
    }

    if (s1.width >= s2.width)
    {
        CGFloat   scale = s2.width / s1.width;
        s.width  *= scale;
        s.height *= scale;
    }

    return s;
}
*/

MSSTATIC_INLINE CGSize CGSizeUnionSize(CGSize a, CGSize b)
{
    return CGSizeMake(MAX(a.width, b.width), MAX(a.height, b.height));
}

MSSTATIC_INLINE CGSize CGSizeGetDelta(CGSize a, CGSize b)
{
    return CGSizeMake(a.width - b.width, a.height - b.height);
}

#define CGSizeMakeSquare(v) CGSizeMake(v, v)

MSSTATIC_INLINE CGFloat CGSizeMinAxis(CGSize size)
{
    return MIN(size.width, size.height);
}

MSSTATIC_INLINE CGFloat CGSizeMaxAxis(CGSize size)
{
    return MAX(size.width, size.height);
}

MSSTATIC_INLINE CGFloat CGSizeGetArea(CGSize size)
{
    return size.width * size.height;
}

MSSTATIC_INLINE BOOL CGSizeGreaterThanSize(CGSize s1, CGSize s2)
{
    return (CGSizeGetArea(s1) > CGSizeGetArea(s2));
}

MSSTATIC_INLINE BOOL CGSizeLessThanSize(CGSize s1, CGSize s2)
{
    return (CGSizeGetArea(s1) < CGSizeGetArea(s2));
}

MSSTATIC_INLINE BOOL CGSizeGreaterThanOrEqualToSize(CGSize s1, CGSize s2)
{
    return (CGSizeGreaterThanSize(s1, s2) || CGSizeEqualToSize(s1, s2));
}

MSSTATIC_INLINE BOOL CGSizeLessThanOrEqualToSize(CGSize s1, CGSize s2)
{
    return (CGSizeLessThanSize(s1, s2) || CGSizeEqualToSize(s1, s2));
}

MSSTATIC_INLINE CGSize CGSizeMaxSize(CGSize s1, CGSize s2)
{
    return (CGSizeGetArea(s1) > CGSizeGetArea(s2) ? s1 : s2);
}

MSSTATIC_INLINE CGSize CGSizeMinSize(CGSize s1, CGSize s2)
{
    return (CGSizeGetArea(s1) < CGSizeGetArea(s2) ? s1 : s2);
}

MSSTATIC_INLINE CGSize CGSizeAspectMappedToWidth(CGSize s, CGFloat w)
{
    return CGSizeMake(w, (w * s.height)/s.width);
}

MSSTATIC_INLINE CGSize CGSizeAspectMappedToHeight(CGSize s, CGFloat h)
{
    return CGSizeMake((h * s.width)/s.height, h);
}

MSSTATIC_INLINE CGSize CGSizeAspectMappedToSize(CGSize s1, CGSize s2, BOOL bound)
{
    CGSize   sw = CGSizeAspectMappedToWidth(s1, s2.width);
    CGSize   sh = CGSizeAspectMappedToHeight(s1, s2.height);
    CGSize   s  = (bound ? CGSizeMinSize(sw, sh) : CGSizeMaxSize(sw, sh));
//    NSLog(@"%s\n\ts1:%@\n\ts2:%@\n\tbound? %@\n\tsw:%@\n\tsh:%@\n\ts:%@",
//          __PRETTY_FUNCTION__,
//          CGSizeString(s1),
//          CGSizeString(s2),
//          (bound? @"YES" : @"NO"),
//          CGSizeString(sw),
//          CGSizeString(sh),
//          CGSizeString(s));
    return s;
}

#pragma mark - CGAffineTransform

MSSTATIC_INLINE CGAffineTransform CGAffineTransformMakeScaleTranslate(CGFloat sx,
                                                                          CGFloat sy,
                                                                          CGFloat dx,
                                                                          CGFloat dy)
{
    return CGAffineTransformMake(sx, 0.f, 0.f, sy, dx, dy);
}

MSSTATIC_INLINE CGAffineTransform CGAffineTransformMakeShear(CGFloat shearX, CGFloat shearY)
{
    return CGAffineTransformMake(1.f, shearY, shearX, 1.f, 0.f, 0.f);
}

MSSTATIC_INLINE CGAffineTransform CGAffineTransformShear(CGAffineTransform transform,
                                                             CGFloat           shearX,
                                                             CGFloat           shearY)
{
    CGAffineTransform   sheared = CGAffineTransformMakeShear(shearX, shearY);
    return CGAffineTransformConcat(transform, sheared);
}

MSSTATIC_INLINE CGFloat CGAffineTransformGetDeltaX(CGAffineTransform transform)
{
    return transform.tx;
}

MSSTATIC_INLINE CGFloat CGAffineTransformGetDeltaY(CGAffineTransform transform)
{
    return transform.ty;
}

MSSTATIC_INLINE CGFloat CGAffineTransformGetScaleX(CGAffineTransform transform)
{
    return sqrtf((transform.a * transform.a) + (transform.c * transform.c));
}

MSSTATIC_INLINE CGFloat CGAffineTransformGetScaleY(CGAffineTransform transform)
{
    return sqrtf((transform.b * transform.b) + (transform.d * transform.d));
}

MSSTATIC_INLINE CGFloat CGAffineTransformGetShearX(CGAffineTransform transform)
{
    return transform.b;
}

MSSTATIC_INLINE CGFloat CGAffineTransformGetShearY(CGAffineTransform transform)
{
    return transform.c;
}

MSSTATIC_INLINE CGFloat CGPointAngleBetweenPoints(CGPoint first, CGPoint second)
{
    CGFloat   dy = second.y - first.y;
    CGFloat   dx = second.x - first.x;
    return atan2f(dy, dx);
}

MSSTATIC_INLINE CGFloat CGAffineTransformGetRotation(CGAffineTransform transform)
{
    // No exact way to get rotation out without knowing order of all previous operations
    // So, we'll cheat. We'll apply the transformation to two points and then determine the
    // angle betwen those two points

    CGPoint   testPoint1   = CGPointMake(-100.f, 0.f);
    CGPoint   testPoint2   = CGPointMake(100.f, 0.f);
    CGPoint   transformed1 = CGPointApplyAffineTransform(testPoint1, transform);
    CGPoint   transformed2 = CGPointApplyAffineTransform(testPoint2, transform);
    return CGPointAngleBetweenPoints(transformed1, transformed2);
}

#pragma mark - CATransform3D

MSSTATIC_INLINE CATransform3D CATransform3DMakePerspective(CGFloat eyeDistance)
{
    return (CATransform3D){1,0,0,0,0,1,0,0,0,0,1,-1./eyeDistance,0,0,0,1 };
}

#pragma mark - Conversions

MSSTATIC_INLINE CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180.0;
}

MSSTATIC_INLINE CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180.0 / M_PI;
}

#pragma mark - Core Text

MSSTATIC_INLINE CGFloat GetLineHeightForFont(CTFontRef iFont)
{
    CGFloat   lineHeight = 0.0;

    if (iFont == NULL)
        return 0.0;

    // Get the ascent from the font, already scaled for the font's size
    lineHeight += CTFontGetAscent(iFont);

    // Get the descent from the font, already scaled for the font's size
    lineHeight += CTFontGetDescent(iFont);

    // Get the leading from the font, already scaled for the font's size
    lineHeight += CTFontGetLeading(iFont);

    return lineHeight;
}

MSSTATIC_INLINE CGRect CGRectBoundToRect(CGRect slave, CGRect master)
{
    CGFloat   slaveMinX  = CGRectGetMinX(slave);
    CGFloat   slaveMaxX  = CGRectGetMaxX(slave);
    CGFloat   slaveMinY  = CGRectGetMinY(slave);
    CGFloat   slaveMaxY  = CGRectGetMaxY(slave);
    CGFloat   masterMinX = CGRectGetMinX(master);
    CGFloat   masterMaxX = CGRectGetMaxX(master);
    CGFloat   masterMinY = CGRectGetMinY(master);
    CGFloat   masterMaxY = CGRectGetMaxY(master);

    CGFloat   pushX = (slaveMinX >= masterMinX
                       ? 0.0f
                       : masterMinX - slaveMinX);
    CGFloat   pushY = (slaveMinY >= masterMinY
                       ? 0.0f
                       : masterMinY - slaveMinY);
    CGFloat   pullX = (slaveMaxX <= masterMaxX
                       ? 0.0f
                       : slaveMaxX - masterMaxX);
    CGFloat   pullY = (slaveMaxY <= masterMaxY
                       ? 0.0f
                       : slaveMaxY - masterMaxY);

    return CGRectMake(slave.origin.x + pushX + pullX,
                      slave.origin.y + pushY + pullY,
                      MIN(slave.size.width + pushX + pullX,  slave.size.width),
                      MIN(slave.size.height + pushY + pullY, slave.size.height));
}
