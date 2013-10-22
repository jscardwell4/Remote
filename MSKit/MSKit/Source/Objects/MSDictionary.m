//
//  MSDictionary.m
//  MSKit
//
//  Created by Jason Cardwell on 4/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSDictionary.h"
#import "NSArray+MSKitAdditions.h"
#import "NSDictionary+MSKitAdditions.h"
#import "NSOrderedSet+MSKitAdditions.h"
#import "NSString+MSKitAdditions.h"
#import "NSValue+MSKitAdditions.h"
#import "MSJSONSerialization.h"
#import "NSPointerArray+MSKitAdditions.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@interface MSIndexedValue : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) id 		 value;

@end

@implementation MSIndexedValue

+ (MSIndexedValue *)indexedValueWithIndex:(NSUInteger)index value:(id)value
{
    assert(value);
    MSIndexedValue * indexedValue = [MSIndexedValue new];
    indexedValue.index = index;
    indexedValue.value = value;
    return indexedValue;
}

@end



////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSDictionary
////////////////////////////////////////////////////////////////////////////////


@implementation MSDictionary {
    @protected
    NSPointerArray      * _orderedKeys;    /// Holds keys and maintains order
    NSPointerArray      * _orderedValues;  /// Holds ordered values, may change to use indexed values
    NSMutableDictionary * _dictionary;  /// Holds a regular dictionary representation
}

- (id)init
{
    if (self = [super init])
    {
        _orderedKeys   = [NSPointerArray weakObjectsPointerArray];
        _orderedValues = [NSPointerArray weakObjectsPointerArray];
        _dictionary    = [@{} mutableCopy];
    }
    return self;
}

- (instancetype)dictionaryByRemovingKeysWithNullObjectValues
{
    MSDictionary * dictionary = [self mutableCopy];
    [dictionary removeKeysWithNullObjectValues];
    return dictionary;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark JSON export
////////////////////////////////////////////////////////////////////////////////

- (id)JSONObject
{
    if ([NSJSONSerialization isValidJSONObject:self])
        return self;

    else if (![self count])
        return NullObject;

    MSDictionary * dictionary = [MSDictionary dictionaryWithCapacity:[self count]];

    [self enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop)
     {
         NSString * keyString = [key description];
         dictionary[keyString] = obj;
         if (![NSJSONSerialization isValidJSONObject:dictionary])
         {
             [dictionary removeObjectForKey:keyString];
             if ([obj respondsToSelector:@selector(JSONObject)])
             {
                 id jsonObj = [obj JSONObject];
                 if ([NSJSONSerialization isValidJSONObject:jsonObj])
                     dictionary[keyString] = jsonObj;
                 else
                     MSLogDebug(@"object of type %@ returned invalid JSON object",
                                ClassTagStringForInstance(obj));
             }

             else if ([obj respondsToSelector:@selector(JSONValue)])
             {
                 id jsonValue = [obj JSONValue];
                 if ([MSJSONSerialization isValidJSONValue:jsonValue])
                     dictionary[keyString] = jsonValue;
                 else
                     MSLogDebug(@"object of type %@ returned invalid JSON Value",
                                ClassTagStringForInstance(obj));
             }

             NSAssert(![dictionary count] || [NSJSONSerialization isValidJSONObject:dictionary],
                      @"Only valid JSON values should have been added to dictionary");
         }
     }];
    
    return dictionary;
}



- (NSString *)JSONString
{
    id jsonObject = [self JSONObject];
    NSAssert(jsonObject, @"failed to get JSON object for %@", ClassTagStringForInstance(self));

    NSString * jsonString = nil;

    if (jsonObject)
    {
        NSError * error = nil;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&error];
        if (error) MSHandleErrors(error);
        else jsonString = [[NSString stringWithData:jsonData]
                           stringByReplacingOccurrencesOfRegEx:@"^(\\s*\"[^\"]+\") :" withString:@"$1:"];
    }

    NSAssert(jsonString, @"failed to create JSON string for %@", ClassTagStringForInstance(self));

    return jsonString;
}

- (MSDictionary *)JSONDictionary { return self; }

