//
//  NSDictionary+MSKitAdditions.m
//  MSKit
//
//  Created by Jason Cardwell on 10/25/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "NSDictionary+MSKitAdditions.h"
#import "MSJSONSerialization.h"
#import "MSKitMacros.h"
#import "NSObject+MSKitAdditions.h"
#import "MSDictionary.h"

static int ddLogLevel = LOG_LEVEL_DEBUG;
static int msLogContext = LOG_CONTEXT_CONSOLE;
#pragma unused(ddLogLevel,msLogContext)

@implementation NSDictionary (MSKitAdditions)

/// isEmpty
/// @return BOOL
- (BOOL)isEmpty { return self.count == 0; }

/// JSONString
/// @return NSString *
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


/// JSONObject
/// @return id
- (id)JSONObject
{
    if ([NSJSONSerialization isValidJSONObject:self])
        return self;

    else if (![self count])
        return NullObject;

    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:[self count]];

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

/// dictionaryFromDictionary:replacements:
/// @param dictionary description
/// @param replacements description
/// @return instancetype
+ (instancetype)dictionaryFromDictionary:(NSDictionary *)dictionary
                            replacements:(NSDictionary *)replacements
{
    NSMutableDictionary * d = [dictionary mutableCopy];
    for (id key in replacements) {
        NSArray * objectKeys = [dictionary allKeysForObject:key];
        for (id objectKey in objectKeys) {
            d[objectKey] = replacements[key];
        }

    }
    return [self dictionaryWithDictionary:d];
}

/// dictionaryWithSharedKeys:
/// @param keys description
/// @return instancetype
+ (instancetype)dictionaryWithSharedKeys:(NSArray *)keys
{
    id sharedKeySet = [NSDictionary sharedKeySetForKeys:keys];
    return (sharedKeySet ? [[self class] dictionaryWithSharedKeySet:sharedKeySet] : nil);
}

/// dictionaryByRemovingEntriesForKeys:
/// @param keys description
/// @return instancetype
- (instancetype)dictionaryByRemovingEntriesForKeys:(NSArray *)keys
{
    NSMutableDictionary * dictionary = [self mutableCopy];
    [dictionary removeObjectsForKeys:keys];
    return [[self class] dictionaryWithDictionary:dictionary];
}

/// dictionaryByRemovingEntryForKey:
/// @param key description
/// @return instancetype
- (instancetype)dictionaryByRemovingEntryForKey:(id<NSCopying>)key
{
    return ([self hasKey:key] ? [self dictionaryByRemovingEntriesForKeys:@[key]] : self);
}

/// dictionaryByAddingEntriesFromDictionary:
/// @param dictionary description
/// @return instancetype
- (instancetype)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary * d = [self mutableCopy];
    [d addEntriesFromDictionary:dictionary];
    return [[self class] dictionaryWithDictionary:d];
}

/// dictionaryByMappingObjectsToBlock:
/// @param block description
/// @return instancetype
- (instancetype)dictionaryByMappingObjectsToBlock:(id (^)(id key, id obj))block
{
    NSMutableDictionary * d = [self mutableCopy];
    [d mapObjectsToBlock:block];
    return [[self class] dictionaryWithDictionary:d];
}

/// dictionaryByMappingKeysToBlock:
/// @param block description
/// @return instancetype
- (instancetype)dictionaryByMappingKeysToBlock:(id (^)(id key, id obj))block
{
    NSMutableDictionary * d = [self mutableCopy];
    [d mapKeysToBlock:block];
    return [[self class] dictionaryWithDictionary:d];
}

/// hasKey:
/// @param key description
/// @return BOOL
- (BOOL)hasKey:(id)key {
    return (CFDictionaryContainsKey((__bridge CFDictionaryRef)(self), (__bridge const void *)(key)));
}

/// MSDictionaryValue
/// @return MSDictionary *
- (MSDictionary *)MSDictionaryValue { return [MSDictionary dictionaryWithDictionary:self]; }

@end

@implementation NSMutableDictionary (MSKitAdditions)

/// mapObjectsToBlock:
/// @param block description
- (void)mapObjectsToBlock:(id (^)(id key, id obj))block {
    for (id key in [self allKeys])
    {
        self[key] = block(key, self[key]);
    }
}

/// mapKeysToBlock:
/// @param block description
- (void)mapKeysToBlock:(id (^)(id key, id obj))block {
    for (id key in [self allKeys])
    {
        id object = self[key];
        id kPrime = block(key, object);
        [self removeObjectForKey:key];
        self[kPrime] = object;
    }
}

@end
