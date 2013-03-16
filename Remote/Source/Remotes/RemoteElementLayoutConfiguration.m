//
//  RemoteElementLayoutConfiguration.m
//  Remote
//
//  Created by Jason Cardwell on 3/7/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

#import "RemoteElementLayoutConfiguration.h"
#import "RemoteElement.h"

@interface RemoteElementLayoutConfiguration ()

@property (nonatomic, strong) MSBitVector                 * bitVector;
@property (nonatomic, strong) MSBitVector                 * primitiveBitVector;
@property (nonatomic, strong, readwrite) RemoteElement    * element;
@property (nonatomic, strong) MSContextChangeReceptionist * receptionist;

@end

static const int ddLogLevel = LOG_LEVEL_DEBUG;
static const int msLogContext = CONSTRAINT_C;
#pragma unused(ddLogLevel, msLogContext)

@implementation RemoteElementLayoutConfiguration {
    RemoteElement                       * _element;
    RELayoutConfigurationDependencyType   _relationships[8];
}

@dynamic bitVector, element;

@synthesize receptionist = _receptionist;
@synthesize primitiveBitVector = _bitVector;
@synthesize proportionLock = _proportionLock;

NSUInteger bitIndexForNSLayoutAttribute(NSLayoutAttribute attribute);
NSLayoutAttribute attributeForBitIndex(NSUInteger index);

////////////////////////////////////////////////////////////////////////////////
#pragma mark Initializers
////////////////////////////////////////////////////////////////////////////////

+ (RemoteElementLayoutConfiguration *)layoutConfigurationForElement:(RemoteElement *)element
{
    if (!element || !element.managedObjectContext) return nil;

    RemoteElementLayoutConfiguration * config =
        NewObjectForEntityInContext(@"RemoteElementLayoutConfiguration",
                                    element.managedObjectContext);

    [config setValuesForKeysWithDictionary:@{@"element": element, @"bitVector": BitVector8}];
    return config;
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self refreshConfig];
}

