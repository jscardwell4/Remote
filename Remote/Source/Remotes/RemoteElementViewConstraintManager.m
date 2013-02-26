//
// RemoteElementViewConstraintManager.m
// iPhonto
//
// Created by Jason Cardwell on 1/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementViewConstraintManager.h"
#import "RemoteElementConstraintManager.h"
#import "RemoteElementView_Private.h"
#import "RemoteElement_Private.h"
#import "RemoteElementLayoutConstraint.h"
#import "RemoteElementLayoutConfiguration.h"

static const int   msLogContext = REMOTE_F;
static const int   ddLogLevel   = LOG_LEVEL_DEBUG;

// static const int ddLogLevel = DefaultDDLogLevel;
#pragma unused(ddLogLevel,msLogContext)

static NSSet     * kAlignmentAttributes;
NSString * const   RemoteElementModelConstraintNametag = @"RemoteElementModelConstraintNametag";

@implementation RemoteElementViewConstraintManager {
    MSKVOReceptionist * _modelReceptionist;
    MSKVOReceptionist * _viewReceptionist;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Creation
///@name Creation
////////////////////////////////////////////////////////////////////////////////

/*
 * initialize
 */
+ (void)initialize {
    if (self == [RemoteElementViewConstraintManager class])
        kAlignmentAttributes = [@[@(NSLayoutAttributeBottom),
                                  @(NSLayoutAttributeTop),
                                  @(NSLayoutAttributeLeft),
                                  @(NSLayoutAttributeRight),
                                  @(NSLayoutAttributeCenterX),
                                  @(NSLayoutAttributeCenterY)] set];
}

/**
 * Convenience method for creating a new constraint manager.
 * @param view The view for which constraint manager will manage constraints
 * @return Newly created constraint manager for the specified view
 */
+ (RemoteElementViewConstraintManager *)constraintManagerForView:(RemoteElementView *)view {
    return [[self alloc]initWithView:view];
}

/**
 * Default constructor for a new constraint manager.
 * @param view The view for which constraint manager will manage constraints
 * @return Newly created constraint manager for the specified view
 */
- (id)initWithView:(RemoteElementView *)view {
    if ((self = [super init])) {
        __weak RemoteElementViewConstraintManager * weakSelf = self;

        self->_remoteElementView = view;
        self->_modelReceptionist =
            [MSKVOReceptionist
             receptionistForObject:_remoteElementView.remoteElement
                           keyPath:@"needsUpdateConstraints"
                           options:NSKeyValueObservingOptionNew
                           context:NULL
                           handler:^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx) {
                               NSManagedObjectContext * context = _remoteElementView.remoteElement.managedObjectContext;
                               [context performBlockAndWait:^{
                                            [context processPendingChanges];
                               }];

                               [weakSelf refreshConstraints];
                           }

                             queue:[NSOperationQueue mainQueue]];

        self->_viewReceptionist =
            [MSKVOReceptionist
             receptionistForObject:_remoteElementView
                           keyPath:@"needsUpdateConstraints"
                           options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                           context:NULL
                           handler:^(MSKVOReceptionist * r, NSString * k, id o, NSDictionary * c, void * ctx) {
                               [weakSelf refreshConstraints];
                           }

                             queue:[NSOperationQueue mainQueue]];
    }

    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Manipulating constraints
///@name Manipulating constraints
////////////////////////////////////////////////////////////////////////////////

/**
 * Replace constraints with fresh set of constraints generated from model store.
 */
- (void)refreshConstraints {
    // TODO: Only replace constraints that have changed, etc.
    NSArray * constraints = [[_remoteElementView.remoteElement.constraints allObjects]
                             arrayByMappingToBlock:^RELayoutConstraint * (RemoteElementLayoutConstraint * obj, NSUInteger idx) {
        return [RELayoutConstraint constraintWithModelConstraint:obj
                                                         forView:_remoteElementView];
    }];

    [_remoteElementView replaceConstraintsOfType:[RELayoutConstraint class] withConstraints:constraints];
}

/**
 * Alters model constraints to perform resizing the `subelementViews` to match the `siblingView`
 * relative to the attribute specified.
 * @param subelementViews Views to be resized
 * @param siblingView View whose width or height will be the basis for resizing
 * @param attribute Specifies whether resizing will affect width or height
 * @warning Not yet implemented
 */
- (void)resizeSubelements:(NSSet *)subelementViews
                toSibling:(RemoteElementView *)siblingView
                attribute:(NSLayoutAttribute)attribute
{
                    assert( NO);
                    assert( [subelementViews isSubsetOfSet:[_remoteElementView.subelementViews set]]
          && [_remoteElementView.subelementViews containsObject:siblingView]);
}

/**
 * Calls `translateSubelementView:translation:` for each member of `subelementViews` and then calls
 * `shrinkWrapSubelementViews` if `shrinkWrap` property has been set.
 * @param subelementViews Views to be translated
 * @param translation Amount by which views will be translated
 */
- (void)translateSubelements:(NSSet *)subelementViews translation:(CGPoint)translation {
    for (RemoteElementView * subelementView in subelementViews) [self translateSubelementView:subelementView translation:translation];

    if (_shrinkWrap) [self shrinkWrapSubelementViews];
}

/**
 * Modifies constraints to align the specified `sublementViews` to the top, left, bottom, right,
 * centerX, or centerY of `siblingView`.
 * @param subelementViews Views to be aligned to `siblingView`
 * @param siblingView View to which the `subelementViews` will be aligned
 * @param attribute Attribute by which the alignment will be performed
 */
- (void)alignSubelements:(NSSet *)subelementViews
               toSibling:(RemoteElementView *)siblingView
               attribute:(NSLayoutAttribute)attribute {
    // assert the views are all subelement views
                    assert([[subelementViews setByAddingObject:siblingView]
            isSubsetOfSet:[_remoteElementView.subelementViews set]]);

    // enumerate the views to adjust their constraints
    for (RemoteElementView * subelementView in subelementViews) {
        RemoteElement * element = subelementView.remoteElement;

        // adjust constraints that depend on the view being moved
        [self freezeConstraints:[element.dependentSiblingConstraints setRepresentation]
                  forAttributes:kAlignmentAttributes];

        // adjust size constraints to prevent move altering size calculations
        [self freezeSizeForSubelement:subelementView attribute:attribute];

        // get the constraints for the attribute to align already present on the subelement
        NSSet * constraintsForAttribute = [[element constraintsAffectingAxis:UILayoutConstraintAxisForAttribute(attribute)
                                                                       order:RELayoutConstraintFirstOrder]
                                           objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
            return (obj.firstAttribute == attribute);
        }];

        // handle constraints already present for the attribute to align
        if (!constraintsForAttribute.count) {
            // Remove conflicting constraint and add new constraint for attribute
            RemoteElementLayoutConstraint * c = [RemoteElementLayoutConstraint constraintWithItem:element
                                                                                        attribute:attribute
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:siblingView.remoteElement
                                                                                        attribute:attribute
                                                                                       multiplier:1.0f
                                                                                         constant:0.0f
                                                                                            owner:_remoteElementView.remoteElement];

                    assert(c);
            [self resolveConflictsForConstraint:c];
            element.layoutConfiguration[[NSLayoutConstraint pseudoNameForAttribute:attribute]] = @YES;
        } else {
                    assert(constraintsForAttribute.count == 1);
            // just adjust the current constraint
            [[constraintsForAttribute anyObject]
             setValuesForKeysWithDictionary:@{@"secondItem" : siblingView.remoteElement,
                                              @"multiplier" : @1,
                                              @"secondAttribute" : @(attribute),
                                              @"constant" : @0}
            ];
        }
    }

    if (_shrinkWrap) {
        [_remoteElementView setNeedsUpdateConstraints];
        [_remoteElementView updateConstraintsIfNeeded];
        [_remoteElementView setNeedsLayout];
        [_remoteElementView layoutIfNeeded];
        [self shrinkWrapSubelementViews];
    }
}  /* alignSubelements */

