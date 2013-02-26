//
// RemoteElementLayoutConstraint.m
// iPhonto
//
// Created by Jason Cardwell on 1/21/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementLayoutConstraint.h"
#import "RemoteElementLayoutConfiguration.h"
#import "RemoteElementConstraintManager.h"
#import "RemoteElement_Private.h"
#import "RemoteElementView_Private.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - RemoteElementLayoutConstraint
////////////////////////////////////////////////////////////////////////////////

@implementation RemoteElementLayoutConstraint {
    NSArray * _kvoReceptionists;
}
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
@dynamic identifier;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Initializer
////////////////////////////////////////////////////////////////////////////////

+ (RemoteElementLayoutConstraint *)constraintWithItem:(RemoteElement *)element1
                                            attribute:(NSLayoutAttribute)attr1
                                            relatedBy:(NSLayoutRelation)relation
                                               toItem:(RemoteElement *)element2
                                            attribute:(NSLayoutAttribute)attr2
                                           multiplier:(CGFloat)multiplier
                                             constant:(CGFloat)c
                                                owner:(RemoteElement *)owner {
    assert(  ValueIsNotNil(element1)
          && attr1 && (  !element2
                      || ValueIsNotNil(element2))
          && ValueIsNotNil(owner));

    __block RemoteElementLayoutConstraint * constraint = nil;
    NSManagedObjectContext                * context    = element1.managedObjectContext;

    [context performBlockAndWait:^{
                 constraint = [NSEntityDescription          insertNewObjectForEntityForName:@"RemoteElementLayoutConstraint"
                                                            inManagedObjectContext:context];
                 if (constraint) {
                 constraint.firstItem = element1;
                 constraint.firstAttribute = attr1;
                 constraint.relation = relation;
                 constraint.secondItem = element2;
                 constraint.secondAttribute = attr2;
                 constraint.multiplier = multiplier;
                 constraint.constant = c;
                 constraint.owner = owner;
                 }
             }

    ];

    return constraint;
}

- (void)awakeFromInsert {
    /*
     * You typically use this method to initialize special default property values. This method
     * is invoked only once in the object's lifetime. If you want to set attribute values in an
     * implementation of this method, you should typically use primitive accessor methods (either
     * setPrimitiveValue:forKey: or—better—the appropriate custom primitive accessors). This
     * ensures that the new values are treated as baseline values rather than being recorded as
     * undoable changes for the properties in question.
     */
    [super awakeFromInsert];
    self.identifier = [@"_" stringByAppendingString :[MSNonce()stringByRemovingCharacter:'-']];
    self.key        = @"";
    [self kvoReceptionists];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self kvoReceptionists];
}

- (void)kvoReceptionists {
    assert(_kvoReceptionists == nil);

    __weak RemoteElementLayoutConstraint * weakSelf = self;
    MSKVOHandler                           handler  = ^(MSKVOReceptionist * receptionist,
                                                        NSString * keyPath,
                                                        id object,
                                                        NSDictionary * change,
                                                        void * context)
    {
        if (ValueIsNil(object)) assert(![@"firstItem" isEqualToString: keyPath]);
        [weakSelf.owner
         constraintDidUpdate:weakSelf];
    };
    NSOperationQueue           * queue   = [NSOperationQueue mainQueue];
    void                       * context = NULL;
    NSKeyValueObservingOptions   options = NSKeyValueObservingOptionNew;

    _kvoReceptionists = [@[@"firstItem",
                           @"secondItem",
                           @"firstAttribute",
                           @"secondAttribute",
                           @"multiplier",
                           @"relation"] arrayByMappingToBlock :^MSKVOReceptionist * (NSString * keyPath, NSUInteger idx) {
        return [MSKVOReceptionist receptionistForObject:weakSelf
                                                keyPath:keyPath
                                                options:options
                                                context:context
                                                handler:handler
                                                  queue:queue];
    }];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////

- (BOOL)isStaticConstraint {
    return ((!self.secondItem)
            ? YES
            : NO);
}

- (BOOL)hasAttributeValues:(NSDictionary *)values {
    NSString * firstItem       = values[@"firstItem"];
    NSString * secondItem      = values[@"secondItem"];
    NSNumber * firstAttribute  = values[@"firstAttribute"];
    NSNumber * secondAttribute = values[@"secondAttribute"];
    NSNumber * relation        = values[@"relation"];
    NSNumber * multiplier      = values[@"multiplier"];
    NSNumber * constant        = values[@"constant"];
    NSNumber * priority        = values[@"priority"];
    NSString * owner           = values[@"owner"];

    return (  (!firstItem || [self.firstItem.identifier isEqualToString:firstItem])
           && (!firstAttribute || self.firstAttribute == Float(firstAttribute))
           && (!relation || self.relation == Integer(relation))
           && (!secondItem || [self.secondItem.identifier isEqualToString:secondItem])
           && (!secondAttribute || self.secondAttribute == Float(secondAttribute))
           && (!multiplier || self.multiplier == Float(multiplier))
           && (!constant || self.constant == Float(constant))
           && (!priority || self.priority == Float(priority))
           && (!owner || [self.owner.identifier isEqualToString:owner]));
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging
////////////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    NSString * firstItem      = [self.firstItem.displayName camelCaseString];
    NSString * firstAttribute = [NSLayoutConstraint pseudoNameForAttribute:self.firstAttribute];
    NSString * relation       = [NSLayoutConstraint pseudoNameForRelation:self.relation];
    NSString * secondItem     = (self.secondItem
                                 ?[self.secondItem.displayName camelCaseString]
                                 : nil);
    NSString * secondAttribute = (self.secondAttribute != NSLayoutAttributeNotAnAttribute
                                  ?[NSLayoutConstraint pseudoNameForAttribute:self.secondAttribute]
                                  : nil);
    NSString * multiplier = (self.multiplier == 1.0f
                             ? nil
                             :[[NSString stringWithFormat:@"%f", self.multiplier]stringByStrippingTrailingZeroes]);
    NSString * constant = (self.constant == 0.0f
                           ? nil
                           :[[NSString stringWithFormat:@"%f", self.constant]stringByStrippingTrailingZeroes]);
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
}

@end