- (void)setElement:(RemoteElement *)element {
    // probably unnecessary since element always gets set before constraints have been added
    [self willChangeValueForKey:@"element"];
    [self setPrimitiveValue:element forKey:@"element"];
    [self didChangeValueForKey:@"element"];
    [self refreshConfig];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Element Config
////////////////////////////////////////////////////////////////////////////////

- (NSSet *)intrinsicConstraints {
    return [self.element.constraints
            filteredSetUsingPredicateWithBlock:
            ^BOOL(RemoteElementLayoutConstraint * constraint, NSDictionary *bindings) {
                return (   constraint.firstItem == _element
                        && (!constraint.secondItem || constraint.secondItem == _element));
            }];
}

- (NSSet *)subelementConstraints {
    return [self.element.constraints
            setByRemovingObjectsFromSet:self.intrinsicConstraints];
}

- (NSSet *)dependentChildConstraints {
    return [self.dependentConstraints
            objectsPassingTest:
            ^BOOL(RemoteElementLayoutConstraint * constraint, BOOL *stop) {
                return [_element.subelements containsObject:constraint.firstItem];
            }];
}

- (NSSet *)dependentConstraints {
    return [self.element.secondItemConstraints
            setByRemovingObjectsFromSet:self.intrinsicConstraints];
}

- (NSSet *)dependentSiblingConstraints {
    return [self.dependentConstraints
            setByRemovingObjectsFromSet:self.dependentChildConstraints];
}

- (void)refreshConfig {
    _proportionLock = NO;
    MSBitVector * bv = BitVector8;
    [self.element.firstItemConstraints
     enumerateObjectsUsingBlock:^(RemoteElementLayoutConstraint * constraint, BOOL *stop) {
         uint8_t bitIndex = bitIndexForNSLayoutAttribute(constraint.firstAttribute);
         bv[bitIndex] = @YES;
         _relationships[bitIndex] =
             (RELayoutConfigurationDependencyType)remoteElementRelationshipTypeForConstraint(_element,
                                                                                             constraint);
         if (   constraint.firstItem == constraint.secondItem
             && (   constraint.firstAttribute == NSLayoutAttributeWidth
                 || constraint.firstAttribute == NSLayoutAttributeHeight))
             _proportionLock = YES;
     }];
    if (self.bitVector != bv) _bitVector.bits = bv.bits;

    if (!_receptionist) {
        __weak RemoteElementLayoutConfiguration * weakself = self;
        _receptionist = [MSContextChangeReceptionist
                         receptionistForObject:_element
                         notificationName:NSManagedObjectContextObjectsDidChangeNotification
                         queue:MainQueue
                         updateHandler:^(MSContextChangeReceptionist *rec, NSManagedObject *obj) {
                             if ([obj hasChangesForKey:@"firstItemConstraints"])
                                 [weakself refreshConfig];

                         }
                         deleteHandler:nil];
    }
}

- (RELayoutConfigurationDependencyType)dependencyTypeForAttribute:(NSLayoutAttribute)attribute {
    if (!self[attribute])
        return RELayoutConfigurationUnspecifiedDependency;
    else
        return _relationships[bitIndexForNSLayoutAttribute(attribute)];
}

- (NSArray *)replacementCandidatesForAddingAttribute:(NSLayoutAttribute)attribute
                                           additions:(NSArray **)additions
{
    switch (attribute) {
        case NSLayoutAttributeBaseline :
        case NSLayoutAttributeBottom :
            if (self[@"height"])
                return (self[@"centerY"]
                        ? @[@(NSLayoutAttributeCenterY)]
                        : @[@(NSLayoutAttributeTop)]);
            else {
                *additions = @[@(NSLayoutAttributeHeight)];

                return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeTop)];
            }

        case NSLayoutAttributeTop :
            if (self[@"height"])
                return (self[@"centerY"]
                        ? @[@(NSLayoutAttributeCenterY)]
                        : @[@(NSLayoutAttributeBottom)]);
            else {
                *additions = @[@(NSLayoutAttributeHeight)];

                return @[@(NSLayoutAttributeCenterY), @(NSLayoutAttributeBottom)];
            }

        case NSLayoutAttributeLeft :
        case NSLayoutAttributeLeading :
            if (self[@"width"])
                return (self[@"centerX"]
                        ? @[@(NSLayoutAttributeCenterX)]
                        : @[@(NSLayoutAttributeRight)]);
            else {
                *additions = @[@(NSLayoutAttributeWidth)];

                return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeRight)];
            }

        case NSLayoutAttributeRight :
        case NSLayoutAttributeTrailing :
            if (self[@"width"])
                return (self[@"centerX"]
                        ? @[@(NSLayoutAttributeCenterX)]
                        : @[@(NSLayoutAttributeLeft)]);
            else {
                *additions = @[@(NSLayoutAttributeWidth)];

                return @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeLeft)];
            }

        case NSLayoutAttributeCenterX :
            if (self[@"width"])
                return (self[@"left"]
                        ? @[@(NSLayoutAttributeLeft)]
                        : @[@(NSLayoutAttributeRight)]);
            else {
                *additions = @[@(NSLayoutAttributeWidth)];

                return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
            }

        case NSLayoutAttributeCenterY :
            if (self[@"height"])
                return (self[@"top"]
                        ? @[@(NSLayoutAttributeTop)]
                        : @[@(NSLayoutAttributeBottom)]);
            else {
                *additions = @[@(NSLayoutAttributeHeight)];

                return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
            }

        case NSLayoutAttributeWidth :
            if (self[@"centerX"])
                return (self[@"left"]
                        ? @[@(NSLayoutAttributeLeft)]
                        : @[@(NSLayoutAttributeRight)]);
            else {
                *additions = @[@(NSLayoutAttributeCenterX)];

                return @[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight)];
            }

        case NSLayoutAttributeHeight :
            if (self[@"centerY"])
                return (self[@"top"]
                        ? @[@(NSLayoutAttributeTop)]
                        : @[@(NSLayoutAttributeBottom)]);
            else {
                *additions = @[@(NSLayoutAttributeCenterY)];
                
                return @[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom)];
            }
            
        case NSLayoutAttributeNotAnAttribute :
        default :
            
            return nil;
    }
}

- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute {
    return [self constraintsForAttribute:attribute
                                   order:RELayoutConstraintUnspecifiedOrder];
}

- (NSSet *)constraintsForAttribute:(NSLayoutAttribute)attribute
                             order:(RELayoutConstraintOrder)order
{
    if (!self[attribute]) return nil;

    NSMutableSet * constraints = [NSMutableSet set];

    if (!order || order == RELayoutConstraintFirstOrder) {
        [constraints unionSet:[self.element.firstItemConstraints
                               objectsPassingTest:
                               ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                                   return (obj.firstAttribute == attribute);
                               }]];
    }
    if (!order || order == RELayoutConstraintSecondOrder) {
        [constraints unionSet:[self.element.secondItemConstraints
                               objectsPassingTest:
                               ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                                   return (obj.secondAttribute == attribute);
                               }]];
    }

    return (constraints.count ? constraints : nil);
}

