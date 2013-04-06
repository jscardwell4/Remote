// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MacroCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"





extern const struct MacroCommandRelationships {
	 NSString *commands;
} MacroCommandRelationships;






@class Command;


@interface MacroCommandID : CommandID {}
@end

@interface _MacroCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MacroCommandID*)objectID;





@property (nonatomic, retain) NSOrderedSet *commands;

- (NSMutableOrderedSet*)commandsSet;





@end


@interface _MacroCommand (CommandsCoreDataGeneratedAccessors)
- (void)addCommands:(NSOrderedSet*)value_;
- (void)removeCommands:(NSOrderedSet*)value_;
- (void)addCommandsObject:(Command*)value_;
- (void)removeCommandsObject:(Command*)value_;
@end


@interface _MacroCommand (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableOrderedSet*)primitiveCommands;
- (void)setPrimitiveCommands:(NSMutableOrderedSet*)value;


@end
