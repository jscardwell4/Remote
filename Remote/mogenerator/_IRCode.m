// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IRCode.m instead.

#import "_IRCode.h"


const struct IRCodeAttributes IRCodeAttributes = {
	.alternateName = @"alternateName",
	.frequency = @"frequency",
	.offset = @"offset",
	.onOffPattern = @"onOffPattern",
	.prontoHex = @"prontoHex",
	.repeatCount = @"repeatCount",
	.setsDeviceInput = @"setsDeviceInput",
};



const struct IRCodeRelationships IRCodeRelationships = {
	.device = @"device",
	.deviceConfigurations = @"deviceConfigurations",
	.sendCommands = @"sendCommands",
};






@implementation IRCodeID
@end

@implementation _IRCode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IRCode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IRCode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IRCode" inManagedObjectContext:moc_];
}

- (IRCodeID*)objectID {
	return (IRCodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"frequencyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"frequency"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"offsetValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"offset"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"repeatCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"repeatCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"setsDeviceInputValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"setsDeviceInput"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic alternateName;






@dynamic frequency;



- (int64_t)frequencyValue {
	NSNumber *result = [self frequency];
	return [result longLongValue];
}


- (void)setFrequencyValue:(int64_t)value_ {
	[self setFrequency:[NSNumber numberWithLongLong:value_]];
}


- (int64_t)primitiveFrequencyValue {
	NSNumber *result = [self primitiveFrequency];
	return [result longLongValue];
}

- (void)setPrimitiveFrequencyValue:(int64_t)value_ {
	[self setPrimitiveFrequency:[NSNumber numberWithLongLong:value_]];
}





@dynamic offset;



- (int16_t)offsetValue {
	NSNumber *result = [self offset];
	return [result shortValue];
}


- (void)setOffsetValue:(int16_t)value_ {
	[self setOffset:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveOffsetValue {
	NSNumber *result = [self primitiveOffset];
	return [result shortValue];
}

- (void)setPrimitiveOffsetValue:(int16_t)value_ {
	[self setPrimitiveOffset:[NSNumber numberWithShort:value_]];
}





@dynamic onOffPattern;






@dynamic prontoHex;






@dynamic repeatCount;



- (int16_t)repeatCountValue {
	NSNumber *result = [self repeatCount];
	return [result shortValue];
}


- (void)setRepeatCountValue:(int16_t)value_ {
	[self setRepeatCount:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveRepeatCountValue {
	NSNumber *result = [self primitiveRepeatCount];
	return [result shortValue];
}

- (void)setPrimitiveRepeatCountValue:(int16_t)value_ {
	[self setPrimitiveRepeatCount:[NSNumber numberWithShort:value_]];
}





@dynamic setsDeviceInput;



- (BOOL)setsDeviceInputValue {
	NSNumber *result = [self setsDeviceInput];
	return [result boolValue];
}


- (void)setSetsDeviceInputValue:(BOOL)value_ {
	[self setSetsDeviceInput:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveSetsDeviceInputValue {
	NSNumber *result = [self primitiveSetsDeviceInput];
	return [result boolValue];
}

- (void)setPrimitiveSetsDeviceInputValue:(BOOL)value_ {
	[self setPrimitiveSetsDeviceInput:[NSNumber numberWithBool:value_]];
}





@dynamic device;

	

@dynamic deviceConfigurations;

	
- (NSMutableSet*)deviceConfigurationsSet {
	[self willAccessValueForKey:@"deviceConfigurations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"deviceConfigurations"];
  
	[self didAccessValueForKey:@"deviceConfigurations"];
	return result;
}
	

@dynamic sendCommands;

	
- (NSMutableSet*)sendCommandsSet {
	[self willAccessValueForKey:@"sendCommands"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sendCommands"];
  
	[self didAccessValueForKey:@"sendCommands"];
	return result;
}
	






@end




