// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButtonConfigurationDelegate.h instead.

#import <CoreData/CoreData.h>
#import "REConfigurationDelegate.h"





extern const struct REButtonConfigurationDelegateRelationships {
	 NSString *commands;
	 NSString *titleSets;
} REButtonConfigurationDelegateRelationships;






@class Command;
@class ControlStateTitleSet;


@interface REButtonConfigurationDelegateID : REConfigurationDelegateID {}
@end

@interface _REButtonConfigurationDelegate : REConfigurationDelegate {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REButtonConfigurationDelegateID*)objectID;





@property (nonatomic, retain) NSSet *commands;

- (NSMutableSet*)commandsSet;




@property (nonatomic, retain) NSSet *titleSets;

- (NSMutableSet*)titleSetsSet;





@end


@interface _REButtonConfigurationDelegate (CommandsCoreDataGeneratedAccessors)
- (void)addCommands:(NSSet*)value_;
- (void)removeCommands:(NSSet*)value_;
- (void)addCommandsObject:(Command*)value_;
- (void)removeCommandsObject:(Command*)value_;
@end

@interface _REButtonConfigurationDelegate (TitleSetsCoreDataGeneratedAccessors)
- (void)addTitleSets:(NSSet*)value_;
- (void)removeTitleSets:(NSSet*)value_;
- (void)addTitleSetsObject:(ControlStateTitleSet*)value_;
- (void)removeTitleSetsObject:(ControlStateTitleSet*)value_;
@end


@interface _REButtonConfigurationDelegate (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveCommands;
- (void)setPrimitiveCommands:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTitleSets;
- (void)setPrimitiveTitleSets:(NSMutableSet*)value;


@end
