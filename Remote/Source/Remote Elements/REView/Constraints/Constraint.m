//
// Constraint.m
// Remote
//
// Created by Jason Cardwell on 1/21/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "Constraint.h"
#import "ConstraintManager.h"
#import "RemoteElement_Private.h"
#import "RemoteElementView_Private.h"

@interface Constraint ()

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

@implementation Constraint
@dynamic firstAttribute, secondAttribute, multiplier, constant, firstItem, secondItem, relation, priority, owner, tag, key;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Initializer
////////////////////////////////////////////////////////////////////////////////

+ (Constraint *)constraintWithItem:(RemoteElement *)element1
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

    Constraint * constraint = [self MR_createInContext:element1.managedObjectContext];
    if (constraint)
    {
        constraint.firstAttribute = attr1;
        constraint.relation = relation;
        constraint.secondItem = element2;
        constraint.secondAttribute = attr2;
        constraint.multiplier = multiplier;
        constraint.constant = c;
        constraint.firstItem = element1;
    }

    return constraint;
}

+ (Constraint *)constraintWithAttributeValues:(NSDictionary *)attributes
{
    return [self constraintWithItem:attributes[@"firstItem"]
                          attribute:UnsignedIntegerValue(attributes[@"firstAttribute"])
                          relatedBy:UnsignedIntegerValue(attributes[@"relation"])
                             toItem:NilSafe(attributes[@"secondItem"])
                          attribute:UnsignedIntegerValue(attributes[@"secondAttribute"])
                         multiplier:FloatValue(attributes[@"multiplier"])
                           constant:FloatValue(attributes[@"constant"])];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
////////////////////////////////////////////////////////////////////////////////

- (LayoutConfiguration *)configuration { return self.firstItem.layoutConfiguration; }

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
            && (!firstAttribute || self.firstAttribute == FloatValue(firstAttribute))
            && (!relation || self.relation == IntegerValue(relation))
            && (   !secondItem
                || (  [secondItem isKindOfClass:[NSString class]]
                    ? [self.secondItem.uuid isEqualToString:secondItem]
                    : self.secondItem == secondItem))
            && (!secondAttribute || self.secondAttribute == FloatValue(secondAttribute))
            && (!multiplier || self.multiplier == FloatValue(multiplier))
            && (!constant || self.constant == FloatValue(constant))
            && (!priority || self.priority == FloatValue(priority))
            && (   !owner
                || (  [owner isKindOfClass:[NSString class]]
                    ? [self.owner.uuid isEqualToString:owner]
                    : self.owner == owner))
            );
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Importing
////////////////////////////////////////////////////////////////////////////////

