//
// RECommandSetCollection.m
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//

#import "RECommandContainer_Private.h"

static int ddLogLevel   = DefaultDDLogLevel;
static int msLogContext = (LOG_CONTEXT_REMOTE|LOG_CONTEXT_FILE);
#pragma unused(ddLogLevel,msLogContext)

@implementation RECommandSetCollection

@dynamic commandSets;

- (void)setObject:(id)label forKeyedSubscript:(RECommandSet *)commandSet
{
    assert(label && commandSet);
    if (!([label isKindOfClass:[NSAttributedString class]] || [label isKindOfClass:[NSString class]]))
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"label must be some form of string"
                                     userInfo:nil];
    else
    {
        [self addCommandSetsObject:commandSet];
        NSMutableDictionary * index = [self.index mutableCopy];
        index[commandSet.uuid] = ([label isKindOfClass:[NSAttributedString class]]
                                  ? label
                                  : [NSAttributedString attributedStringWithString:label]);
        self.index = [NSDictionary dictionaryWithDictionary:index];
    }
}

- (NSAttributedString *)objectForKeyedSubscript:(RECommandSet *)commandSet
{
    assert(commandSet);
    return (NSAttributedString *)self.index[commandSet.uuid];
}

- (void)setObject:(RECommandSet *)commandSet atIndexedSubscript:(NSUInteger)idx
{
    NSUInteger currentCount = [self.commandSets count];
    if (commandSet && currentCount > idx) [self insertObject:commandSet inCommandSetsAtIndex:idx];
    else if (commandSet && currentCount == idx) [self addCommandSetsObject:commandSet];
}

- (RECommandSet *)objectAtIndexedSubscript:(NSUInteger)idx
{
    return ([self.commandSets count] > idx ? self.commandSets[idx] : nil);
}

@end

@implementation RECommandSetCollection (CommandSetAccessors)

MSKIT_STATIC_STRING_CONST kCommandSetsKey = @"commandSets";

- (void)insertObject:(RECommandSet *)value inCommandSetsAtIndex:(NSUInteger)index
{
    NSIndexSet * indexes = [NSIndexSet indexSetWithIndex:index];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
    [[self primitiveCommandSets] insertObject:value atIndex:index];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
}

- (void)removeObjectFromCommandSetsAtIndex:(NSUInteger)index
{
    NSIndexSet * indexes = [NSIndexSet indexSetWithIndex:index];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
    [[self primitiveCommandSets] removeObjectAtIndex:index];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
}

- (void)insertCommandSets:(NSArray *)values atIndexes:(NSIndexSet *)indexes
{
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
    [[self primitiveCommandSets] insertObjects:values atIndexes:indexes];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
}

- (void)removeCommandSetsAtIndexes:(NSIndexSet *)indexes
{
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
    [[self primitiveCommandSets] removeObjectsAtIndexes:indexes];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
}

- (void)replaceObjectInCommandSetsAtIndex:(NSUInteger)index withObject:(RECommandSet *)value
{
    NSIndexSet * indexes = [NSIndexSet indexSetWithIndex:index];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kCommandSetsKey];
    [self primitiveCommandSets][index] = value;
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kCommandSetsKey];
}

- (void)replaceCommandSetsAtIndexes:(NSIndexSet *)indexes withCommandSets:(NSArray *)values
{
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kCommandSetsKey];
    [[self primitiveCommandSets] replaceObjectsAtIndexes:indexes withObjects:values];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kCommandSetsKey];
}

- (void)addCommandSetsObject:(RECommandSet *)value
{
    NSIndexSet * indexes = [NSIndexSet indexSetWithIndex:[[self primitiveCommandSets] count]];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
    [[self primitiveCommandSets] addObject:value];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
}

- (void)removeCommandSetsObject:(RECommandSet *)value
{
    NSUInteger   index = [[self primitiveCommandSets] indexOfObject:value];
    if (index != NSNotFound) {
        NSIndexSet * indexes = [NSIndexSet indexSetWithIndex:index];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
        [[self primitiveCommandSets] removeObject:value];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
    }
}

- (void)addCommandSets:(NSOrderedSet *)values
{
    if ([values count]) {
        NSIndexSet * indexes = [NSIndexSet indexSetWithIndexesInRange:
                                NSMakeRange([[self primitiveCommandSets] count], [values count])];
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
        [[self primitiveCommandSets] addObjectsFromArray:[values array]];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kCommandSetsKey];
    }
}

- (void)removeCommandSets:(NSOrderedSet *)values
{
    NSIndexSet * indexes = [[self primitiveCommandSets]
                            indexesOfObjectsPassingTest:
                            ^BOOL(id obj, NSUInteger index, BOOL *stop)
                            {
                                return YES;
                            }];

    if ([indexes count]) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
        [[self primitiveCommandSets] removeObjectsAtIndexes:indexes];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kCommandSetsKey];
    }
}


@end