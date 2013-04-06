// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ComponentDevice.h instead.

#import <CoreData/CoreData.h>
#import "BankObject.h"



extern const struct ComponentDeviceAttributes {
	 NSString *alwaysOn;
	 NSString *inputPowersOn;
	 NSString *port;
	 NSString *power;
} ComponentDeviceAttributes;



extern const struct ComponentDeviceRelationships {
	 NSString *codes;
	 NSString *configurations;
	 NSString *offCommand;
	 NSString *onCommand;
	 NSString *powerCommands;
} ComponentDeviceRelationships;





extern const struct ComponentDeviceUserInfo {
	 NSString *com.apple.syncservices.Syncable;
} ComponentDeviceUserInfo;


@class IRCode;
@class DeviceConfiguration;
@class Command;
@class Command;
@class PowerCommand;










@interface ComponentDeviceID : BankObjectID {}
@end

@interface _ComponentDevice : BankObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ComponentDeviceID*)objectID;





@property (nonatomic, retain) NSNumber* alwaysOn;




@property (atomic) BOOL alwaysOnValue;
- (BOOL)alwaysOnValue;
- (void)setAlwaysOnValue:(BOOL)value_;


//- (BOOL)validateAlwaysOn:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* inputPowersOn;




@property (atomic) BOOL inputPowersOnValue;
- (BOOL)inputPowersOnValue;
- (void)setInputPowersOnValue:(BOOL)value_;


//- (BOOL)validateInputPowersOn:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* port;




@property (atomic) int16_t portValue;
- (int16_t)portValue;
- (void)setPortValue:(int16_t)value_;


//- (BOOL)validatePort:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* power;




@property (atomic) int16_t powerValue;
- (int16_t)powerValue;
- (void)setPowerValue:(int16_t)value_;


//- (BOOL)validatePower:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *codes;

- (NSMutableSet*)codesSet;




@property (nonatomic, retain) NSSet *configurations;

- (NSMutableSet*)configurationsSet;




@property (nonatomic, retain) Command *offCommand;

//- (BOOL)validateOffCommand:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Command *onCommand;

//- (BOOL)validateOnCommand:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *powerCommands;

- (NSMutableSet*)powerCommandsSet;





@end


@interface _ComponentDevice (CodesCoreDataGeneratedAccessors)
- (void)addCodes:(NSSet*)value_;
- (void)removeCodes:(NSSet*)value_;
- (void)addCodesObject:(IRCode*)value_;
- (void)removeCodesObject:(IRCode*)value_;
@end

@interface _ComponentDevice (ConfigurationsCoreDataGeneratedAccessors)
- (void)addConfigurations:(NSSet*)value_;
- (void)removeConfigurations:(NSSet*)value_;
- (void)addConfigurationsObject:(DeviceConfiguration*)value_;
- (void)removeConfigurationsObject:(DeviceConfiguration*)value_;
@end

@interface _ComponentDevice (PowerCommandsCoreDataGeneratedAccessors)
- (void)addPowerCommands:(NSSet*)value_;
- (void)removePowerCommands:(NSSet*)value_;
- (void)addPowerCommandsObject:(PowerCommand*)value_;
- (void)removePowerCommandsObject:(PowerCommand*)value_;
@end


@interface _ComponentDevice (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAlwaysOn;
- (void)setPrimitiveAlwaysOn:(NSNumber*)value;

- (BOOL)primitiveAlwaysOnValue;
- (void)setPrimitiveAlwaysOnValue:(BOOL)value_;




- (NSNumber*)primitiveInputPowersOn;
- (void)setPrimitiveInputPowersOn:(NSNumber*)value;

- (BOOL)primitiveInputPowersOnValue;
- (void)setPrimitiveInputPowersOnValue:(BOOL)value_;




- (NSNumber*)primitivePort;
- (void)setPrimitivePort:(NSNumber*)value;

- (int16_t)primitivePortValue;
- (void)setPrimitivePortValue:(int16_t)value_;




- (NSNumber*)primitivePower;
- (void)setPrimitivePower:(NSNumber*)value;

- (int16_t)primitivePowerValue;
- (void)setPrimitivePowerValue:(int16_t)value_;





- (NSMutableSet*)primitiveCodes;
- (void)setPrimitiveCodes:(NSMutableSet*)value;



- (NSMutableSet*)primitiveConfigurations;
- (void)setPrimitiveConfigurations:(NSMutableSet*)value;



- (Command*)primitiveOffCommand;
- (void)setPrimitiveOffCommand:(Command*)value;



- (Command*)primitiveOnCommand;
- (void)setPrimitiveOnCommand:(Command*)value;



- (NSMutableSet*)primitivePowerCommands;
- (void)setPrimitivePowerCommands:(NSMutableSet*)value;


@end