- (RemoteElementLayoutConstraint *)constraintWithValues:(NSDictionary *)attributes
{
    return [self.element.firstItemConstraints firstObjectPassingTest:
            ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                return [obj hasAttributeValues:attributes];}];
}

- (NSSet *)constraintsAffectingAxis:(UILayoutConstraintAxis)axis
                              order:(RELayoutConstraintOrder)order
{
    NSMutableSet * constraints = [NSMutableSet set];

    if (!order || order == RELayoutConstraintFirstOrder) {
        [constraints
         unionSet:[self.element.firstItemConstraints objectsPassingTest:
                   ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                       return (axis == UILayoutConstraintAxisForAttribute(obj.firstAttribute));
                   }]];
    }
    if (!order || order == RELayoutConstraintSecondOrder) {
        [constraints
         unionSet:[self.element.secondItemConstraints objectsPassingTest:
                   ^BOOL (RemoteElementLayoutConstraint * obj, BOOL * stop) {
                       return (axis == UILayoutConstraintAxisForAttribute(obj.secondAttribute));
                   }]];
    }

    return (constraints.count
            ? constraints
            : nil);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Syntax Support
////////////////////////////////////////////////////////////////////////////////

- (NSNumber *)objectForKeyedSubscript:(NSString *)key {
    return self[[NSLayoutConstraint attributeForPseudoName:key]];
}

- (void)setObject:(NSNumber *)object forKeyedSubscript:(NSString *)key {
    self[[NSLayoutConstraint attributeForPseudoName:key]] = object;
}

- (NSNumber *)objectAtIndexedSubscript:(NSLayoutAttribute)idx {
    NSUInteger bitIndex = bitIndexForNSLayoutAttribute(idx);
    return (bitIndex == NSNotFound ? @NO : self.bitVector[bitIndex]);
}

- (void)setObject:(NSNumber *)object atIndexedSubscript:(NSLayoutAttribute)idx {
    if (!object) object = @NO;
    NSUInteger bitIndex = bitIndexForNSLayoutAttribute(idx);
    assert(bitIndex != NSNotFound);
    self.bitVector[bitIndex] = object;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Logging
////////////////////////////////////////////////////////////////////////////////

- (NSString *)description {
    NSMutableString * s = [@"" mutableCopy];

    if (!NSUIntegerValue(_bitVector.bits)) [self refreshConfig];

    if ([_bitVector[7] boolValue]) [s appendString:@"L"];
    if ([_bitVector[6] boolValue]) [s appendString:@"R"];
    if ([_bitVector[5] boolValue]) [s appendString:@"T"];
    if ([_bitVector[4] boolValue]) [s appendString:@"B"];
    if ([_bitVector[3] boolValue]) [s appendString:@"X"];
    if ([_bitVector[2] boolValue]) [s appendString:@"Y"];
    if ([_bitVector[1] boolValue]) [s appendString:@"W"];
    if ([_bitVector[0] boolValue]) [s appendString:@"H"];

    return s;
}

- (NSString *)binaryDescription {
    return [_bitVector binaryDescription];
}

@end

NSUInteger bitIndexForNSLayoutAttribute(NSLayoutAttribute attribute) {
    switch (attribute) {
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:          return 7;
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:         return 6;
        case NSLayoutAttributeTop:              return 5;
        case NSLayoutAttributeBaseline:
        case NSLayoutAttributeBottom:           return 4;
        case NSLayoutAttributeCenterX:          return 3;
        case NSLayoutAttributeCenterY:          return 2;
        case NSLayoutAttributeWidth:            return 1;
        case NSLayoutAttributeHeight:           return 0;
        case NSLayoutAttributeNotAnAttribute:   return NSNotFound;
    }

}

NSLayoutAttribute attributeForBitIndex(NSUInteger index) {
    switch (index) {
        case 7:  return NSLayoutAttributeLeft;
        case 6:  return NSLayoutAttributeRight;
        case 5:  return NSLayoutAttributeTop;
        case 4:  return NSLayoutAttributeBottom;
        case 3:  return NSLayoutAttributeCenterX;
        case 2:  return NSLayoutAttributeCenterY;
        case 1:  return NSLayoutAttributeWidth;
        case 0:  return NSLayoutAttributeHeight;
        default: return NSLayoutAttributeNotAnAttribute;
    }
}

