// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REActivityButton.h instead.

#import <CoreData/CoreData.h>
#import "REButton.h"





extern const struct REActivityButtonRelationships {
	 NSString *deviceConfigurations;
} REActivityButtonRelationships;






@class DeviceConfiguration;


@interface REActivityButtonID : REButtonID {}
@end

@interface _REActivityButton : REButton {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REActivityButtonID*)objectID;





@property (nonatomic, retain) NSSet *deviceConfigurations;

- (NSMutableSet*)deviceConfigurationsSet;





@end


@interface _REActivityButton (DeviceConfigurationsCoreDataGeneratedAccessors)
- (void)addDeviceConfigurations:(NSSet*)value_;
- (void)removeDeviceConfigurations:(NSSet*)value_;
- (void)addDeviceConfigurationsObject:(DeviceConfiguration*)value_;
- (void)removeDeviceConfigurationsObject:(DeviceConfiguration*)value_;
@end


@interface _REActivityButton (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveDeviceConfigurations;
- (void)setPrimitiveDeviceConfigurations:(NSMutableSet*)value;


@end
