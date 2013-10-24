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
#import "NSNumber+MSKitAdditions.h"

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

@interface MSDictionary ()

@property (nonatomic, strong, readwrite) NSMutableArray * keys;
@property (nonatomic, strong, readwrite) NSMutableArray * values;
@property (nonatomic ,strong, readwrite) NSMutableDictionary * dictionary;
@end


@implementation MSDictionary {
    @protected
//    NSPointerArray      * _keys;        /// Holds keys and maintains order
//    NSPointerArray      * _values;      /// Holds ordered values, may change to use indexed values
//    NSMutableDictionary * _dictionary;  /// Holds a regular dictionary representation
}

- (id)init
{
    if (self = [super init])
    {
        self.keys       = [@[] mutableCopy];    //[NSPointerArray weakObjectsPointerArray];
        self.values     = [@[] mutableCopy];    //[NSPointerArray weakObjectsPointerArray];
        self.dictionary = [@{} mutableCopy];
    }
    return self;
}

- (void)setRequiresStringKeys:(BOOL)requiresStringKeys
{
    if (!requiresStringKeys) _requiresStringKeys = requiresStringKeys;
    else
    {
        BOOL isCompliant = YES;
        for (id object in self.keys) if (!isStringKind(object)) { isCompliant = NO; break; }
        if (!isCompliant) ThrowInvalidInternalInconsistency(current set of keys are not all strings);
        else _requiresStringKeys = requiresStringKeys;
    }
}

- (MSDictionary *)dictionaryByRemovingKeysWithNullObjectValues
{
    MSDictionary * dictionary = [self mutableCopy];
    [dictionary compact];
    return dictionary;
}

- (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys
{
    MSDictionary * dictionary = [MSDictionary dictionaryWithDictionary:[super dictionaryWithValuesForKeys:keys]];
    [dictionary compact];
    return dictionary;
}

//- (NSArray *)keys { return [_keys allObjects]; }
//- (void)setKeys:(NSArray *)keys { [_keys setObjectsFromArray:keys]; }

//- (NSArray *)values { return [_values allObjects]; }
//- (void)setValues:(NSArray *)values { [_values setObjectsFromArray:values]; }

+ (instancetype)dictionaryWithValuesForKeys:(NSArray *)keys fromDictionary:(NSDictionary *)dictionary
{
    MSDictionary * sourceDictionary = [MSDictionary dictionaryWithDictionary:dictionary];
    MSDictionary * returnDictionary = [sourceDictionary dictionaryWithValuesForKeys:keys];
    [returnDictionary compact];
    return returnDictionary;
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
                           stringByReplacingRegEx:@"^(\\s*\"[^\"]+\") :" withString:@"$1:"];
    }

    NSAssert(jsonString, @"failed to create JSON string for %@", ClassTagStringForInstance(self));

    return jsonString;
}

- (MSDictionary *)JSONDictionary { return self; }

////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)count { return [self.dictionary count]; }

- (id)objectForKey:(id)aKey { return [self.dictionary objectForKey:aKey]; }

+ (BOOL)supportsSecureCoding { return YES; }

- (Class)classForCoder { return [self class]; }

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_keys forKey:@"keys"];
    [aCoder encodeObject:_values forKey:@"values"];
    [aCoder encodeObject:_dictionary forKey:@"dictionary"];
    [aCoder encodeObject:@(_requiresStringKeys) forKey:@"requiresStringKeys"];
    [aCoder encodeObject:_userInfo forKey:@"userInfo"];
}

- (MSDictionary *)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.keys               = [aDecoder decodeObjectForKey:@"keys"];
        self.values             = [aDecoder decodeObjectForKey:@"values"];
        self.dictionary         = [aDecoder decodeObjectForKey:@"dictionary"];
        self.requiresStringKeys = [[aDecoder decodeObjectForKey:@"requiresStringKeys"] boolValue];
        self.userInfo           = [aDecoder decodeObjectForKey:@"userInfo"];
    }
    return self;
}

- (NSEnumerator *)keyEnumerator { return [self.keys objectEnumerator]; }