/**
 * Scales each of the `subelementViews` by sending `adjustConstraintsForScale:` to their
 * `constraintManager`.
 * @param subelementViews Views to scale
 * @param scale Amount by which to scale the views
 */
- (void)scaleSubelements:(NSSet *)subelementViews scale:(CGFloat)scale {
    for (RemoteElementView * subelementView in subelementViews) {
        [subelementView.constraintManager adjustConstraintsForScale:scale];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Removing dependencies
///@name Removing dependencies
////////////////////////////////////////////////////////////////////////////////

/**
 * Normalizes `remoteElementView.remoteElement.dependentChildConstraints` to have a multiplier of
 * `1.0`.
 */
- (void)removeMultipliers {
    NSDictionary * viewsByIdentifier = [NSDictionary dictionaryWithObjects:_remoteElementView.subelementViews
                                                                   forKeys:[_remoteElementView.subelementViews
                                                 valueForKeyPath:@"identifier"]];

    for (RemoteElementLayoutConstraint * constraint in _remoteElementView.remoteElement.dependentChildConstraints) {
        if (constraint.multiplier != 1) {
            constraint.multiplier = 1.0f;

            RemoteElementView * view = (RemoteElementView *)viewsByIdentifier[constraint.firstItem.identifier];

            switch (constraint.firstAttribute) {
                // TODO: Handle top, left, right and bottom alignment cases
                case NSLayoutAttributeBaseline :
                case NSLayoutAttributeBottom :
                    constraint.constant = CGRectGetMaxY(view.frame) - _remoteElementView.bounds.size.height;
                    break;

                case NSLayoutAttributeTop :
                    constraint.constant = view.frame.origin.y;
                    break;

                case NSLayoutAttributeCenterY :
                    constraint.constant = view.center.y - _remoteElementView.bounds.size.height / 2.0;
                    break;

                case NSLayoutAttributeLeft :
                case NSLayoutAttributeLeading :
                    constraint.constant = view.frame.origin.x;
                    break;

                case NSLayoutAttributeCenterX :
                    constraint.constant = view.center.x - _remoteElementView.bounds.size.width / 2.0;
                    break;

                case NSLayoutAttributeRight :
                case NSLayoutAttributeTrailing :
                    constraint.constant = CGRectGetMaxX(view.frame) - _remoteElementView.bounds.size.width;
                    break;

                case NSLayoutAttributeWidth :
                    constraint.constant = view.bounds.size.width - _remoteElementView.bounds.size.width;
                    break;

                case NSLayoutAttributeHeight :
                    constraint.constant = view.bounds.size.height - _remoteElementView.bounds.size.height;
                    break;

                case NSLayoutAttributeNotAnAttribute :
                default :
                    assert(NO);
                    break;
            } /* switch */
        }
    }
}             /* removeMultipliers */

/**
 * Modifies `remoteElementView` constraints such that width and height are not co-dependent.
 */
- (void)removeProportionLock {
    if (_remoteElementView.remoteElement.proportionLock) {
        _remoteElementView.remoteElement.proportionLock = NO;

        RemoteElementLayoutConstraint * c = [_remoteElementView.remoteElement.firstItemConstraints
                                             firstObjectPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
            return (obj.secondItem == _remoteElementView.remoteElement && (*stop = YES));
        }

                                            ];

                    assert(c);
        c.multiplier      = 1.0f;
        c.secondItem      = nil;
        c.secondAttribute = NSLayoutAttributeNotAnAttribute;
        c.constant        = (c.firstAttribute == NSLayoutAttributeHeight
                             ? _remoteElementView.bounds.size.height
                             : _remoteElementView.bounds.size.width);
        [_remoteElementView updateConstraintsIfNeeded];
    }
}

/**
 * Modifies constraints for the `subelementView` so that the width or height is constant.
 * @param subelementView View to freeze
 * @param attribute Specifies whether width or height is to be frozen
 */
- (void)freezeSizeForSubelement:(RemoteElementView *)subelementView
                      attribute:(NSLayoutAttribute)attribute {
    [subelementView.remoteElement
     freezeSize:subelementView.bounds.size
        forSubelement:subelementView.remoteElement
            attribute:attribute];
}  /* freezeSizeForSubelement */

/**
 * Modifies constraints such that any sibling co-dependencies are converted to parent-dependencies.
 * To be frozen, the `firstAttribute` of a constraint must be included in the set of `attributes`.
 * @param constraints Constraints to freeze
 * @param attributes `NSSet` of `NSLayoutAttributes` used to filter whether a constraint is frozen
 */
- (void)freezeConstraints:(NSSet *)constraints forAttributes:(NSSet *)attributes {
    for (RemoteElementLayoutConstraint * constraint in constraints) {
        if (![attributes containsObject:@(constraint.firstAttribute)]) continue;

        RemoteElementView * view = _remoteElementView[constraint.firstItem.identifier];

        [constraint.secondItem removeConstraintFromCache:constraint];
        constraint.secondItem = view.remoteElement.parentElement;
        constraint.multiplier = 1.0f;

        switch (constraint.firstAttribute) {
            case NSLayoutAttributeBottom :
                constraint.secondAttribute = NSLayoutAttributeBottom;
                constraint.constant        = CGRectGetMaxY(view.frame) - view.parentElementView.bounds.size.height;
                break;

            case NSLayoutAttributeTop :
                constraint.secondAttribute = NSLayoutAttributeTop;
                constraint.constant        = view.frame.origin.y;
                break;

            case NSLayoutAttributeLeft :
            case NSLayoutAttributeLeading :
                constraint.secondAttribute = NSLayoutAttributeLeft;
                constraint.constant        = view.frame.origin.x;
                break;

            case NSLayoutAttributeRight :
            case NSLayoutAttributeTrailing :
                constraint.secondAttribute = NSLayoutAttributeRight;
                constraint.constant        = CGRectGetMaxX(view.frame) - view.parentElementView.bounds.size.width;
                break;

            case NSLayoutAttributeCenterX :
                constraint.secondAttribute = NSLayoutAttributeCenterX;
                constraint.constant        = view.center.x - CGRectGetMidX(view.parentElementView.bounds);
                break;

            case NSLayoutAttributeCenterY :
                constraint.secondAttribute = NSLayoutAttributeCenterY;
                constraint.constant        = view.center.y - CGRectGetMidY(view.parentElementView.bounds);
                break;

            case NSLayoutAttributeWidth :
                constraint.secondAttribute = NSLayoutAttributeWidth;
                constraint.constant        = view.frame.size.width - view.parentElementView.bounds.size.width;
                break;

            case NSLayoutAttributeHeight :
                constraint.secondAttribute = NSLayoutAttributeHeight;
                constraint.constant        = view.frame.size.height - view.parentElementView.bounds.size.height;
                break;

            case NSLayoutAttributeBaseline :
            case NSLayoutAttributeNotAnAttribute :
                    assert(NO);
                break;
        } /* switch */
    }
}         /* freezeConstraints */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Size Adjustments
///@name Size Adjustments
////////////////////////////////////////////////////////////////////////////////

/**
 * Calculates the geometric changes necessary to resize the `remoteElementView` such that it is
 * exactly big enough to hold its subelement views.
 * @param size Upon return, `size` will point to a `CGSize` struct holding the calculated size to
 * shrink wrap
 * @param expand Upon return, `expand` will point to a `CGPoint` struct holding the amount of x and
 * y expansion
 * @param contract Upon return, `contract` will point a the `CGPoint` struct holding the amount of x
 * and y contraction
 * @param offset Upon return, `offset` will point to a `CGPoint` struct holding the x and y offset
 * from current size
 */
- (void)calculateShrinkWrap:(CGSize *)size
                     expand:(CGPoint *)expand
                   contract:(CGPoint *)contract
                     offset:(CGPoint *)offset {
    [_remoteElementView updateConstraintsIfNeeded];

    // contract or expand button group to match buttons
    ////////////////////////////////////////////////////////////////////////////////
    CGFloat   minX        = [[_remoteElementView.subelementViews valueForKeyPath:@"@min.minX"]floatValue];
    CGFloat   maxX        = [[_remoteElementView.subelementViews valueForKeyPath:@"@max.maxX"]floatValue];
    CGFloat   minY        = [[_remoteElementView.subelementViews valueForKeyPath:@"@min.minY"]floatValue];
    CGFloat   maxY        = [[_remoteElementView.subelementViews valueForKeyPath:@"@max.maxY"]floatValue];
    CGSize    currentSize = _remoteElementView.bounds.size;
    CGFloat   contractX   = (minX > 0                      // left edge needs to come in ?
                             ? -minX                       // move edge to left-most origin
                             : (maxX < currentSize.width   // right edge needs to push out?
                                ? currentSize.width - maxX // push out the difference
                                : 0.0f));
    CGFloat   contractY = (minY > 0                        // top edge needs to come in?
                           ? -minY                         // move edge to top-most origin
                           : (maxY < currentSize.height    // bottom edge needs to push out?
                              ? currentSize.height - maxY  // push out the difference
                              : 0.0f));
    CGFloat   expandX = (maxX > currentSize.width          // right edge needs to push out?
                         ? maxX - currentSize.width        // move edge out the difference
                         : (minX < 0                       // left edge needs to push out?
                            ? minX                         // move edge out the difference
                            : 0.0f));
    CGFloat   expandY = (maxY > currentSize.height         // top edge needs to push out?
                         ? maxY - currentSize.height       // move edge out the difference
                         : (minY < 0                       // bottom edge needs to push out?
                            ? minY                         // move edge out the difference
                            : 0.0f));
    CGFloat   offsetX = (contractX < 0
                         ? contractX
                         : (expandX < 0
                            ? -expandX
                            : 0.0f));
    CGFloat   offsetY = (contractY < 0
                         ? contractY
                         : (expandY < 0
                            ? -expandY
                            : 0.0f));

    *contract = CGPointMake(contractX, contractY);
    *expand   = CGPointMake(expandX, expandY);
    *offset   = CGPointMake(offsetX, offsetY);
    *size     = CGSizeMake(maxX - minX, maxY - minY);
}

/**
 * Makes the `remoteElementView` the specified size, handling constraint manipulation to avoid
 * conflicts.
 * @param size Size to make the `remoteElementView`
 */
- (void)resizeView:(CGSize)size {
    if (  _remoteElementView.remoteElement.proportionLock
       && _remoteElementView.bounds.size.width / _remoteElementView.bounds.size.height != size.width / size.height)
    {
        [self removeProportionLock];
                    assert(!_remoteElementView.remoteElement.proportionLock);
    }

    [_remoteElementView.parentElementView.constraintManager
     freezeConstraints:[_remoteElementView.remoteElement.dependentSiblingConstraints setRepresentation]
         forAttributes:kAlignmentAttributes];

    CGSize   deltaSize = CGSizeGetDelta(_remoteElementView.bounds.size, size);

    for (RemoteElementLayoutConstraint * constraint in _remoteElementView.remoteElement.firstItemConstraints) {
        switch (constraint.firstAttribute) {
            case NSLayoutAttributeLeft :
            case NSLayoutAttributeLeading :
            case NSLayoutAttributeRight :
            case NSLayoutAttributeTrailing :
                constraint.constant -= deltaSize.width / 2.0f;
                break;

            case NSLayoutAttributeWidth :

                if (constraint.isStaticConstraint) constraint.constant = size.width;
                else if (constraint.firstItem != constraint.secondItem) constraint.constant -= deltaSize.width;

                break;

            case NSLayoutAttributeCenterX :
                break;

            case NSLayoutAttributeBaseline :
            case NSLayoutAttributeBottom :
            case NSLayoutAttributeTop :
                constraint.constant -= deltaSize.height / 2.0f;
                break;

            case NSLayoutAttributeHeight :

                if (constraint.isStaticConstraint) constraint.constant = size.height;
                else if (constraint.firstItem != constraint.secondItem) constraint.constant -= deltaSize.height;

                break;

            case NSLayoutAttributeCenterY :
                break;

            case NSLayoutAttributeNotAnAttribute :
            default :
                    assert(NO);
                break;
        } /* switch */
    }

    [_remoteElementView setNeedsUpdateConstraints];
}         /* resizeView */

/**
 * Convenience method that makes calls to `calculateShrinkWrap:expand:contract:offset:`,
 * `resizeView:`, and `removeMultipliers`.
 * Called from `shrinkWrapSubelementViews`
 * @param size Upon return, `size` will point to a `CGSize` struct holding the calculated size to
 * shrink wrap
 * @param expand Upon return, `expand` will point to a `CGPoint` struct holding the amount of x and
 * y expansion
 * @param contract Upon return, `contract` will point a the `CGPoint` struct holding the amount of x
 * and y contraction
 * @param offset Upon return, `offset` will point to a `CGPoint` struct holding the x and y offset
 * from current size
 * @see calculateShrinkWrap:expand:contract:offset:
 */
- (void)sizeToFitSubelementViews:(CGSize *)newSize
                          expand:(CGPoint *)expand
                        contract:(CGPoint *)contract
                          offset:(CGPoint *)offset {
    [self calculateShrinkWrap:newSize expand:expand contract:contract offset:offset];

    if (CGSizeEqualToSize(*newSize, _remoteElementView.bounds.size)) return;

    // adjust size
    [self resizeView:*newSize];

    // normalize constraint multipliers
    [self removeMultipliers];
}

/**
 * Scales the `remoteElementView` by the specified amount.
 * @param scale Amount by which to scale the view
 */
- (void)adjustConstraintsForScale:(CGFloat)scale {
    CGSize   maxSize    = _remoteElementView.maximumSize;
    CGSize   minSize    = _remoteElementView.minimumSize;
    CGSize   scaledSize = CGSizeApplyScale(_remoteElementView.bounds.size, scale);
    CGSize   newSize    = (CGSizeContainsSize(maxSize, scaledSize)
                           ? (CGSizeContainsSize(scaledSize, minSize)
                              ? scaledSize
                              : minSize
                              )
                           : maxSize
                           );

    [self resizeView:newSize];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Translation/Alignment Adjustments
///@name Translation/Alignment Adjustments
////////////////////////////////////////////////////////////////////////////////

/**
 * Handles the translation for a single `subelementView` of `remoteElementView`.
 * @param subelementView View to translate
 * @param translation Amount to translate
 */
- (void)translateSubelementView:(RemoteElementView *)subelementView
                    translation:(CGPoint)translation {
    [self freezeConstraints:[subelementView.remoteElement.dependentSiblingConstraints setRepresentation]
              forAttributes:kAlignmentAttributes];

    for (RemoteElementLayoutConstraint * constraint in subelementView.remoteElement.firstItemConstraints) {
        switch (constraint.firstAttribute) {
            case NSLayoutAttributeBaseline :
            case NSLayoutAttributeBottom :
            case NSLayoutAttributeTop :
            case NSLayoutAttributeCenterY :
                constraint.constant += translation.y;
                break;

            case NSLayoutAttributeLeft :
            case NSLayoutAttributeLeading :
            case NSLayoutAttributeRight :
            case NSLayoutAttributeTrailing :
            case NSLayoutAttributeCenterX :
                constraint.constant += translation.x;
                break;

            case NSLayoutAttributeWidth :
            case NSLayoutAttributeHeight :
            case NSLayoutAttributeNotAnAttribute :
                break;
        }  /* switch */
    }
}

/**
 * Method used to "shrink wrap" the `remoteElementView` around its `subelementViews` by
 * being exactly as big as it needs to full hold them all.
 */
- (void)shrinkWrapSubelementViews {
    CGPoint   contract, expand, offset;
    CGSize    newSize;

    [self sizeToFitSubelementViews:&newSize expand:&expand contract:&contract offset:&offset];

    CGSize   delta = CGSizeGetDelta(newSize, _remoteElementView.bounds.size);

    // adjust constants to account for shift in button group size
    for (RemoteElementLayoutConstraint * constraint in _remoteElementView.remoteElement.dependentChildConstraints) {
        switch (constraint.firstAttribute) {
            // TODO: Handle all cases
            case NSLayoutAttributeBaseline :
            case NSLayoutAttributeBottom :
            case NSLayoutAttributeTop :
            case NSLayoutAttributeCenterY :
                constraint.constant += (contract.y == 0
                                        ? (offset.y
                                           ? offset.y / 2.0f
                                           : -expand.y / 2.0f
                                           )
                                        : offset.y - delta.height / 2.0f
                                        );
                break;

            case NSLayoutAttributeLeft :
            case NSLayoutAttributeLeading :
            case NSLayoutAttributeRight :
            case NSLayoutAttributeTrailing :
            case NSLayoutAttributeCenterX :
                constraint.constant += (contract.x == 0
                                        ? (offset.x
                                           ? offset.x / 2.0f
                                           : -expand.x / 2.0f
                                           )
                                        : offset.x - delta.width / 2.0f
                                        );
                break;

            case NSLayoutAttributeWidth :
                constraint.constant -= delta.width;
                break;

            case NSLayoutAttributeHeight :
                constraint.constant -= delta.height;
                break;

            case NSLayoutAttributeNotAnAttribute :
                    assert(NO);
                break;
        } /* switch */
    }
}         /* shrinkWrapSubelementViews */

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Conflict Resolution
///@name Conflict Resolution
////////////////////////////////////////////////////////////////////////////////

/**
 * Modifies `remoteElementView` constraints to avoid unsatisfiable conditions when adding the
 * specified constraint.
 * @param constraint `RemoteElementLayoutConstraint` whose addition may require conflict resolution
 */
- (void)resolveConflictsForConstraint:(RemoteElementLayoutConstraint *)constraint {
    RemoteElementView * subelementView = _remoteElementView[constraint.firstItem.identifier];
    NSArray           * additions      = nil;
    NSArray           * replacements   = [constraint.firstItem
                                          replacementCandidatesForAddingAttribute:constraint.firstAttribute
                                                                        additions:&additions];
    NSSet * removal = [subelementView.remoteElement.firstItemConstraints
                       objectsPassingTest:^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
        return [replacements containsObject:@(obj.firstAttribute)];
    }

                      ];

    for (RemoteElementLayoutConstraint * removedConstraint in removal) {
        [removedConstraint.managedObjectContext
         performBlockAndWait:^{
             [removedConstraint.managedObjectContext
              deleteObject:removedConstraint];
         }];
    }

    if (additions)
        for (NSNumber * n in additions) {
            switch ([n integerValue]) {
                case NSLayoutAttributeCenterX : {
                    RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint constraintWithItem:constraint.firstItem
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_remoteElementView.remoteElement
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0f
                                                                 constant:(CGRectGetMidX(subelementView.frame) - CGRectGetMidX(_remoteElementView.bounds))
                                                                    owner:_remoteElementView.remoteElement];

                    assert(c);
                    constraint.firstItem.layoutConfiguration[@"centerX"] = @YES;
                }
                break;

                case NSLayoutAttributeCenterY : {
                    RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint constraintWithItem:constraint.firstItem
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_remoteElementView.remoteElement
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0f
                                                                 constant:(CGRectGetMidY(subelementView.frame) - CGRectGetMidY(_remoteElementView.bounds))
                                                                    owner:_remoteElementView.remoteElement];

                    assert(c);
                    constraint.firstItem.layoutConfiguration[@"centerY"] = @YES;
                }
                break;

                case NSLayoutAttributeWidth : {
                    RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint constraintWithItem:constraint.firstItem
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:subelementView.bounds.size.width
                                                                    owner:subelementView.remoteElement];

                    assert(c);
                    constraint.firstItem.layoutConfiguration[@"width"] = @YES;
                }
                break;

                case NSLayoutAttributeHeight : {
                    RemoteElementLayoutConstraint * c =
                        [RemoteElementLayoutConstraint constraintWithItem:constraint.firstItem
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_remoteElementView.remoteElement
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1.0f
                                                                 constant:subelementView.bounds.size.height
                                                                    owner:subelementView.remoteElement];

                    assert(c);
                    constraint.firstItem.layoutConfiguration[@"height"] = @YES;
                }
                break;

                default :
                    assert(NO);
                    break;
            } /* switch */
        }
}             /* resolveConflictsForConstraint */

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RELayoutConstraint Implementation
////////////////////////////////////////////////////////////////////////////////

