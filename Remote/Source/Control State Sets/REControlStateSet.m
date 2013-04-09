//
// ControlStateSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REControlStateSet.h"

@interface REControlStateSet (CoreDataGeneratedAccessors)

- (void)setPrimitiveUuid:(NSString *)uuid;

@end

@implementation REControlStateSet

@dynamic uuid;

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

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context
{
    return [self MR_createInContext:context];
}

+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)context
                             withObjects:(NSDictionary *)objects
{
    REControlStateSet * stateSet = [self controlStateSetInContext:context];
    [stateSet setValuesForKeysWithDictionary:objects];
    return stateSet;
}

- (void)copyObjectsFromSet:(REControlStateSet *)set
{
    for (int i = 0; i < 8; i++) self[i] = [set[i] copy];
}

- (void)awakeFromInsert { [super awakeFromInsert]; [self setPrimitiveUuid:MSNonce()]; }

- (id)objectAtIndexedSubscript:(NSUInteger)state
{
    if (!validState(state)) return nil;
    
    id object = [self valueForKey:propertyForState(state)];

    if (object) return object;

    else if (state & UIControlStateSelected) return self[state & ~UIControlStateSelected];

    else if (state & UIControlStateHighlighted) return self[state & ~ UIControlStateHighlighted];

    else return [self valueForKey:@"normal"];
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)state
{
    if (validState(state)) [self setValue:object forKey:propertyForState(state)];
}

@end
