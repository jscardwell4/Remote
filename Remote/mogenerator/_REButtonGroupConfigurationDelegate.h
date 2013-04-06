// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButtonGroupConfigurationDelegate.h instead.

#import <CoreData/CoreData.h>
#import "REConfigurationDelegate.h"



extern const struct REButtonGroupConfigurationDelegateAttributes {
	 NSString *labels;
} REButtonGroupConfigurationDelegateAttributes;



extern const struct REButtonGroupConfigurationDelegateRelationships {
	 NSString *commandSets;
} REButtonGroupConfigurationDelegateRelationships;






@class CommandSet;



@class NSObject;

@interface REButtonGroupConfigurationDelegateID : REConfigurationDelegateID {}
@end

@interface _REButtonGroupConfigurationDelegate : REConfigurationDelegate {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REButtonGroupConfigurationDelegateID*)objectID;





@property (nonatomic, retain) id labels;



//- (BOOL)validateLabels:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *commandSets;

- (NSMutableSet*)commandSetsSet;





@end


@interface _REButtonGroupConfigurationDelegate (CommandSetsCoreDataGeneratedAccessors)
- (void)addCommandSets:(NSSet*)value_;
- (void)removeCommandSets:(NSSet*)value_;
- (void)addCommandSetsObject:(CommandSet*)value_;
- (void)removeCommandSetsObject:(CommandSet*)value_;
@end


@interface _REButtonGroupConfigurationDelegate (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveLabels;
- (void)setPrimitiveLabels:(id)value;





- (NSMutableSet*)primitiveCommandSets;
- (void)setPrimitiveCommandSets:(NSMutableSet*)value;


@end
