//
//  MSDictionary.h
//  MSKit
//
//  Created by Jason Cardwell on 4/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSKitProtocols.h"

@interface MSDictionary : NSMutableDictionary <MSJSONExport>

@property (nonatomic, strong) MSDictionary * userInfo;

@property (nonatomic, assign) BOOL requiresStringKeys;

- (MSDictionary *)dictionaryBySortingByKeys:(NSArray *)sortedKeys;
- (MSDictionary *)dictionaryByRemovingKeysWithNullObjectValues;
- (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;
+ (instancetype)dictionaryWithValuesForKeys:(NSArray *)keys fromDictionary:(NSDictionary *)dictionary;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectAtIndex:(NSUInteger)idx;
- (id)keyAtIndex:(NSUInteger)idx;

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

- (void)exchangeIndex:(NSUInteger)index withIndex:(NSUInteger)otherIndex;

- (NSUInteger)indexForKey:(id)key;
- (NSUInteger)indexForValue:(id)value;

@end