- (NSArray *)allKeysForObject:(id)anObject
{
    NSIndexSet * indexes = [self.values indexesOfObjectsPassingTest:
                            ^BOOL(id obj, NSUInteger idx, BOOL *stop)
                            {
                                return [obj isEqual:anObject];
                            }];
    return (indexes.count ? [self.keys objectsAtIndexes:indexes] : nil);
}

- (NSArray *)allKeys { return self.keys; }
- (NSArray *)allValues { return self.values; }

- (NSString *)description
{
    NSMutableArray * keyValuePairs = [@[] mutableCopy];
    for (int i = 0; i < [self count]; i++)
        [keyValuePairs addObject:$(@"'%@': '%@'", self.keys[i], self.values[i])];

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
        UnsignedIntegerValue([self.keys valueForKeyPath:@"@max.description.length"]);
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

- (NSEnumerator *)objectEnumerator { return [self.values objectEnumerator]; }

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker
{
    NSMutableArray * objects = [@[] mutableCopy];
    for (id key in keys) [objects addObject:(self[key] ?: marker)];
    return objects;
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys
{
    NSRange r = NSMakeRange(0, [self count]);
    if (objects) [self.values getObjects:objects range:r];
    if (keys) [self.keys getObjects:keys range:r];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx { return self.values[idx]; }

- (id)objectAtIndex:(NSUInteger)idx { return [self objectAtIndexedSubscript:idx]; }

- (id)keyAtIndex:(NSUInteger)idx { return self.keys[idx]; }

- (MSDictionary *)dictionaryBySortingByKeys:(NSArray *)sortedKeys
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
        self.dictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
        self.keys = [NSMutableArray arrayWithObjects:keys count:cnt];
        self.values = [NSMutableArray arrayWithObjects:objects count:cnt];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [MSDictionary dictionaryWithObjects:self.values forKeys:self.keys];
}

- (id)mutableCopyWithZone:(NSZone *)zone { return [self copyWithZone:zone]; }

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id [])buffer
                                    count:(NSUInteger)len
{
    return [self.keys countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)compact
{
    [self removeObjectsForKeys:[[self.dictionary keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop)
                                {
                                    return ValueIsNil(obj);
                                }] allObjects]];
}

- (void)compress
{
    MSDictionary * replacementKeys = [MSDictionary dictionary];
    MSDictionary * replacementValues = [MSDictionary dictionary];

    [self enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop)
     {
         if (!(isStringKind(key) && isDictionaryKind(obj) && [obj count] == 1)) return;
         id innerKey = [obj allKeys][0];
         if (!isStringKind(innerKey)) return;

         NSString * keypath = [@"." join:@[key, innerKey]];
         id value = obj[innerKey];
         NSUInteger index = [self.keys indexOfObject:key];
         replacementKeys[@(index)] = keypath;
         replacementValues[@(index)] = value;
     }];

    for (NSNumber * indexValue in replacementKeys)
    {
        NSUInteger index = [indexValue unsignedIntegerValue];
        id key = self.keys[index];
        [self removeObjectForKey:key];

        NSString * replacementKey = replacementKeys[indexValue];
        id value = replacementValues[indexValue];

        while (isDictionaryKind(value) && [value count] == 1 && isStringKind([value allKeys][0]))
        {
            replacementKey = [@"." join:@[replacementKey, [value allKeys][0]]];
            value = value[[value allKeys][0]];
        }

        self.dictionary[replacementKey] = value;
        [self.keys insertObject:replacementKey atIndex:index];
        [self.values insertObject:value atIndex:index];
    }
}

- (void)inflate
{
    assert(NO);
}

- (void)sortByKeys:(NSArray *)sortedKeys
{
    NSMutableOrderedSet * keys = [NSMutableOrderedSet orderedSetWithArray:sortedKeys];
    [keys intersectOrderedSet:[NSOrderedSet orderedSetWithArray:self.keys]];

    NSMutableOrderedSet * extraKeys = [keys mutableCopy];
    [extraKeys minusOrderedSet:keys];

    NSMutableArray * values = [@[] mutableCopy];
    for (id key in keys)
        [values addObject:self[key]];
    
    for (id key in extraKeys)
        [values addObject:self[key]];

    [keys addObjectsFromArray:[extraKeys array]];

    self.keys = [[keys array] mutableCopy];
    self.values = values;
}

