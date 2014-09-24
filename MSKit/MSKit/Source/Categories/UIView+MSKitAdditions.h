//
//  UIView+MSKitAdditions.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
@import Foundation;
@import UIKit;

@interface UIView (MSKitAdditions)

+ (UIView *)currentResponder;
+ (UIView *)firstResponderInView:(UIView *)topView;
+ (CGRect)unionFrameForViews:(NSArray *)views;

- (NSString *)viewTreeDescription;
- (NSString *)viewTreeDescriptionWithProperties:(NSArray *)properties;

- (void)repositionFrameAtOrigin:(CGPoint)origin;
- (void)resizeFrameToSize:(CGSize)size anchored:(BOOL)anchored;
- (void)resizeBoundsToSize:(CGSize)size;
- (void)fitFrameToSize:(CGSize)size anchored:(BOOL)anchored;
- (void)fitBoundsToSize:(CGSize)size;
- (void)setAlignedCenter:(CGPoint)center;
- (NSArray *)subviewsOfKind:(Class)kind;
- (NSArray *)subviewsOfType:(Class)type;

+ (id)newForAutolayout;

- (id)initForAutoLayout;
- (id)initForAutoLayoutWithFrame:(CGRect)frame;

@property (nonatomic, strong) NSString * nametag;
@property (nonatomic, assign, readonly) CGFloat minX;
@property (nonatomic, assign, readonly) CGFloat minY;
@property (nonatomic, assign, readonly) CGFloat maxX;
@property (nonatomic, assign, readonly) CGFloat maxY;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, assign, readonly) CGFloat width;

- (UIView *)viewWithNametag:(NSString *)nametag;
- (UIView *)viewWithNametagPrefix:(NSString *)prefix;
- (UIView *)viewWithNametagSuffix:(NSString *)suffixx;
- (UIView *)viewMatching:(NSPredicate *)predicate;

- (NSArray *)viewsWithNametag:(NSString *)nametag;
- (NSArray *)viewsWithNametagPrefix:(NSString *)prefix;
- (NSArray *)viewsWithNametagSuffix:(NSString *)suffixx;
- (NSArray *)viewsMatching:(NSPredicate *)predicate;

- (UIView *)subviewWithNametag:(NSString *)nametag;
- (UIView *)subviewWithNametagPrefix:(NSString *)prefix;
- (UIView *)subviewWithNametagSuffix:(NSString *)suffixx;
- (UIView *)subviewMatching:(NSPredicate *)predicate;

- (NSArray *)subviewsWithNametag:(NSString *)nametag;
- (NSArray *)subviewsWithNametagPrefix:(NSString *)prefix;
- (NSArray *)subviewsWithNametagSuffix:(NSString *)suffixx;
- (NSArray *)subviewsMatching:(NSPredicate *)predicate;

- (UIGestureRecognizer *)gestureWithNametag:(NSString *)nametag;
- (UIGestureRecognizer *)gestureWithNametagPrefix:(NSString *)prefix;
- (UIGestureRecognizer *)gestureWithNametagSuffix:(NSString *)suffixx;
- (UIGestureRecognizer *)gestureMatching:(NSPredicate *)predicate;

- (NSArray *)gesturesWithNametag:(NSString *)nametag;
- (NSArray *)gesturesWithNametagPrefix:(NSString *)prefix;
- (NSArray *)gesturesWithNametagSuffix:(NSString *)suffixx;
- (NSArray *)gesturesMatching:(NSPredicate *)predicate;

- (NSLayoutConstraint *)constraintWithTag:(NSUInteger)tag;
- (NSArray *)constraintsWithTag:(NSUInteger)tag;

- (NSLayoutConstraint *)constraintWithNametag:(NSString *)nametag;
- (NSLayoutConstraint *)constraintWithNametagPrefix:(NSString *)prefix;
- (NSLayoutConstraint *)constraintWithNametagSuffix:(NSString *)suffix;
- (NSLayoutConstraint *)constraintWithIdentifier:(NSString *)identifier;
- (NSLayoutConstraint *)constraintWithIdentifierPrefix:(NSString *)prefix;
- (NSLayoutConstraint *)constraintWithIdentifierSuffix:(NSString *)suffix;
- (NSLayoutConstraint *)constraintMatching:(NSPredicate *)predicate;

- (NSArray *)constraintsWithNametag:(NSString *)nametag;
- (NSArray *)constraintsWithNametagPrefix:(NSString *)prefix;
- (NSArray *)constraintsWithNametagSuffix:(NSString *)suffix;
- (NSArray *)constraintsWithIdentifier:(NSString *)identifier;
- (NSArray *)constraintsWithIdentifierPrefix:(NSString *)prefix;
- (NSArray *)constraintsWithIdentifierSuffix:(NSString *)suffix;
- (NSArray *)constraintsMatching:(NSPredicate *)predicate;

- (void)replaceConstraintWithNametag:(NSString *)nametag withConstraint:(NSLayoutConstraint *)constraint;
- (void)replaceConstraintsWithNametag:(NSString *)nametag withConstraints:(NSArray *)constraints;
- (void)replaceConstraintsWithNametagPrefix:(NSString *)prefix withConstraints:(NSArray *)constraints;
- (void)replaceConstraintWithIdentifier:(NSString *)identifier withConstraint:(NSLayoutConstraint *)constraint;
- (void)replaceConstraintsWithIdentifier:(NSString *)identifier withConstraints:(NSArray *)constraints;
- (void)replaceConstraintsWithIdentifierPrefix:(NSString *)prefix withConstraints:(NSArray *)constraints;
- (NSArray *)constraintsOfType:(Class)type;
- (void)replaceConstraintsOfType:(Class)type withConstraints:(NSArray *)constraints;

- (UIImage *)snapshot;
- (UIImage *)blurredSnapshot;

- (void)constrainWithFormat:(NSString *)format identifier:(NSString *)identifier;
- (void)constrainWithFormat:(NSString *)format nametag:(NSString *)nametag;
- (void)constrainWithFormat:(NSString *)format; // Use 'self' as identifier to avoid issues with dictionary for views
- (void)constrainWithFormat:(NSString *)format views:(NSDictionary *)views; // Adds self to `views`
- (void)constrainWithFormat:(NSString *)format views:(NSDictionary *)views nametag:(NSString *)nametag;
- (void)constrainWithFormat:(NSString *)format views:(NSDictionary *)views identifier:(NSString *)identifier;

@end

@interface UIView (Debugger)
- (NSString *)recursiveDescription;
- (NSString *)prettyConstraintsDescription;
@end
