//
//  MSDictionary.h
//  MSKit
//
//  Created by Jason Cardwell on 4/17/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSKitProtocols.h"

@interface MSDictionary : NSMutableDictionary <MSJSONExport>

- (instancetype)dictionaryBySortingByKeys:(NSArray *)sortedKeys;
- (instancetype)dictionaryByRemovingKeysWithNullObjectValues;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectAtIndex:(NSUInteger)idx;
- (id)keyAtIndex:(NSUInteger)idx;

- (NSString *)formattedDescriptionWithOptions:(NSUInteger)options levelIndent:(NSUInteger)levelIndent;

- (void)removeKeysWithNullObjectValues;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;

- (void)sortByKeys:(NSArray *)sortedKeys;

@end