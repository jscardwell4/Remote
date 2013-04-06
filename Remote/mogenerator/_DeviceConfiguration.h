// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeviceConfiguration.h instead.

#import <CoreData/CoreData.h>



extern const struct DeviceConfigurationAttributes {
	 NSString *powerState;
} DeviceConfigurationAttributes;



extern const struct DeviceConfigurationRelationships {
	 NSString *activityButtons;
	 NSString *device;
	 NSString *input;
} DeviceConfigurationRelationships;






@class REActivityButton;
@class ComponentDevice;
@class IRCode;




@interface DeviceConfigurationID : NSManagedObjectID {}
@end

@interface _DeviceConfiguration : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DeviceConfigurationID*)objectID;





@property (nonatomic, retain) NSNumber* powerState;




@property (atomic) int16_t powerStateValue;
- (int16_t)powerStateValue;
- (void)setPowerStateValue:(int16_t)value_;


//- (BOOL)validatePowerState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *activityButtons;

- (NSMutableSet*)activityButtonsSet;




@property (nonatomic, retain) ComponentDevice *device;

//- (BOOL)validateDevice:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) IRCode *input;

//- (BOOL)validateInput:(id*)value_ error:(NSError**)error_;





@end


@interface _DeviceConfiguration (ActivityButtonsCoreDataGeneratedAccessors)
- (void)addActivityButtons:(NSSet*)value_;
- (void)removeActivityButtons:(NSSet*)value_;
- (void)addActivityButtonsObject:(REActivityButton*)value_;
- (void)removeActivityButtonsObject:(REActivityButton*)value_;
@end


@interface _DeviceConfiguration (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitivePowerState;
- (void)setPrimitivePowerState:(NSNumber*)value;

- (int16_t)primitivePowerStateValue;
- (void)setPrimitivePowerStateValue:(int16_t)value_;





- (NSMutableSet*)primitiveActivityButtons;
- (void)setPrimitiveActivityButtons:(NSMutableSet*)value;



- (ComponentDevice*)primitiveDevice;
- (void)setPrimitiveDevice:(ComponentDevice*)value;



- (IRCode*)primitiveInput;
- (void)setPrimitiveInput:(IRCode*)value;


@end
