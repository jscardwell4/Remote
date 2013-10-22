//
//  NSDictionary+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 10/25/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSKitProtocols.h"

@interface NSDictionary (MSKitAdditions) <MSJSONExport>

+ (NSDictionary *)dictionaryFromDictionary:(NSDictionary *)dictionary
                              replacements:(NSDictionary *)replacements;

- (NSDictionary *)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryByRemovingEntryForKey:(id<NSCopying>)key;

- (NSDictionary *)dictionaryByRemovingEntriesForKeys:(NSArray *)keys;

- (NSDictionary *)dictionaryByMappingObjectsToBlock:(id (^)(id key, id obj))block;

- (NSDictionary *)dictionaryByMappingKeysToBlock:(id (^)(id key, id obj))block;

- (BOOL)hasKey:(id)key;
@end

@interface NSMutableDictionary (MSKitAdditions)

- (void)mapObjectsToBlock:(id (^)(id key, id obj))block;
- (void)mapKeysToBlock:(id (^)(id key, id obj))block;

@end