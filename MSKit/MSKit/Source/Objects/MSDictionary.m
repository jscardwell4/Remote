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
#import "MSKitMacros.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)


////////////////////////////////////////////////////////////////////////////////
#pragma mark - MSDictionary
////////////////////////////////////////////////////////////////////////////////

@interface MSDictionary ()

@property (nonatomic, strong, readwrite) NSMutableArray * keys;
@property (nonatomic, strong, readwrite) NSMutableArray * values;
@property (nonatomic, strong, readwrite) NSMutableDictionary * dictionary;

@end


@implementation MSDictionary
{
    MSDictionary * _userInfo;
    BOOL           _isUserInfo;
    NSSet        * _validKeys;
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


////////////////////////////////////////////////////////////////////////////////
#pragma mark MSDictionary methods
////////////////////////////////////////////////////////////////////////////////

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

- (MSDictionary *)compactedDictionary
{
    MSDictionary * dictionary = [self copy];
    [dictionary compact];

    return dictionary;
}

- (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys
{
    NSDictionary * source = [super dictionaryWithValuesForKeys:keys];
    MSDictionary * dictionary = [MSDictionary dictionaryWithDictionary:source];
    [dictionary compact];

    return dictionary;
}

+ (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys
                               fromDictionary:(NSDictionary *)dictionary
{
    MSDictionary * sourceDictionary = [MSDictionary dictionaryWithDictionary:dictionary];
    MSDictionary * returnDictionary = [sourceDictionary dictionaryWithValuesForKeys:keys];
    [returnDictionary compact];

    return returnDictionary;
}

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

- (id)objectAtIndexedSubscript:(NSUInteger)idx { return self.values[idx]; }

- (id)objectAtIndex:(NSUInteger)idx { return [self objectAtIndexedSubscript:idx]; }

- (id)keyAtIndex:(NSUInteger)idx { return self.keys[idx]; }

- (MSDictionary *)dictionaryBySortingByKeys:(NSArray *)sortedKeys
{
    MSDictionary * dictionary = [MSDictionary dictionaryWithDictionary:self];
    [dictionary sortByKeys:sortedKeys];
    return dictionary;
}

- (NSSet *)validKeys { return _validKeys; }

- (BOOL)isValidKey:(id<NSCopying>)key
{
    if (_validKeys)
        return [_validKeys containsObject:key];

    else if (_requiresStringKeys)
        return isStringKind((id)key);

    else return YES;
}


- (void)compact
{
    NSDictionaryPredicateBlock test = ^BOOL(id key, id obj, BOOL *stop) { return ValueIsNil(obj); };
    NSArray * keysToRemove = [[self.dictionary keysOfEntriesPassingTest:test] allObjects];
    [self removeObjectsForKeys:keysToRemove];
}

- (void)compress
{
    MSDictionary * replacementKeys   = [MSDictionary dictionary];
    MSDictionary * replacementValues = [MSDictionary dictionary];

    NSDictionaryEnumerationBlock enumerate =
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
        };

    [self enumerateKeysAndObjectsUsingBlock:enumerate];

    for (NSNumber * indexValue in replacementKeys)
    {
        NSUInteger index = UnsignedIntegerValue(indexValue);
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
    for (id key in keys) [values addObject:self[key]];
    for (id key in extraKeys) [values addObject:self[key]];

    [keys addObjectsFromArray:[extraKeys array]];

    self.keys = [[keys array] mutableCopy];
    self.values = values;
}

- (void)sortKeysUsingSelector:(SEL)comparator
{
    [self.keys sortUsingSelector:comparator];
    self.values = [[self.dictionary objectsForKeys:self.keys notFoundMarker:NullObject] mutableCopy];
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

- (void)exchangeKeyValueAtIndex:(NSUInteger)index withKeyValueAtIndex:(NSUInteger)otherIndex
{
    if (index >= [self count]) ThrowInvalidIndexArgument(index);
    else if (otherIndex >= [self count]) ThrowInvalidIndexArgument(otherIndex);
    else
    {
        [self.keys exchangeObjectAtIndex:index withObjectAtIndex:otherIndex];
        [self.values exchangeObjectAtIndex:index withObjectAtIndex:otherIndex];
    }
}

- (NSUInteger)indexForKey:(id)key { return [_keys indexOfObject:key]; }

- (NSUInteger)indexForValue:(id)value { return [self indexOfObject:value]; }


- (void)insertObject:(id)object forKey:(id<NSCopying>)key atIndex:(NSUInteger)index
{
    if (!object) ThrowInvalidNilArgument(object);
    else if (!key) ThrowInvalidNilArgument(key);
    else if (index >= [self count]) ThrowInvalidIndexArgument(index);
    else
    {
        [_keys insertObject:key atIndex:index];
        [_values insertObject:object atIndex:index];
        [_dictionary setObject:object forKey:key];
    }
}

- (void)setUserInfo:(MSDictionary *)userInfo
{
    if (_isUserInfo) ThrowInvalidInternalInconsistency(cannot add userInfo to a userInfo dictionary);
    else
    {
        _userInfo = userInfo;
        if (_userInfo) _userInfo->_isUserInfo = YES;
    }
}

- (MSDictionary *)userInfo
{
    if (!_isUserInfo && !_userInfo) self.userInfo = [MSDictionary dictionary];
    return _userInfo;
}

- (id)keyForObject:(id)object
{
    NSUInteger index = [self indexOfObject:object];
    return (index == NSNotFound ? nil : _keys[index]);
}

- (NSUInteger)indexOfObject:(id)object { return [_values indexOfObject:object]; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark JSON export
////////////////////////////////////////////////////////////////////////////////


- (id)JSONObject
{
    if ([NSJSONSerialization isValidJSONObject:self]) return self;

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

- (NSString *)JSONString { return [MSJSONSerialization JSONFromObject:self.JSONObject]; }

- (MSDictionary *)JSONDictionary { return self; }


////////////////////////////////////////////////////////////////////////////////
#pragma mark Superclass overrides
////////////////////////////////////////////////////////////////////////////////


- (NSUInteger)count { return [self.dictionary count]; }

- (id)objectForKey:(id)aKey { return [self.dictionary objectForKey:aKey]; }

- (Class)classForCoder { return [self class]; }

MSSTATIC_KEY(MSDictionaryKeysStorage);
MSSTATIC_KEY(MSDictionaryValuesStorage);
MSSTATIC_KEY(MSDictionaryDictionaryStorage);
MSSTATIC_KEY(MSDictionaryStringKeysStorage);
MSSTATIC_KEY(MSDictionaryIsUserInfoStorage);
MSSTATIC_KEY(MSDictionaryUserInfoStorage);
MSSTATIC_KEY(MSDictionaryValidKeysStorage);

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if ([aCoder allowsKeyedCoding])
    {
        [super encodeWithCoder:aCoder];
        [aCoder encodeObject:_keys             forKey:MSDictionaryKeysStorageKey];
        [aCoder encodeObject:_values           forKey:MSDictionaryValuesStorageKey];
        [aCoder encodeObject:_dictionary       forKey:MSDictionaryDictionaryStorageKey];
        [aCoder encodeBool:_requiresStringKeys forKey:MSDictionaryStringKeysStorageKey];
        [aCoder encodeObject:_validKeys        forKey:MSDictionaryValidKeysStorageKey];
        [aCoder encodeBool:_isUserInfo         forKey:MSDictionaryIsUserInfoStorageKey];
        [aCoder encodeObject:_userInfo         forKey:MSDictionaryUserInfoStorageKey];
    }
}

- (MSDictionary *)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]) && [aDecoder allowsKeyedCoding])
    {
        _keys               = [aDecoder decodeObjectForKey:MSDictionaryKeysStorageKey];
        _values             = [aDecoder decodeObjectForKey:MSDictionaryValuesStorageKey];
        _dictionary         = [aDecoder decodeObjectForKey:MSDictionaryDictionaryStorageKey];
        _requiresStringKeys = [aDecoder decodeBoolForKey:MSDictionaryStringKeysStorageKey];
        _validKeys          = [aDecoder decodeObjectForKey:MSDictionaryValidKeysStorageKey];
        _isUserInfo         = [aDecoder decodeBoolForKey:MSDictionaryIsUserInfoStorageKey];
        _userInfo           = [aDecoder decodeObjectForKey:MSDictionaryUserInfoStorageKey];
    }

    return self;
}

- (BOOL)isEqualToDictionary:(MSDictionary *)otherDictionary
{
    if (self == otherDictionary) return YES;
    else if (!isMSDictionary(otherDictionary)) return NO;
    else return (   [_keys isEqualToArray:otherDictionary->_keys]
                 && [_values isEqualToArray:otherDictionary->_values]);
}

- (NSEnumerator *)keyEnumerator { return [self.keys objectEnumerator]; }

- (NSArray *)allKeysForObject:(id)anObject
{
    NSArrayPredicateBlock test =
        ^BOOL(id obj, NSUInteger idx, BOOL *stop)
        {
            return [obj isEqual:anObject];
        };

    NSIndexSet * indexes = [self.values indexesOfObjectsPassingTest:test];

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

- (MSDictionary *)initWithObjects:(const id [])objects
                          forKeys:(const id <NSCopying> [])keys
                            count:(NSUInteger)cnt
{
    if (self = [super initWithObjects:objects forKeys:keys count:cnt])
    {
        self.dictionary = [[NSMutableDictionary alloc] initWithObjects:objects
                                                               forKeys:keys
                                                                 count:cnt];
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

+ (instancetype)dictionaryWithSharedKeySet:(id)keyset
{
    return [[self alloc] initWithSharedKeySet:keyset];
}

- (MSDictionary *)initWithSharedKeySet:(id)keyset
{
    if (self = [super init])
    {
        _validKeys = [[keyset allKeys] set];

        NSUInteger capacity = [keyset count];

        _keys       = [NSMutableArray arrayWithCapacity:capacity];
        _values     = [NSMutableArray arrayWithCapacity:capacity];
        _dictionary = [NSMutableDictionary dictionaryWithSharedKeySet:keyset];
    }

    return self;
}

- (void)removeObjectForKey:(id)aKey
{
    if ([self.keys containsObject:aKey])
    {
        NSUInteger index = [self.keys indexOfObject:aKey];
        [self.keys removeObjectAtIndex:index];
        [self.values removeObjectAtIndex:index];
        [self.dictionary removeObjectForKey:aKey];
    }
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key { [self setObject:obj forKey:key]; }

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if ([self.keys containsObject:aKey])
    {
        NSUInteger index = [_keys indexOfObject:aKey];

        [self willChange:NSKeyValueChangeReplacement
         valuesAtIndexes:NSIndexSetMake(index)
                  forKey:@"allKeys"];

        [self.values replaceObjectAtIndex:index withObject:anObject];
        [self.dictionary setObject:anObject forKey:aKey];

        [self didChange:NSKeyValueChangeReplacement
        valuesAtIndexes:NSIndexSetMake(index)
                 forKey:@"allKeys"];
}

    else
    {
        NSUInteger count = [_keys count];

        [self willChange:NSKeyValueChangeInsertion
         valuesAtIndexes:NSIndexSetMake(count++)
                  forKey:@"allKeys"];

        [self.keys addObject:aKey];
        [self.values addObject:anObject];
        [self.dictionary setObject:anObject forKey:aKey];

        [self didChange:NSKeyValueChangeInsertion
        valuesAtIndexes:NSIndexSetMake(count)
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
    NSArrayPredicateBlock test =
        ^BOOL(id obj, NSUInteger idx, BOOL *stop)
        {
            return [keyArray containsObject:obj];
        };

    NSIndexSet * indexes = [_keys indexesOfObjectsPassingTest:test];

    [self.keys removeObjectsAtIndexes:indexes];
    [self.values removeObjectsAtIndexes:indexes];
    [self.dictionary removeObjectsForKeys:keyArray];
}


- (MSDictionary *)initWithCapacity:(NSUInteger)numItems
{
    if (self = [super init])
    {
        self.keys       = [NSMutableArray arrayWithCapacity:numItems];
        self.values     = [NSMutableArray arrayWithCapacity:numItems];
        self.dictionary = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }

    return self;
}

@end
