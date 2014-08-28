//
// ControlStateSet.h
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ControlStateSet
////////////////////////////////////////////////////////////////////////////////

@interface ControlStateSet : ModelObject <NSCopying>

+ (instancetype)controlStateSet;
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc;
+ (instancetype)controlStateSetInContext:(NSManagedObjectContext *)moc
                             withObjects:(NSDictionary *)objects;

+ (BOOL)validState:(id)state;
+ (NSString *)propertyForState:(NSNumber *)state;
+ (NSUInteger)stateForProperty:(NSString *)property;
+ (NSSet *)validProperties;
+ (NSString *)attributeKeyFromKey:(id)key;

- (BOOL)isEmptySet;
- (NSDictionary *)dictionaryFromSetObjects:(BOOL)useJSONKeys;

// objectAtIndex: and objectForKey: do not use fall through logic
// where as objectAtIndexedSubscript: and objectForKeyedSubscript: do use fall through logic

- (id)objectAtIndex:(NSUInteger)state;
- (id)objectForKey:(NSString *)key;
- (id)objectAtIndexedSubscript:(NSUInteger)state;
- (id)objectForKeyedSubscript:(NSString *)key;

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)state;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forStates:(NSArray *)states;

- (void)copyObjectsFromSet:(ControlStateSet *)set;

@end
