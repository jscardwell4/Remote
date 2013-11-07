//
//  MSDictionary.h
//  MSKit
//
//  Created by Jason Cardwell on 4/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSKitProtocols.h"

@interface MSDictionary : NSMutableDictionary <MSJSONExport>

@property (nonatomic, strong)   MSDictionary * userInfo;
@property (nonatomic, readonly) NSSet        * validKeys;
@property (nonatomic, assign)   BOOL           requiresStringKeys;

- (MSDictionary *)dictionaryBySortingByKeys:(NSArray *)sortedKeys;
- (MSDictionary *)compactedDictionary;
- (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;
+ (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys
                               fromDictionary:(NSDictionary *)dictionary;

- (BOOL)isValidKey:(id<NSCopying>)key;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectAtIndex:(NSUInteger)idx;
- (id)keyAtIndex:(NSUInteger)idx;

- (id)keyForObject:(id)object;
- (NSUInteger)indexOfObject:(id)object;

- (NSString *)formattedDescriptionWithOptions:(NSUInteger)options levelIndent:(NSUInteger)levelIndent;

/// Removes all keys for which the value is the null object
- (void)compact;

/// Recursively looks for values that are of a dictionary type with only one key-value pair and
/// replaces with keypath-value pair
- (void)compress;

/// Recursively looks for keypath-value pairs and expands into key-dictionary pairs
- (void)inflate;

- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;

- (void)sortByKeys:(NSArray *)sortedKeys;
- (void)sortKeysUsingSelector:(SEL)comparator;

- (void)replaceKey:(id)key withKey:(id)replacementKey;

- (void)exchangeKeyValueAtIndex:(NSUInteger)index withKeyValueAtIndex:(NSUInteger)otherIndex;

- (void)insertObject:(id)object forKey:(id<NSCopying>)key atIndex:(NSUInteger)index;

- (NSUInteger)indexForKey:(id)key;
- (NSUInteger)indexForValue:(id)value;

@end