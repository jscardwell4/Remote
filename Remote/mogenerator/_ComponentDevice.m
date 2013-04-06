// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ComponentDevice.m instead.

#import "_ComponentDevice.h"


const struct ComponentDeviceAttributes ComponentDeviceAttributes = {
	.alwaysOn = @"alwaysOn",
	.inputPowersOn = @"inputPowersOn",
	.port = @"port",
	.power = @"power",
};



const struct ComponentDeviceRelationships ComponentDeviceRelationships = {
	.codes = @"codes",
	.configurations = @"configurations",
	.offCommand = @"offCommand",
	.onCommand = @"onCommand",
	.powerCommands = @"powerCommands",
};





const struct ComponentDeviceUserInfo ComponentDeviceUserInfo = {
	.com.apple.syncservices.Syncable = @"NO",
};


@implementation ComponentDeviceID
@end

@implementation _ComponentDevice

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ComponentDevice" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ComponentDevice";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ComponentDevice" inManagedObjectContext:moc_];
}

- (ComponentDeviceID*)objectID {
	return (ComponentDeviceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"alwaysOnValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"alwaysOn"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"inputPowersOnValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"inputPowersOn"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"portValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"port"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"powerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"power"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic alwaysOn;



- (BOOL)alwaysOnValue {
	NSNumber *result = [self alwaysOn];
	return [result boolValue];
}


- (void)setAlwaysOnValue:(BOOL)value_ {
	[self setAlwaysOn:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveAlwaysOnValue {
	NSNumber *result = [self primitiveAlwaysOn];
	return [result boolValue];
}

- (void)setPrimitiveAlwaysOnValue:(BOOL)value_ {
	[self setPrimitiveAlwaysOn:[NSNumber numberWithBool:value_]];
}





@dynamic inputPowersOn;



- (BOOL)inputPowersOnValue {
	NSNumber *result = [self inputPowersOn];
	return [result boolValue];
}


- (void)setInputPowersOnValue:(BOOL)value_ {
	[self setInputPowersOn:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveInputPowersOnValue {
	NSNumber *result = [self primitiveInputPowersOn];
	return [result boolValue];
}

- (void)setPrimitiveInputPowersOnValue:(BOOL)value_ {
	[self setPrimitiveInputPowersOn:[NSNumber numberWithBool:value_]];
}





@dynamic port;



- (int16_t)portValue {
	NSNumber *result = [self port];
	return [result shortValue];
}


- (void)setPortValue:(int16_t)value_ {
	[self setPort:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitivePortValue {
	NSNumber *result = [self primitivePort];
	return [result shortValue];
}

- (void)setPrimitivePortValue:(int16_t)value_ {
	[self setPrimitivePort:[NSNumber numberWithShort:value_]];
}





@dynamic power;



- (int16_t)powerValue {
	NSNumber *result = [self power];
	return [result shortValue];
}


- (void)setPowerValue:(int16_t)value_ {
	[self setPower:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitivePowerValue {
	NSNumber *result = [self primitivePower];
	return [result shortValue];
}

- (void)setPrimitivePowerValue:(int16_t)value_ {
	[self setPrimitivePower:[NSNumber numberWithShort:value_]];
}





@dynamic codes;

	
- (NSMutableSet*)codesSet {
	[self willAccessValueForKey:@"codes"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"codes"];
  
	[self didAccessValueForKey:@"codes"];
	return result;
}
	

@dynamic configurations;

	
- (NSMutableSet*)configurationsSet {
	[self willAccessValueForKey:@"configurations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"configurations"];
  
	[self didAccessValueForKey:@"configurations"];
	return result;
}
	

@dynamic offCommand;

	

@dynamic onCommand;

	

@dynamic powerCommands;

	
- (NSMutableSet*)powerCommandsSet {
	[self willAccessValueForKey:@"powerCommands"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"powerCommands"];
  
	[self didAccessValueForKey:@"powerCommands"];
	return result;
}
	






@end




