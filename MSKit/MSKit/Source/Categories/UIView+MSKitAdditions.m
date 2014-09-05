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
  return [self.subviews filteredArrayUsingPredicateWithBlock:^BOOL (id obj, NSDictionary * bindings) {
    return [obj isKindOfClass:kind];
  }];
}

- (NSArray *)subviewsOfType:(Class)type {
  return [self.subviews filteredArrayUsingPredicateWithBlock:^BOOL (id obj, NSDictionary * bindings) {
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

- (UIView *)viewWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  if ([predicate evaluateWithObject:self]) return self;
  if (![self.subviews count]) return nil;
  return [self.subviews objectPassingTest:^BOOL(UIView * view, NSUInteger idx) {
    return [predicate evaluateWithObject:view];
  }];
}

- (NSArray *)viewsWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  return [[self.subviews arrayByAddingObject:self] objectsPassingTest:^BOOL(UIView * view, NSUInteger idx, BOOL *stop) {
    return [predicate evaluateWithObject:view];
  }];
}

- (UIView *)subviewWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  if (![self.subviews count]) return nil;
  return [self.subviews objectPassingTest:^BOOL(UIView * subview, NSUInteger idx) {
    return [predicate evaluateWithObject:subview];
  }];
}

- (NSArray *)subviewsWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  if (![self.subviews count]) return nil;
  return [self.subviews objectsPassingTest:^BOOL(UIView * subview, NSUInteger idx, BOOL *stop) { return [predicate evaluateWithObject:subview]; }];
}

