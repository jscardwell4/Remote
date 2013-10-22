//
//  UIView+MSKitAdditions.m
//  Remote
//
//  Created by Jason Cardwell on 4/12/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "MSKitMacros.h"
#import "MSKitGeometryFunctions.h"
#import "UIView+MSKitAdditions.h"
#import <objc/runtime.h>
#import "NSLayoutConstraint+MSKitAdditions.h"
#import "NSString+MSKitAdditions.h"
#import "NSArray+MSKitAdditions.h"
#import "UIGestureRecognizer+MSKitAdditions.h"
#import "UIImage+ImageEffects.h"

@implementation UIView (MSKitAdditions)


static const char * kUIViewNametagKey = "kUIViewNametagKey";

- (id)nametag {
    return objc_getAssociatedObject(self, (void *)kUIViewNametagKey);
}

- (void)setNametag:(NSString *)nametag {
    objc_setAssociatedObject(self, 
                             (void *)kUIViewNametagKey,
                             nametag, 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)subviewsOfKind:(Class)kind {
    return [self.subviews filteredArrayUsingPredicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
        return [obj isKindOfClass:kind];
    }];
}

- (NSArray *)subviewsOfType:(Class)type {
    return [self.subviews filteredArrayUsingPredicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
        return [obj isMemberOfClass:type];
    }];
}

+ (id)newForAutolayout {
    UIView * view = [self new];
    if (view) view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (id)initForAutoLayout {
    if ((self = [self init]))
        self.translatesAutoresizingMaskIntoConstraints = NO;
    return self;
}

- (id)initForAutoLayoutWithFrame:(CGRect)frame {
    if ((self = [self initWithFrame:frame]))
        self.translatesAutoresizingMaskIntoConstraints = NO;
    return self;
}

- (CGFloat)minX { return CGRectGetMinX(self.frame); }

- (CGFloat)minY { return CGRectGetMinY(self.frame); }

- (CGFloat)maxX { return CGRectGetMaxX(self.frame); }

- (CGFloat)maxY { return CGRectGetMaxY(self.frame); }

- (CGFloat)height { return self.bounds.size.height; }

- (CGFloat)width { return self.bounds.size.width; }

- (UIView *)viewWithNametag:(NSString *)nametag {
    
    if (!nametag)
        return nil;
    
    if ([self.nametag isEqualToString:nametag])
        return self;
    
    for (UIView * subview in self.subviews) {
        UIView * resultView = [subview viewWithNametag:nametag];
        if (resultView)
            return resultView;
    }
    
    return nil;
}

- (UIGestureRecognizer *)gestureWithNametag:(NSString *)nametag {

    if (!nametag)
        return nil;

    UIGestureRecognizer * gesture = [self.gestureRecognizers objectPassingTest:
                                     ^BOOL(UIGestureRecognizer * obj, NSUInteger idx)
                                     {
                                         return [obj.nametag isEqualToString:nametag];
                                     }];
    return gesture;
}

- (NSLayoutConstraint *)constraintWithTag:(NSUInteger)tag {
	for (NSLayoutConstraint * constraint in self.constraints) {
		if (constraint.tag == tag)
			return constraint;
	}
	return nil;
}

- (NSArray *)constraintsWithTag:(NSUInteger)tag {
	NSIndexSet * idxs = [self.constraints indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return (((NSLayoutConstraint *)obj).tag == tag);
	}];
	return idxs.count > 0 ? [self.constraints objectsAtIndexes:idxs] : nil;
}

- (NSLayoutConstraint *)constraintWithNametag:(NSString *)nametag {
	if (!nametag) return nil;
	for (NSLayoutConstraint * constraint in self.constraints) {
		if ([constraint.nametag isEqualToString:nametag])
			return constraint;
	}
	return nil;
}

- (NSArray *)constraintsWithNametag:(NSString *)nametag {
	if (!nametag) return nil;
	NSIndexSet * idxs = [self.constraints indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [((NSLayoutConstraint *)obj).nametag isEqualToString:nametag];
	}];	
	return idxs.count > 0 ? [self.constraints objectsAtIndexes:idxs] : nil;
}