+ (id)MR_importFromObject:(NSDictionary *)data inContext:(NSManagedObjectContext *)context
{
    NSDictionary * index  = data[@"index"];
    id formatData = data[@"format"];
    NSArray      * formatArray = (isStringKind(formatData) ? @[formatData] : formatData);
    if (!(index && formatArray)) return nil;

    NSMutableArray * constraints = [@[] mutableCopy];

    for (NSString * s in formatArray)
    {
        NSDictionary * d = [NSLayoutConstraint dictionaryFromExtendedVisualFormat:s];
        RemoteElement * element1, * element2;
        NSLayoutAttribute attribute1, attribute2;
        NSLayoutRelation relation;
        float multiplier = 1, constant = 0, priority = UILayoutPriorityRequired;

        NSString * attribute1Name = d[MSExtendedVisualFormatAttribute1Name];
        assert(attribute1Name);
        attribute1 = [NSLayoutConstraint attributeForPseudoName:attribute1Name];

        NSString * attribute2Name = NilSafe(d[MSExtendedVisualFormatAttribute2Name]);
        attribute2 = (attribute2Name
                      ? [NSLayoutConstraint attributeForPseudoName:attribute2Name]
                      : NSLayoutAttributeNotAnAttribute);

        NSString * relationName = d[MSExtendedVisualFormatRelationName];
        assert(relationName);
        relation = [NSLayoutConstraint relationForPseudoName:relationName];

        NSNumber * constantNumber = NilSafe(d[MSExtendedVisualFormatConstantName]);
        NSString * constantOperator = NilSafe(d[MSExtendedVisualFormatConstantOperatorName]);
        if (constantNumber)
        {
            constant = [constantNumber floatValue];
            if (constantOperator && [constantOperator isEqualToString:@"-"])
                constant = 0 - constant;
        }

        NSNumber * multiplierNumber = NilSafe(d[MSExtendedVisualFormatMultiplierName]);
        if (multiplierNumber) multiplier = [multiplierNumber floatValue];

        NSNumber * priorityNumber = NilSafe(d[MSExtendedVisualFormatPriorityName]);
        if (priorityNumber) priority = [priorityNumber floatValue];

        NSString * element1Name = d[MSExtendedVisualFormatItem1Name];
        assert(element1Name);
        NSString * element1UUID = index[element1Name];
        assert(element1UUID);
        element1 = [RemoteElement MR_findFirstByAttribute:@"uuid"
                                                withValue:element1UUID
                                                inContext:context];
        assert(element1);

        NSString * element2Name = NilSafe(d[MSExtendedVisualFormatItem2Name]);
        if (element2Name)
        {
            NSString * element2UUID = index[element2Name];
            assert(element2UUID);
            element2 = [RemoteElement MR_findFirstByAttribute:@"uuid"
                                                    withValue:element2UUID
                                                    inContext:context];
            assert(element2);
        }
        
        Constraint * c = [self constraintWithItem:element1
                                        attribute:attribute1
                                        relatedBy:relation
                                           toItem:element2
                                        attribute:attribute2
                                       multiplier:multiplier
                                         constant:constant];
        assert(c);
        c.priority = priority;
        [constraints addObject:c];
    }
    
    return ([constraints count] ? constraints : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging
////////////////////////////////////////////////////////////////////////////////

- (NSString *)committedValuesDescription
{
    NSArray * attributeKeys = @[@"firstItem",
                                @"firstAttribute",
                                @"relation",
                                @"secondItem",
                                @"secondAttribute",
                                @"multiplier",
                                @"constant",
                                @"priority"];

    NSDictionary * attributes = [self committedValuesForKeys:attributeKeys];

    NSString * firstItem      = [((RemoteElement *)attributes[@"firstItem"]).name
                                 camelCaseString];
    NSString * firstAttribute = [NSLayoutConstraint pseudoNameForAttribute:
                                 [attributes[@"firstAttribute"] integerValue]];
    NSString * relation       = [NSLayoutConstraint pseudoNameForRelation:
                                 [attributes[@"relation"] integerValue]];
    NSString * secondItem     = [((RemoteElement *)NilSafe(attributes[@"secondItem"])).name
                                 camelCaseString];
    NSString * secondAttribute = (IntegerValue(attributes[@"secondAttribute"])
                                  ? [NSLayoutConstraint pseudoNameForAttribute:
                                     [attributes[@"secondAttribute"] integerValue]]
                                  : nil);
    NSString * multiplier = ([(NSNumber *)attributes[@"multiplier"] floatValue] == 1.0f
                             ? nil
                             :StripTrailingZeros($(@"%f", [(NSNumber *)attributes[@"multiplier"] floatValue])));
    NSString * constant = ([(NSNumber *)attributes[@"constant"] floatValue] == 0.0f
                           ? nil
                           :StripTrailingZeros($(@"%f", [(NSNumber *)attributes[@"constant"] floatValue])));
    NSString * priority = ([(NSNumber *)attributes[@"priority"] integerValue] == UILayoutPriorityRequired
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

- (NSDictionary * )JSONDictionary
{
    MSDictionary * dictionary = [super JSONDictionary];

    if (self.tag) dictionary[@"tag"] = @(self.tag);
    dictionary[@"key"] = CollectionSafe(self.key);
    dictionary[@"firstAttribute"] = [NSLayoutConstraint pseudoNameForAttribute:self.firstAttribute];
    dictionary[@"secondAttribute"] = [NSLayoutConstraint pseudoNameForAttribute:self.secondAttribute];
    dictionary[@"relation"] = [NSLayoutConstraint pseudoNameForRelation:self.relation];
    if (self.multiplier != 1.0f) dictionary[@"multiplier"] = @(self.multiplier);
    if (self.constant) dictionary[@"constant"] = @(self.constant);
    dictionary[@"firstItem"] = self.firstItem.uuid;
    dictionary[@"secondItem"] = CollectionSafe(self.secondItem.uuid);
    dictionary[@"owner"] = self.owner.uuid;
    if (self.priority != UILayoutPriorityRequired) dictionary[@"priority"] = @(self.priority);

//    [dictionary compact];

    return dictionary;
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

    NSString * firstItem       = [((RemoteElement *)attributes[@"firstItem"]).name
                                  camelCaseString];
    NSString * firstAttribute  = [NSLayoutConstraint pseudoNameForAttribute:
                                  [attributes[@"firstAttribute"] integerValue]];
    NSString * relation        = [NSLayoutConstraint pseudoNameForRelation:
                                  [attributes[@"relation"] integerValue]];
    NSString * secondItem      = [((RemoteElement *)NilSafe(attributes[@"secondItem"])).name
                                  camelCaseString];
    NSString * secondAttribute = ([attributes[@"secondAttribute"] integerValue]
                                  ? [NSLayoutConstraint pseudoNameForAttribute:
                                     [attributes[@"secondAttribute"] integerValue]]
                                  : nil);
    NSString * multiplier = ([(NSNumber *)attributes[@"multiplier"] floatValue] == 1.0f
                             ? nil
                             :StripTrailingZeros($(@"%f", [(NSNumber *)attributes[@"multiplier"] floatValue])));
    NSString * constant = ([(NSNumber *)attributes[@"constant"] floatValue] == 0.0f
                           ? nil
                           :StripTrailingZeros($(@"%f", [(NSNumber *)attributes[@"constant"] floatValue])));
    NSString * priority = ([(NSNumber *)attributes[@"priority"] integerValue] == UILayoutPriorityRequired
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

