//
// REConstraint.m
// Remote
//
// Created by Jason Cardwell on 1/21/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "REConstraint.h"
#import "REConstraintManager.h"
#import "RemoteElement_Private.h"
#import "REView_Private.h"

@interface REConstraint ()

@property (nonatomic, assign, readwrite) int16_t         firstAttribute;
@property (nonatomic, assign, readwrite) int16_t         secondAttribute;
@property (nonatomic, assign, readwrite) int16_t         relation;
@property (nonatomic, assign, readwrite) float           multiplier;
@property (nonatomic, strong, readwrite) RemoteElement * firstItem;
@property (nonatomic, strong, readwrite) RemoteElement * secondItem;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - REConstraint
////////////////////////////////////////////////////////////////////////////////

@implementation REConstraint
@dynamic firstAttribute;
@dynamic secondAttribute;
@dynamic multiplier;
@dynamic constant;
@dynamic firstItem;
@dynamic secondItem;
@dynamic relation;
@dynamic priority;
@dynamic owner;
@dynamic tag;
@dynamic key;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Initializer
////////////////////////////////////////////////////////////////////////////////

+ (REConstraint *)constraintWithItem:(RemoteElement *)element1
                           attribute:(NSLayoutAttribute)attr1
                           relatedBy:(NSLayoutRelation)relation
                              toItem:(RemoteElement *)element2
                           attribute:(NSLayoutAttribute)attr2
                          multiplier:(CGFloat)multiplier
                            constant:(CGFloat)c
{
    assert(  ValueIsNotNil(element1)
           && attr1 && (  !element2
                        || ValueIsNotNil(element2)));

    __block REConstraint * constraint = nil;
    NSManagedObjectContext                * context    = element1.managedObjectContext;

    [context performBlockAndWait:^{
        constraint = [NSEntityDescription
                      insertNewObjectForEntityForName:@"REConstraint"
                      inManagedObjectContext:context];
        if (constraint) {
            constraint.firstAttribute = attr1;
            constraint.relation = relation;
            constraint.secondItem = element2;
            constraint.secondAttribute = attr2;
            constraint.multiplier = multiplier;
            constraint.constant = c;
            constraint.firstItem = element1;
        }
     }];

    return constraint;
}

