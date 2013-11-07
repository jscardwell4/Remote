//
//  NSDictionary+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 10/25/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSKitProtocols.h"

typedef void(^NSDictionaryEnumerationBlock)(id obj, id key, BOOL *stop);
typedef BOOL(^NSDictionaryPredicateBlock)  (id obj, id key, BOOL *stop);
typedef id  (^NSDictionaryMappingBlock)    (id obj, id key);

@interface NSDictionary (MSKitAdditions) <MSJSONExport>

+ (instancetype)dictionaryFromDictionary:(NSDictionary *)dictionary
                            replacements:(NSDictionary *)replacements;

+ (instancetype)dictionaryWithSharedKeys:(NSArray *)keys;

- (instancetype)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary;

- (instancetype)dictionaryByRemovingEntryForKey:(id<NSCopying>)key;

- (instancetype)dictionaryByRemovingEntriesForKeys:(NSArray *)keys;

- (instancetype)dictionaryByMappingObjectsToBlock:(id (^)(id key, id obj))block;

- (instancetype)dictionaryByMappingKeysToBlock:(id (^)(id key, id obj))block;

- (BOOL)hasKey:(id)key;

@end

@interface NSMutableDictionary (MSKitAdditions)

- (void)mapObjectsToBlock:(id (^)(id key, id obj))block;
- (void)mapKeysToBlock:(id (^)(id key, id obj))block;

@end
