// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IRCode.h instead.

#import <CoreData/CoreData.h>
#import "BankObject.h"



extern const struct IRCodeAttributes {
	 NSString *alternateName;
	 NSString *frequency;
	 NSString *offset;
	 NSString *onOffPattern;
	 NSString *prontoHex;
	 NSString *repeatCount;
	 NSString *setsDeviceInput;
} IRCodeAttributes;



extern const struct IRCodeRelationships {
	 NSString *device;
	 NSString *deviceConfigurations;
	 NSString *sendCommands;
} IRCodeRelationships;






@class ComponentDevice;
@class DeviceConfiguration;
@class SendIRCommand;
















@interface IRCodeID : BankObjectID {}
@end

@interface _IRCode : BankObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IRCodeID*)objectID;





@property (nonatomic, retain) NSString* alternateName;



//- (BOOL)validateAlternateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* frequency;




@property (atomic) int64_t frequencyValue;
- (int64_t)frequencyValue;
- (void)setFrequencyValue:(int64_t)value_;


//- (BOOL)validateFrequency:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* offset;




@property (atomic) int16_t offsetValue;
- (int16_t)offsetValue;
- (void)setOffsetValue:(int16_t)value_;


//- (BOOL)validateOffset:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* onOffPattern;



//- (BOOL)validateOnOffPattern:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* prontoHex;



//- (BOOL)validateProntoHex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* repeatCount;




@property (atomic) int16_t repeatCountValue;
- (int16_t)repeatCountValue;
- (void)setRepeatCountValue:(int16_t)value_;


//- (BOOL)validateRepeatCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* setsDeviceInput;




@property (atomic) BOOL setsDeviceInputValue;
- (BOOL)setsDeviceInputValue;
- (void)setSetsDeviceInputValue:(BOOL)value_;


//- (BOOL)validateSetsDeviceInput:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) ComponentDevice *device;

//- (BOOL)validateDevice:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *deviceConfigurations;

- (NSMutableSet*)deviceConfigurationsSet;




@property (nonatomic, retain) NSSet *sendCommands;

- (NSMutableSet*)sendCommandsSet;





@end


@interface _IRCode (DeviceConfigurationsCoreDataGeneratedAccessors)
- (void)addDeviceConfigurations:(NSSet*)value_;
- (void)removeDeviceConfigurations:(NSSet*)value_;
- (void)addDeviceConfigurationsObject:(DeviceConfiguration*)value_;
- (void)removeDeviceConfigurationsObject:(DeviceConfiguration*)value_;
@end

@interface _IRCode (SendCommandsCoreDataGeneratedAccessors)
- (void)addSendCommands:(NSSet*)value_;
- (void)removeSendCommands:(NSSet*)value_;
- (void)addSendCommandsObject:(SendIRCommand*)value_;
- (void)removeSendCommandsObject:(SendIRCommand*)value_;
@end


@interface _IRCode (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAlternateName;
- (void)setPrimitiveAlternateName:(NSString*)value;




- (NSNumber*)primitiveFrequency;
- (void)setPrimitiveFrequency:(NSNumber*)value;

- (int64_t)primitiveFrequencyValue;
- (void)setPrimitiveFrequencyValue:(int64_t)value_;




- (NSNumber*)primitiveOffset;
- (void)setPrimitiveOffset:(NSNumber*)value;

- (int16_t)primitiveOffsetValue;
- (void)setPrimitiveOffsetValue:(int16_t)value_;




- (NSString*)primitiveOnOffPattern;
- (void)setPrimitiveOnOffPattern:(NSString*)value;




- (NSString*)primitiveProntoHex;
- (void)setPrimitiveProntoHex:(NSString*)value;




- (NSNumber*)primitiveRepeatCount;
- (void)setPrimitiveRepeatCount:(NSNumber*)value;

- (int16_t)primitiveRepeatCountValue;
- (void)setPrimitiveRepeatCountValue:(int16_t)value_;




- (NSNumber*)primitiveSetsDeviceInput;
- (void)setPrimitiveSetsDeviceInput:(NSNumber*)value;

- (BOOL)primitiveSetsDeviceInputValue;
- (void)setPrimitiveSetsDeviceInputValue:(BOOL)value_;





- (ComponentDevice*)primitiveDevice;
- (void)setPrimitiveDevice:(ComponentDevice*)value;



- (NSMutableSet*)primitiveDeviceConfigurations;
- (void)setPrimitiveDeviceConfigurations:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSendCommands;
- (void)setPrimitiveSendCommands:(NSMutableSet*)value;


@end
