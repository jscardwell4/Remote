//
//  UIView+MSKitAdditions.h
//  Remote
//
//  Created by Jason Cardwell on 4/12/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
- (UIGestureRecognizer *)gestureWithNametag:(NSString *)nametag;
- (NSLayoutConstraint *)constraintWithTag:(NSUInteger)tag;
- (NSArray *)constraintsWithTag:(NSUInteger)tag;
- (NSLayoutConstraint *)constraintWithNametag:(NSString *)nametag;
- (NSArray *)constraintsWithNametag:(NSString *)nametag;
- (NSArray *)constraintsWithNametagPrefix:(NSString *)prefix;
- (NSArray *)constraintsWithNametagSuffix:(NSString *)suffix;
- (void)replaceConstraintWithNametag:(NSString *)nametag
                      withConstraint:(NSLayoutConstraint *)constraint;
- (void)replaceConstraintsWithNametag:(NSString *)nametag withConstraints:(NSArray *)constraints;
- (void)replaceConstraintsWithNametagPrefix:(NSString *)prefix withConstraints:(NSArray *)constraints;
- (NSArray *)constraintsOfType:(Class)type;
- (void)replaceConstraintsOfType:(Class)type withConstraints:(NSArray *)constraints;
- (UIImage *)snapshot;
- (UIImage *)blurredSnapshot;
@end

@interface UIView (Debugger)
- (NSString *)recursiveDescription;
- (NSString *)prettyConstraintsDescription;
@end