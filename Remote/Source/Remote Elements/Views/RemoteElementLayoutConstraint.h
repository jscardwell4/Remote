//
//  RemoteElementLayoutConstraint.h
//  Remote
//
//  Created by Jason Cardwell on 4/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import UIKit;
@import CoreData;
@import Foundation;
#import "Lumberjack/Lumberjack.h"
#import "MSKit/MSKit.h"
#import "MSRemoteMacros.h"

@class Constraint, RemoteElementView;

/*
 * RELayoutConstraint
 */
@interface RemoteElementLayoutConstraint:NSLayoutConstraint

@property (nonatomic, strong) Constraint                       * modelConstraint;
@property (readonly, weak)    RemoteElementView                * firstItem;
@property (readonly, weak)    RemoteElementView                * secondItem;
@property (nonatomic, weak)   RemoteElementView                * owner;
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
+ (RemoteElementLayoutConstraint *)constraintWithModel:(Constraint *)modelConstraint
                                               forView:(RemoteElementView *)view;

@end

