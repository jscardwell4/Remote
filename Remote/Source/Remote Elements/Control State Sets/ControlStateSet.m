//
// ControlStateSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"
#import "CoreDataManager.h"

@implementation ControlStateSet

/**
 *
 * valid UIControlState bit combinations:
 * UIControlStateNormal: 0
 * UIControlStateHighlighted: 1
 * UIControlStateDisabled: 2
 * UIControlStateHighlighted|UIControlStateDisabled: 3
 * UIControlStateSelected: 4
 * UIControlStateHighlighted|UIControlStateSelected: 5
 * UIControlStateDisabled|UIControlStateSelected: 6
 * UIControlStateSelected|UIControlStateHighlighted|UIControlStateDisabled: 7
 *
 */
+ (BOOL)validState:(NSUInteger)state
{
    static const NSSet * validStates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        validStates = [@[@0,@1,@2,@3,@4,@5,@6,@7] set];
    });
    return [validStates containsObject:@(state)];
}

+ (NSString *)propertyForState:(NSUInteger)state
{
    switch (state) {
        case UIControlStateNormal:
            return @"normal";

        case UIControlStateHighlighted:
            return @"highlighted";

        case UIControlStateDisabled:
            return @"disabled";

        case UIControlStateHighlighted|UIControlStateDisabled:
            return @"highlightedAndDisabled";

        case UIControlStateSelected:
            return @"selected";

        case UIControlStateSelected|UIControlStateHighlighted:
            return @"highlightedAndSelected";

        case UIControlStateSelected|UIControlStateDisabled:
            return @"disabledAndSelected";

        case UIControlStateSelected|UIControlStateDisabled|UIControlStateHighlighted:
            return @"selectedHighlightedAndDisabled";
            
        default:
            return nil;
    }
}

+ (NSUInteger)stateForProperty:(NSString *)property
{
    static const NSDictionary * properties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        properties = @{@"normal"                         : @0,
                       @"highlighted"                    : @1,
                       @"disabled"                       : @2,
                       @"highlightedAndDisabled"         : @3,
                       @"selected"                       : @4,
                       @"highlightedAndSelected"         : @5,
                       @"disabledAndSelected"            : @6,
                       @"selectedHighlightedAndDisabled" : @7};

    });
    NSNumber * state = properties[property];
    return (state ? NSUIntegerValue(state) : NSUIntegerMax);
}



/*
@dynamic disabled;
@dynamic disabledAndSelected;
@dynamic highlighted;
@dynamic highlightedAndDisabled;
@dynamic highlightedAndSelected;
@dynamic normal;
@dynamic selected;
@dynamic selectedHighlightedAndDisabled;
*/
+ (instancetype)controlStateSet
{
    return [self controlStateSetInContext:[CoreDataManager defaultContext]];
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
{
    return [self MR_createInContext:moc];
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects
{
    ControlStateSet * stateSet = [self controlStateSetInContext:moc];
    [stateSet setValuesForKeysWithDictionary:objects];
    return stateSet;
}

- (NSDictionary *)dictionaryFromSetObjects
{
    NSMutableDictionary * dict = [@{} mutableCopy];
    for (NSUInteger i = 0; i < 8; i++)
    {
        NSString * property = [ControlStateSet propertyForState:i];
        id obj = [self valueForKey:property];
        if (obj) dict[[ControlStateSet propertyForState:i]] = obj;
    }

    return dict;
}

- (BOOL)isEmptySet { return ([[self dictionaryFromSetObjects] count] == 0); }

- (void)copyObjectsFromSet:(ControlStateSet *)set
{
    for (int i = 0; i < 8; i++) self[i] = [[set objectAtIndex:i] copy];
}

- (id)objectAtIndex:(NSUInteger)state
{
    return [self valueForKey:[ControlStateSet propertyForState:state]];
}

- (id)objectForKey:(NSString *)key
{
    return ([ControlStateSet validState:[ControlStateSet stateForProperty:key]] ? [self valueForKey:key] : nil);
}

- (id)objectAtIndexedSubscript:(NSUInteger)state
{
    if (![ControlStateSet validState:state]) return nil;
    
    id object = [self valueForKey:[ControlStateSet propertyForState:state]];

    if (object) return object;

    else if (state & UIControlStateSelected) return self[state & ~UIControlStateSelected];

    else if (state & UIControlStateHighlighted) return self[state & ~ UIControlStateHighlighted];

    else return [self valueForKey:@"normal"];
}

- (void)setObject:(id)obj forStates:(NSArray *)states
{
    for (id state in states)
    {
        if ([state isKindOfClass:[NSNumber class]])
            self[[state unsignedIntegerValue]] = obj;
        else
            self[state] = obj;
    }
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    NSUInteger state = [ControlStateSet stateForProperty:key];
    return self[state];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    NSUInteger state = [ControlStateSet stateForProperty:key];
    @try
    {
        self[state] = obj;
    }

    @catch (NSException * exception)
    {
        if ([exception.name isEqualToString:NSRangeException])
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"invalid state key"
                                         userInfo:nil];
        else
            @throw exception;
    }

}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)state
{
    if (!object) return; //@throw InvalidNilArgument(object);
    else if (![ControlStateSet validState:state]) @throw InvalidIndexArgument(state);
    else [self setValue:object forKey:[ControlStateSet propertyForState:state]];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    __block ControlStateSet * controlStateSet = nil;
    Class controlStateSetClass = [self class];
    __weak ControlStateSet * sourceSet = self;
    NSManagedObjectContext * moc = self.managedObjectContext;

    [moc performBlockAndWait:
     ^{
         controlStateSet = [controlStateSetClass controlStateSetInContext:moc];
         [controlStateSet copyObjectsFromSet:sourceSet];
     }];

    return controlStateSet;
}

- (NSDictionary *)JSONDictionary
{
    MSDictionary * dictionary = [[super JSONDictionary] mutableCopy];
    [dictionary addEntriesFromDictionary:[self dictionaryFromSetObjects]];

    return dictionary;
}

@end
