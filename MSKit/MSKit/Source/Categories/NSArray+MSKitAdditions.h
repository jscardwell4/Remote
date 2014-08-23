//
//  NSMutableArray+MSKitAdditions.h
//  MSKit
//
//  Created by Jason Cardwell on 5/24/11.
//  Copyright 2011 Moondeer Studios. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MSKitDefines.h"
#import "MSKitProtocols.h"

typedef void(^NSArrayEnumerationBlock)(id obj, NSUInteger idx, BOOL *stop);
typedef BOOL(^NSArrayPredicateBlock)  (id obj, NSUInteger idx, BOOL *stop);
typedef id  (^NSArrayMappingBlock)    (id obj, NSUInteger idx);


@interface NSArray (MSKitAdditions) <MSJSONExport>

+ (NSArray *)arrayFromRange:(NSRange)range;

@property (nonatomic, readonly) id JSONObject;

- (NSSet *)set;
- (NSUInteger)lastIndex;
- (NSOrderedSet *)orderedSet;

- (NSArray *)arrayByAddingObjects:(id)objects;
- (NSArray *)arrayByAddingKeysFromDictionary:(NSDictionary *)dictionary;
- (NSArray *)arrayByAddingValuesFromDictionary:(NSDictionary *)dictionary;
- (NSArray *)arrayByAddingObjectsFromSet:(NSSet *)set;
- (NSArray *)arrayByRemovingNullObjects;
- (NSArray *)arrayByAddingObjectsFromOrderedSet:(NSOrderedSet *)orderedSet;
- (NSArray *)filteredArrayUsingPredicateWithFormat:(NSString *)format,...;
- (NSArray *)filteredArrayUsingPredicateWithBlock:(BOOL (^)(id evaluatedObject,
                                                            NSDictionary * bindings))block;
- (NSArray *)filter:(BOOL (^)(id evaluatedObject))block;
- (id)objectPassingTest:(BOOL (^)(id obj, NSUInteger idx))predicate;
- (NSArray *)objectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSArray *)arrayByMappingToBlock:(id (^)(id obj, NSUInteger idx))block;
- (NSArray *)flattenedArray;

- (void)makeObjectsPerformSelectorBlock:(void (^)(id object))block;

@end


@interface NSMutableArray (MSKitAdditions)
+ (id)arrayWithNullCapacity:(NSUInteger)capacity;
- (void)filter:(BOOL (^)(id evaluatedObject))block;
- (void)map:(id (^)(id obj, NSUInteger idx))block;
- (void)replaceAllObjectsWithNull;
- (void)removeNullObjects;
- (void)flatten;
@end

#define NSArrayOfVariableNames(...) \
_NSArrayOfVariableNames(@"" # __VA_ARGS__, __VA_ARGS__, nil)

MSEXTERN NSArray * _NSArrayOfVariableNames(NSString * commaSeparatedNamesString, ...);