- (void)sortKeysUsingSelector:(SEL)comparator
{
    [self.keys sortUsingSelector:comparator];
    self.values = [[self.dictionary objectsForKeys:self.keys notFoundMarker:NullObject] mutableCopy];
}

- (void)removeObjectForKey:(id)aKey
{
    if ([self.keys containsObject:aKey])
    {
        NSUInteger index = [self.keys indexOfObject:aKey];
        assert(index < [self.keys count]);
        [self.keys removeObjectAtIndex:index];
        [self.values removeObjectAtIndex:index];
        [self.dictionary removeObjectForKey:aKey];
    }
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    [self setObject:obj forKey:key];
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if ([self.keys containsObject:aKey])
    {
        NSUInteger index = [_keys indexOfObject:aKey];
        [self.values replaceObjectAtIndex:index withObject:anObject];
        [self.dictionary setObject:anObject forKey:aKey];
    }

    else
    {
        [self willChange:NSKeyValueChangeInsertion
         valuesAtIndexes:NSIndexSetMake([_keys count])
                  forKey:@"allKeys"];
        [self.keys addObject:aKey];
        [self.values addObject:anObject];
        [self.dictionary setObject:anObject forKey:aKey];
        [self didChange:NSKeyValueChangeInsertion
        valuesAtIndexes:NSIndexSetMake([_keys count] - 1)
                 forKey:@"allKeys"];
    }
}

- (void)removeAllObjects
{
    [self.dictionary removeAllObjects];
    [self.keys removeAllObjects];
    [self.values removeAllObjects];
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    NSIndexSet * indexes = [_keys indexesOfObjectsPassingTest:
                            ^BOOL(id obj, NSUInteger idx, BOOL *stop)
                            {
                                return [keyArray containsObject:obj];
                            }];
    [self.keys removeObjectsAtIndexes:indexes];
    [self.values removeObjectsAtIndexes:indexes];
    [self.dictionary removeObjectsForKeys:keyArray];
}


- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    if (self = [super init])
    {
        self.keys       = [NSMutableArray arrayWithCapacity:numItems];
        self.values     = [NSMutableArray arrayWithCapacity:numItems];
        self.dictionary = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }

    return self;
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    if (index >= [self.keys count]) ThrowInvalidIndexArgument(index);
    else [self removeObjectForKey:self.keys[index]];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    [self removeObjectsForKeys:[self.keys objectsAtIndexes:indexes]];
}

- (void)replaceKey:(id)key withKey:(id)replacementKey
{
    if (!replacementKey)
        ThrowInvalidNilArgument(replacementKey);

    else if ([self.keys containsObject:replacementKey])
        ThrowInvalidArgument(replacementKey, already has an entry);

    else if (![self.keys containsObject:key])
        ThrowInvalidArgument(key, has no entry);

    else
    {
        NSUInteger idx = [self.keys indexOfObject:key];
        id value = self.values[idx];
        [self.keys replaceObjectAtIndex:idx withObject:replacementKey];
        self.dictionary[replacementKey] = value;
        [self.dictionary removeObjectForKey:key];
    }
}

- (void)exchangeIndex:(NSUInteger)index withIndex:(NSUInteger)otherIndex
{
    if (index >= [self count]) ThrowInvalidIndexArgument(index);
    else if (otherIndex >= [self count]) ThrowInvalidIndexArgument(otherIndex);
    else
    {
        [self.keys exchangeObjectAtIndex:index withObjectAtIndex:otherIndex];
        [self.values exchangeObjectAtIndex:index withObjectAtIndex:otherIndex];
    }
}

- (NSUInteger)indexForKey:(id)key { return [self.keys indexOfObject:key]; }
- (NSUInteger)indexForValue:(id)value { return [self.values indexOfObject:value]; }

- (MSDictionary *)userInfo
{
    if (!_userInfo) self.userInfo = [MSDictionary dictionary];
    return _userInfo;
}

@end
