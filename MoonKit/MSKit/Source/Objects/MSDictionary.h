//
//  MSDictionary.h
//  MSKit
//
//  Created by Jason Cardwell on 4/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
@import Foundation;
@import UIKit;
#import "MSKitProtocols.h"

@class MSKeyPath;

@interface MSDictionary : NSMutableDictionary <MSJSONExport, MSKeySearchable, MSKeyContaining, MSObjectContaining>

@property (nonatomic, strong)   MSDictionary * userInfo;
@property (nonatomic, readonly) NSSet        * validKeys;
@property (nonatomic, assign)   BOOL           requiresStringKeys;
@property (nonatomic, readonly) NSDictionary * NSDictionaryValue;
@property (nonatomic, readonly) BOOL           isEmpty;
@property (nonatomic, readonly) id<NSCopying>  firstKey;
@property (nonatomic, readonly) id<NSCopying>  lastKey;
@property (nonatomic, readonly) id             firstValue;
@property (nonatomic, readonly) id             lastValue;

+ (MSDictionary *)dictionaryWithDictionary:(NSDictionary *)dictionary convertFoundationClasses:(BOOL)convert;
- (void)convertFoundationClasses;
- (MSDictionary *)dictionaryBySortingByKeys:(NSArray *)sortedKeys;
- (MSDictionary *)compactedDictionary;
- (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;
+ (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys
                               fromDictionary:(NSDictionary *)dictionary;
+ (MSDictionary *)dictionaryByParsingArray:(NSArray *)array;
+ (MSDictionary *)dictionaryByParsingArray:(NSArray *)array separator:(NSString *)separator;
+ (MSDictionary *)dictionaryByParsingXML:(NSData *)xmlData;
+ (MSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys usingBlock:(id (^)(id<NSCopying> key))block;

- (instancetype)initWithValues:(NSArray *)values forKeys:(NSArray *)keys;

- (BOOL)isValidKey:(id<NSCopying>)key;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectAtIndex:(NSUInteger)idx;
- (id)keyAtIndex:(NSUInteger)idx;

- (id)keyForObject:(id)object;
- (NSUInteger)indexOfObject:(id)object;

- (id)valueForPath:(MSKeyPath *)path;

- (id)popObjectForKey:(id<NSCopying>)key;

- (NSString *)formattedDescription;
- (NSString *)formattedDescriptionWithLevelIndent:(NSUInteger)levelIndent;
- (NSString *)formattedDescriptionWithOptions:(NSUInteger)options levelIndent:(NSUInteger)levelIndent;

/// Removes all keys for which the value is the null object
- (void)compact;

/// Recursively looks for values that are of a dictionary type with only one key-value pair and
/// replaces with keypath-value pair
- (void)compress;

/// Recursively looks for keypath-value pairs and expands into key-dictionary pairs
//- (void)inflate;

- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;

- (void)sortByKeys:(NSArray *)sortedKeys;
- (void)sortKeysUsingSelector:(SEL)comparator;

- (void)filter:(BOOL (^)(id<NSCopying> key, id value))predicate;

- (void)replaceKeysUsingKeyMap:(NSDictionary *)keyMap;
- (void)replaceKey:(id)key withKey:(id)replacementKey;

- (void)exchangeKeyValueAtIndex:(NSUInteger)index withKeyValueAtIndex:(NSUInteger)otherIndex;

- (void)insertObject:(id)object forKey:(id<NSCopying>)key atIndex:(NSUInteger)index;

- (NSUInteger)indexForKey:(id)key;
- (NSUInteger)indexForValue:(id)value;

@end
