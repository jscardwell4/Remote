//
//  RemoteElementLayoutConstraint.m
//  Remote
//
//  Created by Jason Cardwell on 4/23/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RemoteElementLayoutConstraint.h"
#import "Constraint.h"
//#import "RemoteElementView.h"
#import "Remote-Swift.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RELayoutConstraint Implementation
////////////////////////////////////////////////////////////////////////////////

@interface RemoteElementLayoutConstraint ()

@property (nonatomic, assign, readwrite, getter = isValid) BOOL valid;
@property (nonatomic, strong) MSContextChangeReceptionist     * contextReceptionist;
@property (nonatomic, strong) MSKVOReceptionist               * kvoReceptionist;

@end

@implementation RemoteElementLayoutConstraint

+ (RemoteElementLayoutConstraint *)constraintWithModel:(Constraint *)model
                                               forView:(RemoteElementView *)view {
  if (!model || model.owner != view.model) return nil;

  RemoteElementView * firstItem  = view[model.firstItem.uuid];
  RemoteElementView * secondItem = ([model isStaticConstraint]
                                    ? nil
                                    : view[model.secondItem.uuid]);

  RemoteElementLayoutConstraint * constraint = [RemoteElementLayoutConstraint
                                                constraintWithItem:firstItem
                                                         attribute:model.firstAttribute
                                                         relatedBy:model.relation
                                                            toItem:secondItem
                                                         attribute:model.secondAttribute
                                                        multiplier:model.multiplier
                                                          constant:model.constant];

  assert(constraint);

  constraint.priority        = model.priority;
  constraint.tag             = model.tag;
  constraint.nametag         = model.key;
  constraint.owner           = view;
  constraint.valid           = YES;
  constraint.model = model;


  return constraint;
}

- (void)setModel:(Constraint *)model {

  _model = model;

  __weak RemoteElementLayoutConstraint * weakself = self;

  _contextReceptionist = [MSContextChangeReceptionist
                          receptionistWithObserver:self
                          forObject:_model
                               notificationName:NSManagedObjectContextObjectsDidChangeNotification
                                  updateHandler:^(MSContextChangeReceptionist * receptionist) {

                                    Constraint * constraint = (Constraint *)receptionist.object;

                                    RemoteElementLayoutConstraint * layout =
                                      (RemoteElementLayoutConstraint *)receptionist.observer;

                                    if (  constraint.owner != layout.owner.model
                                        || constraint.firstItem != layout.firstItem.model
                                        || constraint.firstAttribute != layout.firstAttribute
                                        || constraint.relation != layout.relation
                                        || constraint.secondItem != layout.secondItem.model
                                        || constraint.secondAttribute != layout.secondAttribute
                                        || constraint.multiplier != layout.multiplier )

                                      layout.valid = NO;
                                  } deleteHandler:^(MSContextChangeReceptionist * receptionist) {
                                    ((RemoteElementLayoutConstraint *)receptionist.observer).valid = NO;
                                  }];

  _kvoReceptionist = [MSKVOReceptionist
                      receptionistWithObserver:self
                      forObject:_model
                                    keyPath:@"constant"
                                    options:NSKeyValueObservingOptionNew
                                      queue:MainQueue
                                    handler:^(MSKVOReceptionist * receptionist) {
                                      Constraint * constraint = (Constraint *)receptionist.object;
                                      RemoteElementLayoutConstraint * layout =
                                        (RemoteElementLayoutConstraint *)receptionist.observer;
                                      layout.constant = constraint.constant;
                                    }];
}

- (void)setValid:(BOOL)valid {
  _valid = valid;

  if (!_valid) {
    [_owner removeConstraint:self];
  }
}

- (NSString *)uuid { return _model.uuid; }

- (NSString *)description {
  static NSString *(^itemNameForView)(UIView *) = ^(UIView * view) {
    return (view
            ? ([view isKindOfClass:[RemoteElementView class]]
               ? [((RemoteElementView *)view).model.name camelCase]
               : (view.accessibilityIdentifier
                  ?: $(@"<%@:%p>", ClassString([view class]), view)
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
}

@end