+ (REConstraint *)constraintWithAttributeValues:(NSDictionary *)attributes
{
    return [self constraintWithItem:attributes[@"firstItem"]
                          attribute:NSUIntegerValue(attributes[@"firstAttribute"])
                          relatedBy:NSUIntegerValue(attributes[@"relation"])
                             toItem:NilSafeValue(attributes[@"secondItem"])
                          attribute:NSUIntegerValue(attributes[@"secondAttribute"])
                         multiplier:CGFloatValue(attributes[@"multiplier"])
                           constant:CGFloatValue(attributes[@"constant"])];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////

- (RELayoutConfiguration *)configuration { return self.firstItem.layoutConfiguration; }

- (BOOL)isStaticConstraint { return !self.secondItem; }

- (BOOL)hasAttributeValues:(NSDictionary *)values {
    id         firstItem       = values[@"firstItem"];
    id         secondItem      = values[@"secondItem"];
    NSNumber * firstAttribute  = values[@"firstAttribute"];
    NSNumber * secondAttribute = values[@"secondAttribute"];
    NSNumber * relation        = values[@"relation"];
    NSNumber * multiplier      = values[@"multiplier"];
    NSNumber * constant        = values[@"constant"];
    NSNumber * priority        = values[@"priority"];
    id         owner           = values[@"owner"];

    return (   (   !firstItem
                || (  [firstItem isKindOfClass:[NSString class]]
                    ? [self.firstItem.uuid isEqualToString:firstItem]
                    : self.firstItem == firstItem))
            && (!firstAttribute || self.firstAttribute == CGFloatValue(firstAttribute))
            && (!relation || self.relation == NSIntegerValue(relation))
            && (   !secondItem
                || (  [secondItem isKindOfClass:[NSString class]]
                    ? [self.secondItem.uuid isEqualToString:secondItem]
                    : self.secondItem == secondItem))
            && (!secondAttribute || self.secondAttribute == CGFloatValue(secondAttribute))
            && (!multiplier || self.multiplier == CGFloatValue(multiplier))
            && (!constant || self.constant == CGFloatValue(constant))
            && (!priority || self.priority == CGFloatValue(priority))
            && (   !owner
                || (  [owner isKindOfClass:[NSString class]]
                    ? [self.owner.uuid isEqualToString:owner]
                    : self.owner == owner))
            );
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging
////////////////////////////////////////////////////////////////////////////////

- (NSString *)committedValuesDescription {
    NSArray * attributeKeys = @[@"firstItem",
                                @"firstAttribute",
                                @"relation",
                                @"secondItem",
                                @"secondAttribute",
                                @"multiplier",
                                @"constant",
                                @"priority"];

    NSDictionary * attributes = [self committedValuesForKeys:attributeKeys];

    NSString * firstItem      = [((RemoteElement *)attributes[@"firstItem"]).displayName
                                 camelCaseString];
    NSString * firstAttribute = [NSLayoutConstraint pseudoNameForAttribute:
                                 [attributes[@"firstAttribute"] integerValue]];
    NSString * relation       = [NSLayoutConstraint pseudoNameForRelation:
                                 [attributes[@"relation"] integerValue]];
    NSString * secondItem     = [((RemoteElement *)NilSafeValue(attributes[@"secondItem"])).displayName
                                 camelCaseString];
    NSString * secondAttribute = (NSIntegerValue(attributes[@"secondAttribute"])
                                  ? [NSLayoutConstraint pseudoNameForAttribute:
                                     [attributes[@"secondAttribute"] integerValue]]
                                  : nil);
    NSString * multiplier = ([attributes[@"multiplier"] floatValue] == 1.0f
                             ? nil
                             :StripTrailingZeros($(@"%f", [attributes[@"multiplier"] floatValue])));
    NSString * constant = ([attributes[@"constant"] floatValue] == 0.0f
                           ? nil
                           :StripTrailingZeros($(@"%f", [attributes[@"constant"] floatValue])));
    NSString * priority = ([attributes[@"priority"] integerValue] == UILayoutPriorityRequired
                           ? nil
                           :$(@"%i", [attributes[@"priority"] integerValue]));
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
}

- (NSString *)description {
    if (!self.managedObjectContext)
        return @"orphaned constraint";
    else if ([self isDeleted])
        return $(@"%@ <deleted>", [self committedValuesDescription]);

    NSArray * attributeKeys = @[@"firstItem",
                                @"firstAttribute",
                                @"relation",
                                @"secondItem",
                                @"secondAttribute",
                                @"multiplier",
                                @"constant",
                                @"priority"];

    NSDictionary * attributes = [self dictionaryWithValuesForKeys:attributeKeys];

    NSString * firstItem       = [((RemoteElement *)attributes[@"firstItem"]).displayName
                                  camelCaseString];
    NSString * firstAttribute  = [NSLayoutConstraint pseudoNameForAttribute:
                                  [attributes[@"firstAttribute"] integerValue]];
    NSString * relation        = [NSLayoutConstraint pseudoNameForRelation:
                                  [attributes[@"relation"] integerValue]];
    NSString * secondItem      = [((RemoteElement *)NilSafeValue(attributes[@"secondItem"])).displayName
                                  camelCaseString];
    NSString * secondAttribute = ([attributes[@"secondAttribute"] integerValue]
                                  ? [NSLayoutConstraint pseudoNameForAttribute:
                                     [attributes[@"secondAttribute"] integerValue]]
                                  : nil);
    NSString * multiplier = ([attributes[@"multiplier"] floatValue] == 1.0f
                             ? nil
                             :StripTrailingZeros($(@"%f", [attributes[@"multiplier"] floatValue])));
    NSString * constant = ([attributes[@"constant"] floatValue] == 0.0f
                           ? nil
                           :StripTrailingZeros($(@"%f", [attributes[@"constant"] floatValue])));
    NSString * priority = ([attributes[@"priority"] integerValue] == UILayoutPriorityRequired
                           ? nil
                           :$(@"@%i", [attributes[@"priority"] integerValue]));
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
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RELayoutConstraint Implementation
////////////////////////////////////////////////////////////////////////////////

@interface RELayoutConstraint ()

@property (nonatomic, assign, readwrite, getter = isValid) BOOL   valid;
@property (nonatomic, strong) MSContextChangeReceptionist       * contextReceptionist;
@property (nonatomic, strong) MSKVOReceptionist                 * kvoReceptionist;

@end

@implementation RELayoutConstraint

+ (RELayoutConstraint *)constraintWithModel:(REConstraint *)modelConstraint
                                    forView:(REView *)view
{
    if (!modelConstraint || modelConstraint.owner != view.model) return nil;

    REView * firstItem = view[modelConstraint.firstItem.uuid];
    REView * secondItem = ([modelConstraint isStaticConstraint]
                                      ? nil
                                      : view[modelConstraint.secondItem.uuid]);

    RELayoutConstraint * constraint = [RELayoutConstraint
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

- (void)setModelConstraint:(REConstraint *)modelConstraint {

    _modelConstraint = modelConstraint;

    __weak RELayoutConstraint * weakself = self;

    _contextReceptionist = [MSContextChangeReceptionist
                            receptionistForObject:_modelConstraint
                            notificationName:NSManagedObjectContextObjectsDidChangeNotification
                            queue:MainQueue
                            updateHandler:^(MSContextChangeReceptionist *receptionist,
                                            NSManagedObject *object)
                            {
                                REConstraint * constraint =
                                    (REConstraint *)object;

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
                            weakself.constant = ((REConstraint *)o).constant;
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
                ? ([view isKindOfClass:[REView class]]
                   ? [((REView*)view).displayName camelCaseString]
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