////////////////////////////////////////////////////////////////////////////////
#pragma mark NSSecureCoding
////////////////////////////////////////////////////////////////////////////////

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_orderedKeys forKey:@"keys"];
    [aCoder encodeObject:_orderedValues forKey:@"values"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _orderedKeys   = [aDecoder decodeObjectOfClass:[NSOrderedSet class] forKey:@"keys"  ];
        _orderedValues = [aDecoder decodeObjectOfClass:[NSArray      class] forKey:@"values"];
    }
    return self;
}

- (NSEnumerator *)keyEnumerator { return [[_orderedKeys allObjects] objectEnumerator]; }

- (NSArray *)allKeysForObject:(id)anObject
{
    NSIndexSet * indexes = [[_orderedValues allObjects] indexesOfObjectsPassingTest:
                            ^BOOL(id obj, NSUInteger idx, BOOL *stop)
                            {
                                return [obj isEqual:anObject];
                            }];
    return (indexes.count ? [[_orderedKeys allObjects] objectsAtIndexes:indexes] : nil);
}

- (NSArray *)allValues { return [_orderedValues copy]; }

- (NSString *)description
{
    NSMutableArray * keyValuePairs = [@[] mutableCopy];
    for (int i = 0; i < [self count]; i++)
        [keyValuePairs addObject:$(@"'%@': '%@'", _orderedKeys[i], _orderedValues[i])];

    return $(@"<%@:%p> {\n\t%@\n};",
             ClassString([self class]),
             self,
             [keyValuePairs componentsJoinedByString:@",\n\t"]);
}

- (NSString *)debugDescription { return [self description]; }

- (NSString *)formattedDescriptionWithOptions:(NSUInteger)options levelIndent:(NSUInteger)levelIndent
{
    NSMutableArray * descriptionComponents = [@[] mutableCopy];

    NSUInteger maxKeyDescriptionLength =
        NSUIntegerValue([_orderedKeys valueForKeyPath:@"@max.description.length"]);
    NSString * indentString = [NSString stringWithCharacter:' ' count:levelIndent * 4];

    [self enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {

         NSString * spacerString = [NSString stringWithCharacter:' '
                                                          count:(maxKeyDescriptionLength
                                                                 - [key description].length + 1)];
         NSString * keyString = $(@"%@%@: %@", indentString, [key description], spacerString);
         NSMutableArray * objComponents = [[[obj description] componentsSeparatedByString:@"\n"]
                                           mutableCopy];
         NSMutableString * objString = [objComponents[0] mutableCopy];
         if ([objComponents count] > 1)
         {
             [objComponents removeObjectAtIndex:0];
             NSString * meatString = $(@"\n%@%@",
                                       indentString,
                                       [NSString stringWithCharacter:' '
                                                               count:maxKeyDescriptionLength + 3]);
             [objString appendFormat:@"%@%@",
                                     meatString,
                                     [objComponents componentsJoinedByString:meatString]];
         }
         [descriptionComponents addObject:$(@"%@%@", keyString, objString)];
     }];

    return [descriptionComponents componentsJoinedByString:@"\n"];
}

