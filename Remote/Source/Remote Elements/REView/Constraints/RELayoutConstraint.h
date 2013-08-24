//
//  RELayoutConstraint.h
//  Remote
//
//  Created by Jason Cardwell on 4/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

@class REConstraint, REView;

/*
 * RELayoutConstraint
 */
@interface RELayoutConstraint:NSLayoutConstraint

@property (nonatomic, strong) REConstraint                     * modelConstraint;
@property (readonly, weak)    REView                           * firstItem;
@property (readonly, weak)    REView                           * secondItem;
@property (nonatomic, weak)   REView                           * owner;
@property (nonatomic, weak, readonly)   NSString               * uuid;
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
+ (RELayoutConstraint *)constraintWithModel:(REConstraint *)modelConstraint
                                    forView:(REView *)view;

@end

