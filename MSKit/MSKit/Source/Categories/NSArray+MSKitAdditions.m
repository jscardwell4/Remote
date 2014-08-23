//
//  NSMutableArray+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 5/24/11.
//  Copyright 2011 Moondeer Studios. All rights reserved.
//

#import "NSArray+MSKitAdditions.h"
#import "NSString+MSKitAdditions.h"
#import "MSKitMacros.h"
#import "NSObject+MSKitAdditions.h"
#import "MSJSONSerialization.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation NSArray (MSKitAdditions)


- (NSString *)JSONString
{
    id jsonObject = self.JSONObject;
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&error];
    if (error || !jsonData)
    {
        MSHandleErrors(error);
        return nil;
    }

    else
    {
        NSMutableString * jsonString = [[NSString stringWithData:jsonData] mutableCopy];
        [jsonString replaceRegEx:@"^(\\s*\"[^\"]+\") :" withString:@"$1:"];
        return jsonString;
    }
}

- (id)JSONObject
{
    if ([NSJSONSerialization isValidJSONObject:self])
        return self;

    else if (![self count])
        return NullObject;

    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[self count]];

    [self enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL * stop)
     {
         array[idx] = obj;
         if (![NSJSONSerialization isValidJSONObject:array])
         {
             [array removeObjectAtIndex:idx];
             if ([obj respondsToSelector:@selector(JSONObject)])
             {
                 id jsonObj = [obj JSONObject];
                 if ([NSJSONSerialization isValidJSONObject:jsonObj])
                     array[idx] = jsonObj;
                 else
                     MSLogDebug(@"object of type %@ returned invalid JSON object",
                                ClassTagStringForInstance(obj));
             }

             else if ([obj respondsToSelector:@selector(JSONValue)])
             {
                 id jsonValue = [obj JSONValue];
                 if ([MSJSONSerialization isValidJSONValue:jsonValue])
                     array[idx] = jsonValue;
                 else
                     MSLogDebug(@"object of type %@ returned invalid JSON Value",
                                ClassTagStringForInstance(obj));
             }

             NSAssert(![array count] || [NSJSONSerialization isValidJSONObject:array],
                      @"Only valid JSON values should have been added to array");
         }
     }];

    return array;
}


+ (NSArray *)arrayFromRange:(NSRange)range
{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = range.location; i < range.location + range.length; i++)
        array[i] = @(i);
    return array;
}

- (NSUInteger)lastIndex
{ NSInteger count = [self count]; return (count ? count-1 : NSUIntegerMax); }

- (NSSet *)set
{return [NSSet setWithArray:self];}

- (NSOrderedSet *)orderedSet
{return [NSOrderedSet orderedSetWithArray:self];}

- (NSArray *)arrayByAddingObjects:(id)objects
{
    if ([objects isKindOfClass:[NSArray class]])
        return [self arrayByAddingObjectsFromArray:objects];
    else if ([objects isKindOfClass:[NSSet class]])
        return [self arrayByAddingObjectsFromSet:objects];
    else if ([objects isKindOfClass:[NSOrderedSet class]])
        return [self arrayByAddingObjectsFromOrderedSet:objects];
    else if ([objects isKindOfClass:[NSDictionary class]])
        return [self arrayByAddingValuesFromDictionary:objects];
    else if (objects)
        return [self arrayByAddingObject:objects];
    else
        return nil;
}

- (NSArray *)arrayByAddingKeysFromDictionary:(NSDictionary *)dictionary
{
    return [self arrayByAddingObjectsFromArray:[dictionary allKeys]];
}
- (NSArray *)arrayByAddingValuesFromDictionary:(NSDictionary *)dictionary
{
    return [self arrayByAddingObjectsFromArray:[dictionary allValues]];
}
- (NSArray *)arrayByAddingObjectsFromSet:(NSSet *)set
{
    return [self arrayByAddingObjectsFromArray:[set allObjects]];
}

- (NSArray *)arrayByAddingObjectsFromOrderedSet:(NSOrderedSet *)orderedSet
{
    return [self arrayByAddingObjectsFromArray:[orderedSet array]];
}

- (NSArray *)filteredArrayUsingPredicateWithFormat:(NSString *)format,...
{
    va_list args;
    va_start(args, format);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:format arguments:args];
    va_end(args);
    if (!predicate) {
        return nil;
    } else
        return [self filteredArrayUsingPredicate:predicate];
}

- (NSArray *)filteredArrayUsingPredicateWithBlock:(BOOL (^)(id evaluatedObject,
                                                            NSDictionary *bindings))block
{
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:block]];
}

- (NSArray *)filter:(BOOL (^)(id evaluatedObject))block {

    NSMutableArray * result = [@[] mutableCopy];
    for (id obj in self) { if (block(obj)) [result addObject:obj]; }
    return result;
}

- (id)objectPassingTest:(BOOL (^)(id obj, NSUInteger idx))predicate
{
    __block NSUInteger index = NSNotFound;
    [self enumerateObjectsUsingBlock:^(id o, NSUInteger i, BOOL *s) {
        if (predicate(o, i)) index = i;
        if (index != NSNotFound) *s = YES;
    }];
    return (index == NSNotFound ? nil : self[index]);
}

- (NSArray *)objectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSIndexSet * idxs = [self indexesOfObjectsPassingTest:predicate];
    return (idxs.count?[self objectsAtIndexes:idxs]:nil);
}

- (NSArray *)arrayByMappingToBlock:(id (^)(id obj, NSUInteger idx))block
{
    NSMutableArray * array = [self mutableCopy];
    [array map:block];
    return array;
}

- (NSArray *)flattenedArray
{
    NSMutableArray * array = [self mutableCopy];
    [array flatten];
    return array;
}

- (void)makeObjectsPerformSelectorBlock:(void (^)(id object))block
{
    if (block) { for (id object in self) block(object); }
}

- (NSArray *)arrayByRemovingNullObjects
{
    NSMutableArray * array = [self mutableCopy];
    [array removeNullObjects];
    return array;
}

@end



@implementation NSMutableArray (MSKitAdditions)

+(id)arrayWithNullCapacity:(NSUInteger)capacity
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:capacity];
    [array replaceAllObjectsWithNull];
    return array;
}

- (void)filter:(BOOL (^)(id evaluatedObject))block {

    NSMutableIndexSet * indexes = [NSMutableIndexSet indexSet];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!block(obj)) [indexes addIndex:idx];
    }];
    [self removeObjectsAtIndexes:indexes];

}

- (void)flatten
{
    BOOL flat = NO;
    while (!flat)
    {
        flat = YES;
        for (int i = 0; i < self.count; i++)
        {
            if ([self[i] isKindOfClass:[NSArray class]])
            {
                NSArray * array = self[i];
                [self removeObjectAtIndex:i];
                if (array.count)
                {
                    flat = NO;
                    NSIndexSet * indices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, array.count)];
                    [self insertObjects:array atIndexes:indices];
                }
            }
        }
    }
}

- (void)map:(id (^)(id, NSUInteger))block { for (int i = 0; i < self.count; i++) self[i] = block(self[i],i); }

- (void)replaceAllObjectsWithNull
{
  for (int i = 0; i < [self count]; i++)
    self[i] = [NSNull null];
}

- (void)removeNullObjects
{
    [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == nil"]];
}

@end

NSArray * _NSArrayOfVariableNames(NSString * commaSeparatedNamesString, ...)
{
    if (!commaSeparatedNamesString) return nil;
    else return [commaSeparatedNamesString componentsSeparatedByRegEx:@",\\s*"];
}