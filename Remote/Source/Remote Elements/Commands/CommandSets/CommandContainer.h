//
// CommandContainer.h
// Remote
//
// Created by Jason Cardwell on 6/29/11.
// Copyright (c) 2011 Moondeer Studios. All rights reserved.
//
#import "ModelObject.h"
#import "RETypedefs.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Command Container
////////////////////////////////////////////////////////////////////////////////

@interface CommandContainer : ModelObject <NamedModelObject>

+ (instancetype)commandContainerInContext:(NSManagedObjectContext *)context;

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@property (nonatomic, copy, readwrite) NSString * name;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Set
////////////////////////////////////////////////////////////////////////////////
@class   Command, IRCode, ButtonGroup;

@interface CommandSet : CommandContainer

+ (instancetype)commandSetWithType:(CommandSetType)type;
+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context type:(CommandSetType)type;
+ (instancetype)commandSetInContext:(NSManagedObjectContext *)context
                           withType:(CommandSetType)type
                               name:(NSString *)name
                             values:(NSDictionary *)values;

+ (instancetype)commandSetWithType:(CommandSetType)type
                              name:(NSString *)name
                            values:(NSDictionary *)values;

- (void)setObject:(Command *)command forKeyedSubscript:(id<NSCopying>)key;
- (Command *)objectForKeyedSubscript:(id<NSCopying>)key;

@property (nonatomic, readonly) CommandSetType   type;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Command Set Collections
////////////////////////////////////////////////////////////////////////////////


@interface CommandSetCollection : CommandContainer

@property (nonatomic, strong) NSOrderedSet * commandSets;

- (void)setObject:(id)label forKeyedSubscript:(CommandSet *)commandSet;
- (NSAttributedString *)objectForKeyedSubscript:(CommandSet *)commandSet;

- (void)setObject:(CommandSet *)commandSet atIndexedSubscript:(NSUInteger)idx;
- (CommandSet *)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface CommandSetCollection (CommandSetAccessors)

- (void)insertObject:(CommandSet *)value inCommandSetsAtIndex:(NSUInteger)index;
- (void)removeObjectFromCommandSetsAtIndex:(NSUInteger)index;
- (void)insertCommandSets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommandSetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommandSetsAtIndex:(NSUInteger)index withObject:(CommandSet *)value;
- (void)replaceCommandSetsAtIndexes:(NSIndexSet *)indexes withCommandSets:(NSArray *)values;
- (void)addCommandSetsObject:(CommandSet *)value;
- (void)removeCommandSetsObject:(CommandSet *)value;
- (void)addCommandSets:(NSOrderedSet *)values;
- (void)removeCommandSets:(NSOrderedSet *)values;

@end