- (NSArray *)constraintsWithNametagPrefix:(NSString *)prefix {
	if (!prefix) return nil;
	NSIndexSet * idxs = [self.constraints indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [((NSLayoutConstraint *)obj).nametag hasPrefix:prefix];
	}];
	return idxs.count > 0 ? [self.constraints objectsAtIndexes:idxs] : nil;
}

- (NSArray *)constraintsWithNametagSuffix:(NSString *)suffix {
	if (!suffix) return nil;
	NSIndexSet * idxs = [self.constraints indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [((NSLayoutConstraint *)obj).nametag hasSuffix:suffix];
	}];
	return idxs.count > 0 ? [self.constraints objectsAtIndexes:idxs] : nil;
}

- (void)replaceConstraintWithNametag:(NSString *)nametag withConstraint:(NSLayoutConstraint *)constraint {
	NSLayoutConstraint * c = [self constraintWithNametag:nametag];
	if (c) [self removeConstraint:c];
	if (constraint) {
		constraint.nametag = nametag;
		[self addConstraint:constraint];
	}
}

- (void)replaceConstraintsWithNametag:(NSString *)nametag withConstraints:(NSArray *)constraints {
	NSArray * c = [self constraintsWithNametag:nametag];
	if (c) [self removeConstraints:c];
	if (constraints) {
		[constraints setValue:nametag forKeyPath:@"nametag"];
		[self addConstraints:constraints];
	}
}

- (NSArray *)constraintsOfType:(Class)type {
    return [self.constraints
            filteredArrayUsingPredicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject isMemberOfClass:type];
            }];
}

- (void)replaceConstraintsOfType:(Class)type withConstraints:(NSArray *)constraints {
    [self removeConstraints:[self constraintsOfType:type]];
    [self addConstraints:constraints];
}

- (void)replaceConstraintsWithNametagPrefix:(NSString *)prefix withConstraints:(NSArray *)constraints {
    [self endEditing:YES];
	NSArray * c = [self constraintsWithNametagPrefix:prefix];
	if (c) [self removeConstraints:c];
	if (constraints) {
		for (NSLayoutConstraint * constraint in constraints) {
            if (![constraint.nametag hasPrefix:prefix])
                constraint.nametag = [prefix stringByAppendingFormat:@"-%@",constraint.nametag];
        }
		[self addConstraints:constraints];
	}
}


- (void)repositionFrameAtOrigin:(CGPoint)origin { 
    self.frame = CGRectReposition(self.frame, origin);
}

- (void)resizeFrameToSize:(CGSize)size anchored:(BOOL)anchored {
    self.frame = anchored
    ? CGRectAnchoredResize(self.frame, size)
    : CGRectResize(self.frame, size);
}

- (void)resizeBoundsToSize:(CGSize)size {
    self.bounds = CGRectResize(self.bounds, size);
}

+ (CGRect)unionFrameForViews:(NSArray *)views {
    if (!views || !views.count) {
        return CGRectZero;
    }
    CGRect unionFrame = ((UIView *)views[0]).frame;
    for (int i = 1; i < views.count; i++) {
        unionFrame = CGRectUnion(unionFrame, ((UIView *)views[i]).frame);
    }
    return unionFrame;
}

- (void)fitFrameToSize:(CGSize)size anchored:(BOOL)anchored {
    [self resizeFrameToSize:CGSizeAspectMappedToSize(self.frame.size, size, YES) anchored:anchored];
}

- (void)fitBoundsToSize:(CGSize)size {
    [self resizeBoundsToSize:CGSizeAspectMappedToSize(self.bounds.size, size, YES)];
}

+ (UIView *)currentResponder {
    return [UIView firstResponderInView:[SharedApp keyWindow]];
}

+ (UIView *)firstResponderInView:(UIView *)topView {
	__block BOOL stop = NO;
	__block UIView *firstResponder = nil;
	
	__block  void (^findFirstResponder)(UIView *, UIView **, BOOL *) = nil;
    __block  void (__weak ^weakFindFirstResponder)(UIView *, UIView **, BOOL *) = findFirstResponder;

    findFirstResponder =
	^(UIView *view, UIView **firstResponder, BOOL *stop) {
		if (!*stop && [view isFirstResponder]) {
			*stop = YES;
			*firstResponder = view;
		} else if (!*stop && [view.subviews count] > 0) {
			for (UIView * subview in view.subviews) {
				weakFindFirstResponder(subview, firstResponder, stop);
			}
		}
	};
    
	findFirstResponder(topView, &firstResponder, &stop);
	return firstResponder;
}

