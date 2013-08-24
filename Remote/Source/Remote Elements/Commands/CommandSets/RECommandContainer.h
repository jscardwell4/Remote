//
// RECommandContainer.h
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Command Container
////////////////////////////////////////////////////////////////////////////////

@interface RECommandContainer : MSModelObject <MSNamedModelObject>

+ (instancetype)commandContainerInContext:(NSManagedObjectContext *)context;

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@property (nonatomic, copy, readwrite) NSString * name;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Set
////////////////////////////////////////////////////////////////////////////////
@class   RECommand, BOIRCode, REButtonGroup;

@interface RECommandSet : RECommandContainer

+ (instancetype)commandSetWithType:(RECommandSetType)type;
+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(RECommandSetType)type;
+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context
                           withType:(RECommandSetType)type
                               name:(NSString *)name
                             values:(NSDictionary *)values;

+ (instancetype)commandSetWithType:(RECommandSetType)type
                              name:(NSString *)name
                            values:(NSDictionary *)values;

- (void)setObject:(RECommand *)command forKeyedSubscript:(id<NSCopying>)key;
- (RECommand *)objectForKeyedSubscript:(id<NSCopying>)key;

@property (nonatomic, readonly) RECommandSetType   type;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Set Collections
////////////////////////////////////////////////////////////////////////////////


@interface RECommandSetCollection : RECommandContainer

@property (nonatomic, strong) NSOrderedSet * commandSets;

- (void)setObject:(id)label forKeyedSubscript:(RECommandSet *)commandSet;
- (NSAttributedString *)objectForKeyedSubscript:(RECommandSet *)commandSet;

- (void)setObject:(RECommandSet *)commandSet atIndexedSubscript:(NSUInteger)idx;
- (RECommandSet *)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface RECommandSetCollection (CommandSetAccessors)

- (void)insertObject:(RECommandSet *)value inCommandSetsAtIndex:(NSUInteger)index;
- (void)removeObjectFromCommandSetsAtIndex:(NSUInteger)index;
- (void)insertCommandSets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommandSetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommandSetsAtIndex:(NSUInteger)index withObject:(RECommandSet *)value;
- (void)replaceCommandSetsAtIndexes:(NSIndexSet *)indexes withCommandSets:(NSArray *)values;
- (void)addCommandSetsObject:(RECommandSet *)value;
- (void)removeCommandSetsObject:(RECommandSet *)value;
- (void)addCommandSets:(NSOrderedSet *)values;
- (void)removeCommandSets:(NSOrderedSet *)values;

@end
