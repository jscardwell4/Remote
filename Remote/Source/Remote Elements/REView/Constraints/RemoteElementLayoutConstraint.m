//
//  RemoteElementLayoutConstraint.m
//  Remote
//
//  Created by Jason Cardwell on 4/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementLayoutConstraint.h"
#import "Constraint.h"
#import "RemoteElementView.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RELayoutConstraint Implementation
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementLayoutConstraint ()

@property (nonatomic, assign, readwrite, getter = isValid) BOOL   valid;
@property (nonatomic, strong) MSContextChangeReceptionist       * contextReceptionist;
@property (nonatomic, strong) MSKVOReceptionist                 * kvoReceptionist;

@end

@implementation RemoteElementLayoutConstraint

+ (RemoteElementLayoutConstraint *)constraintWithModel:(Constraint *)modelConstraint
                                  forView:(RemoteElementView *)view
{
    if (!modelConstraint || modelConstraint.owner != view.model) return nil;

    RemoteElementView * firstItem = view[modelConstraint.firstItem.uuid];
    RemoteElementView * secondItem = ([modelConstraint isStaticConstraint]
                           ? nil
                           : view[modelConstraint.secondItem.uuid]);

    RemoteElementLayoutConstraint * constraint = [RemoteElementLayoutConstraint
                                       constraintWithItem:firstItem
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
    constraint.owner            = view;
    constraint.valid           = YES;
    constraint.modelConstraint = modelConstraint;



    return constraint;
}

- (void)setModelConstraint:(Constraint *)modelConstraint {

    _modelConstraint = modelConstraint;

    __weak RemoteElementLayoutConstraint * weakself = self;

    _contextReceptionist = [MSContextChangeReceptionist
                            receptionistForObject:_modelConstraint
                            notificationName:NSManagedObjectContextObjectsDidChangeNotification
                            queue:MainQueue
                            updateHandler:^(MSContextChangeReceptionist *receptionist,
                                            NSManagedObject *object)
                            {
                                Constraint * constraint =
                                (Constraint *)object;

                                if (   constraint.owner != weakself.owner.model
                                    || constraint.firstItem != weakself.firstItem.model
                                    || constraint.firstAttribute != weakself.firstAttribute
                                    || constraint.relation != weakself.relation
                                    || constraint.secondItem != weakself.secondItem.model
                                    || constraint.secondAttribute != weakself.secondAttribute
                                    || constraint.multiplier != weakself.multiplier
                                    )
                                    weakself.valid = NO;
                            }
                            deleteHandler:^(MSContextChangeReceptionist *receptionist,
                                            NSManagedObject *object)
                            {
                                weakself.valid = NO;
                            }];

    _kvoReceptionist = [MSKVOReceptionist
                        receptionistForObject:_modelConstraint
                        keyPath:@"constant"
                        options:NSKeyValueObservingOptionNew
                        context:NULL
                        queue:MainQueue
                        handler:^(MSKVOReceptionist *r, NSString *kp, id o, NSDictionary *c, void *ctx) {
                            weakself.constant = ((Constraint *)o).constant;
                        }];
}

- (void)setValid:(BOOL)valid {
    _valid = valid;
    if (!_valid) {
        [_owner removeConstraint:self];
    }
}

- (NSString *)uuid { return _modelConstraint.uuid; }

- (NSString *)description {
    static NSString * (^ itemNameForView)(UIView *) = ^(UIView * view){
        return (view
                ? ([view isKindOfClass:[RemoteElementView class]]
                   ? [((RemoteElementView*)view).name camelCase]
                   : (view.accessibilityIdentifier
                      ? : $(@"<%@:%p>", ClassString([view class]), view)
                      )
                   )
                : (NSString*)nil
                );
    };
    NSString * firstItem       = itemNameForView(self.firstItem);
    NSString * firstAttribute  = [NSLayoutConstraint pseudoNameForAttribute:self.firstAttribute];
    NSString * relation        = [NSLayoutConstraint pseudoNameForRelation:self.relation];
    NSString * secondItem      = itemNameForView(self.secondItem);
    NSString * secondAttribute = (self.secondAttribute != NSLayoutAttributeNotAnAttribute
                                  ? [NSLayoutConstraint pseudoNameForAttribute:self.secondAttribute]
                                  : nil);
    NSString * multiplier = (self.multiplier == 1.0f
                             ? nil
                             : [[NSString stringWithFormat:@"%f", self.multiplier]
                                stringByStrippingTrailingZeroes]);
    NSString * constant = (self.constant == 0.0f
                           ? nil
                           : [[NSString stringWithFormat:@"%f", self.constant]
                              stringByStrippingTrailingZeroes]);
    NSString * priority = (self.priority == UILayoutPriorityRequired
                           ? nil
                           : [NSString stringWithFormat:@"@%i", (int)self.priority]);
    NSMutableString * stringRep = [NSMutableString stringWithFormat:@"%@.%@ %@ ",
                                   firstItem,
                                   firstAttribute,
                                   relation];

    if (secondItem && secondAttribute)
    {
        [stringRep appendFormat:@"%@.%@", secondItem, secondAttribute];

        if (multiplier) [stringRep appendFormat:@" * %@", multiplier];

        if (constant)
        {
            if (self.constant < 0)
            {
                constant = [constant substringFromIndex:1];
                [stringRep appendString:@" - "];
            }
            else
                [stringRep appendString:@" + "];
        }
    }

    if (constant) [stringRep appendString:constant];

    if (priority) [stringRep appendFormat:@" %@", priority];
    
    return stringRep;
}

@end
