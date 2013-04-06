// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommandSetCollection.h instead.

#import <CoreData/CoreData.h>
#import "CommandContainer.h"





extern const struct CommandSetCollectionRelationships {
	 NSString *commandSets;
} CommandSetCollectionRelationships;






@class CommandSet;


@interface CommandSetCollectionID : CommandContainerID {}
@end

@interface _CommandSetCollection : CommandContainer {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommandSetCollectionID*)objectID;





@property (nonatomic, retain) NSSet *commandSets;

- (NSMutableSet*)commandSetsSet;





@end


@interface _CommandSetCollection (CommandSetsCoreDataGeneratedAccessors)
- (void)addCommandSets:(NSSet*)value_;
- (void)removeCommandSets:(NSSet*)value_;
- (void)addCommandSetsObject:(CommandSet*)value_;
- (void)removeCommandSetsObject:(CommandSet*)value_;
@end


@interface _CommandSetCollection (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveCommandSets;
- (void)setPrimitiveCommandSets:(NSMutableSet*)value;


@end