- (UIView *)viewWithNametag:(NSString *)nametag {
  return [self viewWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (NSArray *)viewsWithNametag:(NSString *)nametag {
  return [self viewsWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (UIView *)subviewWithNametag:(NSString *)nametag {
  return [self subviewWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (NSArray *)subviewsWithNametag:(NSString *)nametag {
  return [self subviewsWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (UIView *)viewWithNametagPrefix:(NSString *)prefix {
  return [self viewWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (NSArray *)viewsWithNametagPrefix:(NSString *)prefix {
  return [self viewsWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (UIView *)subviewWithNametagPrefix:(NSString *)prefix {
  return [self subviewWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (NSArray *)subviewsWithNametagPrefix:(NSString *)prefix {
  return [self subviewsWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (UIView *)viewWithNametagSuffix:(NSString *)suffix {
  return [self viewWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasSuffix:suffix])];
}

- (NSArray *)viewsWithNametagSuffix:(NSString *)suffix {
  return [self viewsWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasSuffix:suffix])];
}

- (UIView *)subviewWithNametagSuffix:(NSString *)suffix {
  return [self subviewWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasSuffix:suffix])];
}

- (NSArray *)subviewsWithNametagSuffix:(NSString *)suffix {
  return [self subviewsWithNametagMatching:
          NSPredicateBlock([[(UIView *)evaluatedObject nametag] hasSuffix:suffix])];
}


- (UIGestureRecognizer *)gestureWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  if (![self.gestureRecognizers count]) return nil;

  return [self.gestureRecognizers objectPassingTest:^BOOL(UIGestureRecognizer * gesture, NSUInteger idx) {
    return [predicate evaluateWithObject:gesture];
  }];
}

- (NSArray *)gesturesWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  if (![self.gestureRecognizers count]) return nil;
  return [self.gestureRecognizers objectsPassingTest:^BOOL(UIGestureRecognizer * gesture, NSUInteger idx, BOOL *stop) {
    return [predicate evaluateWithObject:gesture];
  }];
}

- (UIGestureRecognizer *)gestureWithNametag:(NSString *)nametag {
  return [self gestureWithNametagMatching:
          NSPredicateBlock([[(UIGestureRecognizer *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (NSArray *)gesturesWithNametag:(NSString *)nametag {
  return [self gesturesWithNametagMatching:
          NSPredicateBlock([[(UIGestureRecognizer *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (UIGestureRecognizer *)gestureWithNametagPrefix:(NSString *)prefix {
  return [self gestureWithNametagMatching:
          NSPredicateBlock([[(UIGestureRecognizer *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (NSArray *)gesturesWithNametagPrefix:(NSString *)prefix {
  return [self gesturesWithNametagMatching:
          NSPredicateBlock([[(UIGestureRecognizer *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (UIGestureRecognizer *)gestureWithNametagSuffix:(NSString *)suffix {
  return [self gestureWithNametagMatching:
          NSPredicateBlock([[(UIGestureRecognizer *)evaluatedObject nametag] hasSuffix:suffix])];
}

- (NSArray *)gesturesWithNametagSuffix:(NSString *)suffix {
  return [self gesturesWithNametagMatching:
          NSPredicateBlock([[(UIGestureRecognizer *)evaluatedObject nametag] hasSuffix:suffix])];
}






- (NSLayoutConstraint *)constraintWithTag:(NSUInteger)tag {
  if (![self.constraints count]) return nil;
  return [self.constraints objectPassingTest:^BOOL(NSLayoutConstraint * constraint, NSUInteger idx) {
    return constraint.tag == tag;
  }];
}

- (NSArray *)constraintsWithTag:(NSUInteger)tag {
  if (![self.constraints count]) return nil;
  return [self.constraints objectsPassingTest:^BOOL(NSLayoutConstraint * constraint, NSUInteger idx, BOOL *stop) {
    return constraint.tag == tag;
  }];
}

- (NSLayoutConstraint *)constraintWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  if (![self.constraints count]) return nil;
  return [self.constraints objectPassingTest:^BOOL(NSLayoutConstraint * constraint, NSUInteger idx) {
    return [predicate evaluateWithObject:constraint];
  }];
}

- (NSArray *)constraintsWithNametagMatching:(NSPredicate *)predicate {
  if (!predicate) ThrowInvalidNilArgument(predicate);
  if (![self.constraints count]) return nil;
  return [self.constraints objectsPassingTest:^BOOL(NSLayoutConstraint * constraint, NSUInteger idx, BOOL *stop) {
    return [predicate evaluateWithObject:constraint];
  }];
}

- (NSLayoutConstraint *)constraintWithNametag:(NSString *)nametag {
  return [self constraintWithNametagMatching:
          NSPredicateBlock([[(NSLayoutConstraint *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (NSArray *)constraintsWithNametag:(NSString *)nametag {
  return [self constraintsWithNametagMatching:
          NSPredicateBlock([[(NSLayoutConstraint *)evaluatedObject nametag] isEqualToString:nametag])];
}

- (NSLayoutConstraint *)constraintWithNametagPrefix:(NSString *)prefix {
  return [self constraintWithNametagMatching:
          NSPredicateBlock([[(NSLayoutConstraint *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (NSArray *)constraintsWithNametagPrefix:(NSString *)prefix {
  return [self constraintsWithNametagMatching:
          NSPredicateBlock([[(NSLayoutConstraint *)evaluatedObject nametag] hasPrefix:prefix])];
}

- (NSLayoutConstraint *)constraintWithNametagSuffix:(NSString *)suffix {
  return [self constraintWithNametagMatching:
          NSPredicateBlock([[(NSLayoutConstraint *)evaluatedObject nametag] hasSuffix:suffix])];
}

- (NSArray *)constraintsWithNametagSuffix:(NSString *)suffix {
  return [self constraintsWithNametagMatching:
          NSPredicateBlock([[(NSLayoutConstraint *)evaluatedObject nametag] hasSuffix:suffix])];
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
          filteredArrayUsingPredicateWithBlock:^BOOL (id evaluatedObject, NSDictionary * bindings) {
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
        constraint.nametag = [prefix stringByAppendingFormat:@"-%@", constraint.nametag];
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
  __block BOOL     stop           = NO;
  __block UIView * firstResponder = nil;

  __block void (^findFirstResponder)(UIView *, UIView **, BOOL *) = nil;
  __block void(__weak ^ weakFindFirstResponder)(UIView *, UIView **, BOOL *) = findFirstResponder;

  findFirstResponder =
    ^(UIView * view, UIView ** firstResponder, BOOL * stop) {
    if (!*stop && [view isFirstResponder]) {
      *stop           = YES;
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
  __block void(__weak ^ weakDumpView)(UIView *, int) = dumpView;
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
  __block void      (^dumpView)(UIView *, int) = nil;
  __block void(__weak ^ weakDumpView)(UIView *, int) = nil;
  weakDumpView = dumpView = ^(UIView * view, int indent)
  {
    for (int i = 0; i < indent; i++)
      [outstring appendString:@"--"];

    NSMutableDictionary * propertyValues = [@{} mutableCopy];

    for (int i = 0; i < properties.count; i++) {
      NSString * property = properties[i];
      BOOL       isBool   = ([property characterAtIndex:property.length - 1] == '?');

      if (isBool)
        property = [property substringToIndex:property.length - 1];

      if ([view respondsToSelector:NSSelectorFromString(property)]) {
        id val = [view valueForKey:property];

        if (ValueIsNil(val) || ([val respondsToSelector:@selector(count)] && [val count] == 0)) {
          continue;
        }

        propertyValues[properties[i]] = (val
                                         ? (isBool ? BOOLString([val boolValue]) : val)
                                         : [NSNull null]);
      }
    }

    NSString * valueDump = (propertyValues.count > 0
                            ? [[propertyValues description] stringByReplacingRegEx:@"=[\t ]+" withString:@"= "]
                            : @"");
    [outstring appendFormat:@"[%2d] %@%@%@\n", indent, ClassString([view class]), propertyValues.count > 0 ? @":":@"", valueDump];

    for (UIView * subview in view.subviews) weakDumpView(subview, indent + 1);
  };

  dumpView(self, 0);

  return outstring;
}

- (void)setAlignedCenter:(CGPoint)center {
  self.center = center;
  self.frame  = CGRectIntegral(self.frame);
}

- (NSString *)prettyConstraintsDescription {
  static NSString *(^itemNameForView)(UIView *) = ^(UIView * view) {
    return (view
            ? (view.nametag ?: $(@"<%@:%p>", ClassString([view class]), view))
            : (NSString *)nil);
  };

  NSArray * descriptions = [self.constraints mapped:^id (NSLayoutConstraint * constraint, NSUInteger idx) {
    
    NSString     * firstItem     = itemNameForView(constraint.firstItem);
    NSString     * secondItem    = itemNameForView(constraint.secondItem);
    NSDictionary * substitutions = nil;

    if (firstItem && secondItem)
      substitutions = @{ MSExtendedVisualFormatItem1Name : firstItem,
                         MSExtendedVisualFormatItem2Name : secondItem };
    else if (firstItem)
      substitutions = @{ MSExtendedVisualFormatItem1Name : firstItem };

    return [constraint stringRepresentationWithSubstitutions:substitutions];

  }];

  return $(@"Constraints for view '%@':\n%@",
           itemNameForView(self), [descriptions componentsJoinedByString:@"\n"]);
}

- (UIImage *)snapshot {
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
  [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
  UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

- (UIImage *)blurredSnapshot {
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