- (NSEnumerator *)objectEnumerator { return [[_orderedValues allObjects] objectEnumerator]; }

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker
{
    NSMutableArray * objects = [@[] mutableCopy];
    for (id key in keys) [objects addObject:(self[key] ? : marker)];
    return objects;
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys
{
    NSUInteger count = [self count];
    [[_orderedValues allObjects] getObjects:objects range:NSMakeRange(0, count)];
    [[_orderedKeys allObjects] getObjects:keys range:NSMakeRange(0, count)];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx { return _orderedValues[idx]; }

- (id)objectAtIndex:(NSUInteger)idx { return [self objectAtIndexedSubscript:idx]; }

- (id)keyAtIndex:(NSUInteger)idx { return _orderedKeys[idx]; }

- (instancetype)dictionaryBySortingByKeys:(NSArray *)sortedKeys
{
    MSDictionary * dictionary = [MSDictionary dictionaryWithDictionary:self];
    [dictionary sortByKeys:sortedKeys];
    return dictionary;
}

- (instancetype)initWithObjects:(const id [])objects
                        forKeys:(const id <NSCopying> [])keys
                          count:(NSUInteger)cnt
{
    if (self = [super initWithObjects:objects forKeys:keys count:cnt])
    {
        _dictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
        _orderedKeys   = [NSPointerArray weakObjectsPointerArray];
        _orderedValues = [NSPointerArray weakObjectsPointerArray];
        for (int i = 0; i < cnt; i++)
        {
            [_orderedKeys addPointer:(__bridge void *)(keys[i])];
            [_orderedKeys addPointer:(__bridge void *)(objects[i])];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [MSDictionary dictionaryWithObjects:[_orderedValues allObjects]
                                       forKeys:[_orderedKeys allObjects]];
}

- (id)mutableCopyWithZone:(NSZone *)zone { return [self copyWithZone:zone]; }

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len
{
    return [_orderedKeys countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)removeKeysWithNullObjectValues
{
    [self removeObjectsAtIndexes:[[_orderedValues allObjects] indexesOfObjectsPassingTest:
                                  ^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                  {
                                      return ValueIsNil(obj);
                                  }]];
}

- (void)sortByKeys:(NSArray *)sortedKeys
{
    NSMutableOrderedSet * orderedKeys = [NSMutableOrderedSet orderedSetWithArray:sortedKeys];
    [orderedKeys intersectOrderedSet:[NSOrderedSet orderedSetWithArray:[_orderedKeys allObjects]]];

    NSMutableOrderedSet * extraKeys = [_orderedKeys mutableCopy];
    [extraKeys minusOrderedSet:orderedKeys];

    NSMutableArray * orderedValues = [@[] mutableCopy];
    for (id key in orderedKeys)
        [orderedValues addObject:self[key]];
    
    for (id key in extraKeys)
        [orderedValues addObject:self[key]];

    [orderedKeys addObjectsFromArray:[extraKeys array]];

    _orderedKeys = [NSPointerArray weakObjectsPointerArray];
    _orderedValues = [NSPointerArray weakObjectsPointerArray];
}

- (void)removeObjectForKey:(id)aKey
{
    if ([_orderedKeys containsObject:aKey])
    {
        [_orderedKeys removeObject:aKey];
        [_orderedValues removeObject:self[aKey]];
        [super removeObjectForKey:aKey];
    }
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    [super setObject:anObject forKey:aKey];

    if ([_orderedKeys containsObject:aKey])
    {
        NSUInteger index = [_orderedKeys indexOfObject:aKey];
        [_orderedValues replaceObjectAtIndex:index withObject:anObject];
    }

    else
    {
        [self willChange:NSKeyValueChangeInsertion
         valuesAtIndexes:NSIndexSetMake([_orderedKeys count])
                  forKey:@"allKeys"];
        [_orderedKeys addObject:aKey];
        [_orderedValues addObject:anObject];
        [self didChange:NSKeyValueChangeInsertion
        valuesAtIndexes:NSIndexSetMake([_orderedKeys count] - 1)
                 forKey:@"allKeys"];
    }
}

- (void)removeAllObjects
{
    [super removeAllObjects];
    [_orderedKeys removeAllObjects];
    [_orderedValues removeAllObjects];
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    NSIndexSet * indexes = [_orderedKeys indexesOfObjectsPassingTest:
                            ^BOOL(id obj, NSUInteger idx, BOOL *stop)
                            {
                                return [keyArray containsObject:obj];
                            }];
    [_orderedKeys removeObjectsAtIndexes:indexes];
    [_orderedValues removeObjectsAtIndexes:indexes];
    [super removeObjectsForKeys:keyArray];
}


- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    if (self = [super init])
    {
        _orderedKeys   = [NSMutableOrderedSet orderedSetWithCapacity:numItems];
        _orderedValues = [NSMutableArray arrayWithCapacity:numItems];
    }
    return self;
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSArray * keysToRemove = [_orderedKeys objectsAtIndexes:indexes];
    [_orderedKeys removeObjectsAtIndexes:indexes];
    [_orderedValues removeObjectsAtIndexes:indexes];
    [super removeObjectsForKeys:keysToRemove];
}


@end