- (NSString *)viewTreeDescription {
    NSMutableString * outstring = [[NSMutableString alloc] init];
    
    __block void (^dumpView)(UIView *, int) = nil;
    __block void (__weak ^weakDumpView)(UIView *, int) = dumpView;
    dumpView = ^(UIView * view, int indent) {
        for (int i = 0; i < indent; i++)
            [outstring appendString:@"--"];
        
        [outstring appendFormat:@"[%2d] %@\n", indent, [[view class] description]];
        
        for (UIView * subview in view.subviews)
            weakDumpView(subview, indent + 1);
    };
    
    dumpView(self, 0);
    
    return outstring;
}

- (NSString *)viewTreeDescriptionWithProperties:(NSArray *)properties {
    NSMutableString * outstring = [[NSMutableString alloc] init];
    __block void (^dumpView)(UIView *, int) = nil;
    __block void (__weak ^weakDumpView)(UIView *, int) = dumpView;
    dumpView = ^(UIView * view, int indent) {
                for (int i = 0; i < indent; i++)
                    [outstring appendString:@"--"];

                NSMutableDictionary * propertyValues = [@{} mutableCopy];
                for (int i = 0; i < properties.count; i++) {
                    NSString * property = properties[i];
                    BOOL isBool = ([property characterAtIndex:property.length-1] == '?');
                    if (isBool)
                        property = [property substringToIndex:property.length-1];
                    
                    if ([view respondsToSelector:NSSelectorFromString(property)]) {
                        id  val = [view valueForKey:property];
                        if (ValueIsNil(val) || ([val respondsToSelector:@selector(count)] && [val count] == 0)) {
                            continue;
                        }
                        propertyValues[properties[i]] = (val
                                                         ? (isBool ? BOOLString([val boolValue]) : val)
                                                         : [NSNull null]);
                    }
                }

                NSString * valueDump = (propertyValues.count > 0
                                        ? [[propertyValues description] stringByReplacingOccurrencesOfRegEx:@"=[\t ]+" withString:@"= "]
                                        : @"");
                [outstring appendFormat:@"[%2d] %@%@%@\n",
                                        indent, ClassString([view class]),
                                        propertyValues.count > 0?@":":@"",
                                        valueDump];

                for (UIView * subview in view.subviews)
                    weakDumpView(subview, indent + 1);
            };

    dumpView(self, 0);

    return outstring;
}

- (void)setAlignedCenter:(CGPoint)center {
    self.center = center;
    self.frame = CGRectIntegral(self.frame);
}

- (NSString *)prettyConstraintsDescription
{
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view){
        return (view
                ? (view.nametag ?: $(@"<%@:%p>", ClassString([view class]), view))
                : (NSString *)nil);
    };

    NSArray * descriptions = [self.constraints arrayByMappingToBlock:
                              ^id(NSLayoutConstraint * constraint, NSUInteger idx)
                              {
                                  NSString     * firstItem     = itemNameForView(constraint.firstItem);
                                  NSString     * secondItem    = itemNameForView(constraint.secondItem);
                                  NSDictionary * substitutions = nil;

                                  if (firstItem && secondItem)
                                      substitutions = @{MSExtendedVisualFormatItem1Name : firstItem,
                                                        MSExtendedVisualFormatItem2Name : secondItem};
                                  else if (firstItem)
                                      substitutions = @{MSExtendedVisualFormatItem1Name : firstItem};
                                  
                                  return [constraint stringRepresentationWithSubstitutions:substitutions];

                              }];

    return $(@"Constraints for view '%@':\n%@",
             itemNameForView(self), [descriptions componentsJoinedByString:@"\n"]);
}

- (UIImage *)snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)blurredSnapshot
{
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);

    // There he is! The new API method
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];

    // Get the snapshot
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();

    // Now apply the blur effect using Apple's UIImageEffect category
    UIImage * blurredSnapshotImage = [snapshotImage applyLightEffect];

    // Or apply any other effects available in "UIImage+ImageEffects.h"
    // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];

    // Be nice and clean your mess up
    UIGraphicsEndImageContext();

    return blurredSnapshotImage;
}

@end