#define OBSERVE_INVALIDATING_PROPERTIES
@implementation RELayoutConstraint

/**
 * Constructor for new `RELayoutConstraint` objects.
 * @param modelConstraint Model to be represented by the `RELayoutConstraint`
 * @param view View to which the constraint will be added
 * @return Newly created constraint for the specified view
 */
+ (RELayoutConstraint *)constraintWithModelConstraint:(RemoteElementLayoutConstraint *)modelConstraint
                                              forView:(RemoteElementView *)view {
                    assert(  view
          && modelConstraint
          && ValueIsNotNil(modelConstraint.firstItem)
          && modelConstraint.firstAttribute
          && (  !modelConstraint.secondItem
             || [modelConstraint.secondItem.identifier isEqualToString:view.identifier]
             || view[modelConstraint.secondItem.identifier]));

    RemoteElementView * firstItem = ([modelConstraint.firstItem.identifier isEqualToString:view.identifier]
                                     ? view
                                     : view[modelConstraint.firstItem.identifier]);
    RemoteElementView * secondItem = (modelConstraint.secondItem
                                      ? ([modelConstraint.secondItem.identifier
                                          isEqualToString:view.identifier]
                                         ? view
                                         : view[modelConstraint.secondItem.identifier])
                                      : nil);
    RELayoutConstraint * constraint = [RELayoutConstraint constraintWithItem:firstItem
                                                                   attribute:modelConstraint.firstAttribute
                                                                   relatedBy:modelConstraint.relation
                                                                      toItem:secondItem
                                                                   attribute:modelConstraint.secondAttribute
                                                                  multiplier:modelConstraint.multiplier
                                                                    constant:modelConstraint.constant];

                    assert(constraint);

    constraint.priority        = modelConstraint.priority;
    constraint.tag             = modelConstraint.tag;
    constraint.nametag         = modelConstraint.key;
    constraint.modelConstraint = modelConstraint;
    constraint.view            = view;
    [modelConstraint addObserver:constraint
                      forKeyPath:@"constant"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
#ifdef OBSERVE_INVALIDATING_PROPERTIES
    [modelConstraint addObserver:constraint
                      forKeyPath:@"multiplier"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    [modelConstraint addObserver:constraint
                      forKeyPath:@"firstAttribute"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    [modelConstraint addObserver:constraint
                      forKeyPath:@"secondAttribute"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    [modelConstraint addObserver:constraint
                      forKeyPath:@"firstItem"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    [modelConstraint addObserver:constraint
                      forKeyPath:@"secondItem"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
#endif /* ifdef OBSERVE_INVALIDATING_PROPERTIES */
    return constraint;
}  /* constraintWithModelConstraint */

/*
 * Observes model properties. Changes to `constant` are reflected by the constraint. Any other
 * changes cause
 * the constraint to remove itself from its `view`.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == _modelConstraint) {
        if ([@"constant" isEqualToString : keyPath]) {
            id   value = change[NSKeyValueChangeNewKey];

            self.constant = ValueIsNotNil(value)
                            ? Float(value)
                            : 0.0f;
#ifdef OBSERVE_INVALIDATING_PROPERTIES
        } else if (_view) {
            [_view removeConstraint:self];
#endif
        }
    } else
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
}

- (NSString *)description {
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view) {
        return (view
                ? ([view isKindOfClass:[RemoteElementView class]]
                   ?[((RemoteElementView *)view).displayName camelCaseString]
                   : (view.accessibilityIdentifier
                      ? view.accessibilityIdentifier
                      :[NSString stringWithFormat:@"<%@:%p>", NSStringFromClass([view class]), view]
                      )
                   )
                : (NSString *)nil
                );
    };
    NSString * firstItem       = itemNameForView(self.firstItem);
    NSString * firstAttribute  = [NSLayoutConstraint pseudoNameForAttribute:self.firstAttribute];
    NSString * relation        = [NSLayoutConstraint pseudoNameForRelation:self.relation];
    NSString * secondItem      = itemNameForView(self.secondItem);
    NSString * secondAttribute = (self.secondAttribute != NSLayoutAttributeNotAnAttribute
                                  ?[NSLayoutConstraint pseudoNameForAttribute:self.secondAttribute]
                                  : nil);
    NSString * multiplier = (self.multiplier == 1.0f
                             ? nil
                             :[[NSString stringWithFormat:@"%f", self.multiplier]
                               stringByStrippingTrailingZeroes]);
    NSString * constant = (self.constant == 0.0f
                           ? nil
                           :[[NSString stringWithFormat:@"%f", self.constant]
                             stringByStrippingTrailingZeroes]);
    NSString * priority = (self.priority == UILayoutPriorityRequired
                           ? nil
                           :[NSString stringWithFormat:@"@%d", (int)self.priority]);
    NSMutableString * stringRep = [NSMutableString stringWithFormat:@"%@.%@ %@ ",
                                   firstItem, firstAttribute, relation];

    if (secondItem && secondAttribute) {
        [stringRep appendFormat:@"%@.%@", secondItem, secondAttribute];

        if (multiplier) [stringRep appendFormat:@" * %@", multiplier];

        if (constant) {
            if (self.constant < 0) {
                constant = [constant substringFromIndex:1];
                [stringRep appendString:@" - "];
            } else
                [stringRep appendString:@" + "];
        }
    }

    if (constant) [stringRep appendString:constant];

    if (priority) [stringRep appendFormat:@" %@", priority];

    return stringRep;
}  /* description */

- (void)dealloc {
    [_modelConstraint removeObserver:self forKeyPath:@"constant"];
#ifdef OBSERVE_INVALIDATING_PROPERTIES
    [_modelConstraint removeObserver:self forKeyPath:@"multiplier"];
    [_modelConstraint removeObserver:self forKeyPath:@"firstAttribute"];
    [_modelConstraint removeObserver:self forKeyPath:@"secondAttribute"];
    [_modelConstraint removeObserver:self forKeyPath:@"firstItem"];
    [_modelConstraint removeObserver:self forKeyPath:@"secondItem"];
#endif /* ifdef OBSERVE_INVALIDATING_PROPERTIES */
}

@end
