//
// RemoteElementViewConstraintManager.h
// iPhonto
//
// Created by Jason Cardwell on 1/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class   RemoteElementView;

/*
 * RemoteElementViewConstraintManager
 */
@interface RemoteElementViewConstraintManager:NSObject

///@name Creation

/**
 * Convenience method for creating a new constraint manager.
 *
 * @param view The view for which constraint manager will manage constraints
 *
 * @return Newly created constraint manager for the specified view
 */
+ (RemoteElementViewConstraintManager *)constraintManagerForView:(RemoteElementView *)view;

/**
 * Default constructor for a new constraint manager.
 *
 * @param view The view for which constraint manager will manage constraints
 *
 * @return Newly created constraint manager for the specified view
 */
- (id)initWithView:(RemoteElementView *)view;

@property (nonatomic, weak, readonly) RemoteElementView       * remoteElementView;
@property (nonatomic, assign, getter = shouldShrinkWrap) BOOL   shrinkWrap;

///@name Manipulating constraints

/**
 * Replace constraints with fresh set of constraints generated from model store.
 */
- (void)updateConstraints;

/**
 * Calls `translateSubelementView:translation:` for each member of `subelementViews` and then calls
 * `shrinkWrapSubelementViews` if `shrinkWrap` property has been set.
 *
 * @param subelementViews Views to be translated
 *
 * @param translation Amount by which views will be translated
 */
- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation;

/**
 * Modifies constraints to align the specified `sublementViews` to the top, left, bottom, right,
 * centerX, or centerY of `siblingView`.
 *
 * @param subelementViews Views to be aligned to `siblingView`
 *
 * @param siblingView View to which the `subelementViews` will be aligned
 *
 * @param attribute Attribute by which the alignment will be performed
 */
- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute;

/**
 * Alters model constraints to perform resizing the `subelementViews` to match the `siblingView`
 * relative to the attribute specified.
 *
 * @param subelementViews Views to be resized
 *
 * @param siblingView View whose width or height will be the basis for resizing
 *
 * @param attribute Specifies whether resizing will affect width or height
 */
- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute;

/**
 * Scales each of the `subelementViews` by sending `adjustConstraintsForScale:` to their
 * `constraintManager`.
 *
 * @param subelementViews Views to scale
 *
 * @param scale Amount by which to scale the views
 */
- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale;

@end

MSKIT_EXTERN_STRING   RemoteElementModelConstraintNametag;
@class                RemoteElementLayoutConstraint;

/*
 * RELayoutConstraint
 */
@interface RELayoutConstraint:NSLayoutConstraint

@property (nonatomic, strong) RemoteElementLayoutConstraint    * modelConstraint;
@property (nonatomic, weak) RemoteElementView                  * view;
@property (nonatomic, assign, readonly, getter = isValid) BOOL   valid;

/**
 * Constructor for new `RELayoutConstraint` objects.
 *
 * @param modelConstraint Model to be represented by the `RELayoutConstraint`
 *
 * @param view View to which the constraint will be added
 *
 * @return Newly created constraint for the specified view
 */
+ (RELayoutConstraint *)constraintWithModel:(RemoteElementLayoutConstraint *)modelConstraint
                                    forView:(RemoteElementView *)view;

@end
