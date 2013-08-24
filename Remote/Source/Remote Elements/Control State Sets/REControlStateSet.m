//
// ControlStateSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REControlStateSet.h"

@implementation REControlStateSet

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
    return [self controlStateSetInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
{
    return [self MR_createInContext:moc];
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects
{
    REControlStateSet * stateSet = [self controlStateSetInContext:moc];
    [stateSet setValuesForKeysWithDictionary:objects];
    return stateSet;
}

- (NSDictionary *)dictionaryFromSetObjects
{
    NSMutableDictionary * dict = [@{} mutableCopy];
    for (NSUInteger i = 0; i < 8; i++)
    {
        id obj = self[i];
        if (obj) dict[propertyForState(i)] = obj;
    }

    return dict;
}

- (void)copyObjectsFromSet:(REControlStateSet *)set
{
    for (int i = 0; i < 8; i++) self[i] = [set[i] copy];
}

- (id)objectAtIndexedSubscript:(NSUInteger)state
{
    if (!validState(state)) return nil;
    
    id object = [self valueForKey:propertyForState(state)];

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
    NSUInteger state = stateForProperty(key);
    return self[state];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
    NSUInteger state = stateForProperty(key);
    @try
    {
        self[state] = obj;
    }

    @catch (NSException *exception)
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
    else if (!validState(state)) @throw InvalidIndexArgument(state);
    else [self setValue:object forKey:propertyForState(state)];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    __block REControlStateSet * controlStateSet = nil;
    Class controlStateSetClass = [self class];
    __weak REControlStateSet * sourceSet = self;
    NSManagedObjectContext * moc = self.managedObjectContext;

    [moc performBlockAndWait:
     ^{
         controlStateSet = [controlStateSetClass controlStateSetInContext:moc];
         [controlStateSet copyObjectsFromSet:sourceSet];
     }];

    return controlStateSet;
}

@end
