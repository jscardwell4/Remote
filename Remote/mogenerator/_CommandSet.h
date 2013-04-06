// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommandSet.h instead.

#import <CoreData/CoreData.h>
#import "CommandContainer.h"



extern const struct CommandSetAttributes {
	 NSString *name;
	 NSString *type;
} CommandSetAttributes;



extern const struct CommandSetRelationships {
	 NSString *buttonGroup;
	 NSString *commandSetCollections;
	 NSString *commands;
	 NSString *delegates;
} CommandSetRelationships;






@class REButtonGroup;
@class CommandSetCollection;
@class Command;
@class REButtonGroupConfigurationDelegate;






@interface CommandSetID : CommandContainerID {}
@end

@interface _CommandSet : CommandContainer {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommandSetID*)objectID;





@property (nonatomic, retain) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* type;




@property (atomic) int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;


//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) REButtonGroup *buttonGroup;

//- (BOOL)validateButtonGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *commandSetCollections;

- (NSMutableSet*)commandSetCollectionsSet;




@property (nonatomic, retain) NSSet *commands;

- (NSMutableSet*)commandsSet;




@property (nonatomic, retain) NSSet *delegates;

- (NSMutableSet*)delegatesSet;





@end


@interface _CommandSet (CommandSetCollectionsCoreDataGeneratedAccessors)
- (void)addCommandSetCollections:(NSSet*)value_;
- (void)removeCommandSetCollections:(NSSet*)value_;
- (void)addCommandSetCollectionsObject:(CommandSetCollection*)value_;
- (void)removeCommandSetCollectionsObject:(CommandSetCollection*)value_;
@end

@interface _CommandSet (CommandsCoreDataGeneratedAccessors)
- (void)addCommands:(NSSet*)value_;
- (void)removeCommands:(NSSet*)value_;
- (void)addCommandsObject:(Command*)value_;
- (void)removeCommandsObject:(Command*)value_;
@end

@interface _CommandSet (DelegatesCoreDataGeneratedAccessors)
- (void)addDelegates:(NSSet*)value_;
- (void)removeDelegates:(NSSet*)value_;
- (void)addDelegatesObject:(REButtonGroupConfigurationDelegate*)value_;
- (void)removeDelegatesObject:(REButtonGroupConfigurationDelegate*)value_;
@end


@interface _CommandSet (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (REButtonGroup*)primitiveButtonGroup;
- (void)setPrimitiveButtonGroup:(REButtonGroup*)value;



- (NSMutableSet*)primitiveCommandSetCollections;
- (void)setPrimitiveCommandSetCollections:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCommands;
- (void)setPrimitiveCommands:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDelegates;
- (void)setPrimitiveDelegates:(NSMutableSet*)value;


@end
