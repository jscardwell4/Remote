// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DeviceConfiguration.m instead.

#import "_DeviceConfiguration.h"


const struct DeviceConfigurationAttributes DeviceConfigurationAttributes = {
	.powerState = @"powerState",
};



const struct DeviceConfigurationRelationships DeviceConfigurationRelationships = {
	.activityButtons = @"activityButtons",
	.device = @"device",
	.input = @"input",
};






@implementation DeviceConfigurationID
@end

@implementation _DeviceConfiguration

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DeviceConfiguration" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DeviceConfiguration";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DeviceConfiguration" inManagedObjectContext:moc_];
}

- (DeviceConfigurationID*)objectID {
	return (DeviceConfigurationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"powerStateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"powerState"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic powerState;



- (int16_t)powerStateValue {
	NSNumber *result = [self powerState];
	return [result shortValue];
}


- (void)setPowerStateValue:(int16_t)value_ {
	[self setPowerState:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitivePowerStateValue {
	NSNumber *result = [self primitivePowerState];
	return [result shortValue];
}

- (void)setPrimitivePowerStateValue:(int16_t)value_ {
	[self setPrimitivePowerState:[NSNumber numberWithShort:value_]];
}





@dynamic activityButtons;

	
- (NSMutableSet*)activityButtonsSet {
	[self willAccessValueForKey:@"activityButtons"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"activityButtons"];
  
	[self didAccessValueForKey:@"activityButtons"];
	return result;
}
	

@dynamic device;

	

@dynamic input;

	






@end




