// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Command.m instead.

#import "_Command.h"


const struct CommandAttributes CommandAttributes = {
	.indicator = @"indicator",
	.tag = @"tag",
	.uuid = @"uuid",
};



const struct CommandRelationships CommandRelationships = {
	.button = @"button",
	.buttonDelegates = @"buttonDelegates",
	.commandSets = @"commandSets",
	.longPressButton = @"longPressButton",
	.macroCommands = @"macroCommands",
	.offDevice = @"offDevice",
	.onDevice = @"onDevice",
};





const struct CommandUserInfo CommandUserInfo = {
	.com.apple.syncservices.Syncable = @"NO",
};


@implementation CommandID
@end

@implementation _Command

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Command" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Command";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Command" inManagedObjectContext:moc_];
}

- (CommandID*)objectID {
	return (CommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"indicatorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"indicator"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic indicator;



- (BOOL)indicatorValue {
	NSNumber *result = [self indicator];
	return [result boolValue];
}


- (void)setIndicatorValue:(BOOL)value_ {
	[self setIndicator:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveIndicatorValue {
	NSNumber *result = [self primitiveIndicator];
	return [result boolValue];
}

- (void)setPrimitiveIndicatorValue:(BOOL)value_ {
	[self setPrimitiveIndicator:[NSNumber numberWithBool:value_]];
}





@dynamic tag;



- (int16_t)tagValue {
	NSNumber *result = [self tag];
	return [result shortValue];
}


- (void)setTagValue:(int16_t)value_ {
	[self setTag:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveTagValue {
	NSNumber *result = [self primitiveTag];
	return [result shortValue];
}

- (void)setPrimitiveTagValue:(int16_t)value_ {
	[self setPrimitiveTag:[NSNumber numberWithShort:value_]];
}





@dynamic uuid;






@dynamic button;

	

@dynamic buttonDelegates;

	
- (NSMutableSet*)buttonDelegatesSet {
	[self willAccessValueForKey:@"buttonDelegates"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"buttonDelegates"];
  
	[self didAccessValueForKey:@"buttonDelegates"];
	return result;
}
	

@dynamic commandSets;

	
- (NSMutableSet*)commandSetsSet {
	[self willAccessValueForKey:@"commandSets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"commandSets"];
  
	[self didAccessValueForKey:@"commandSets"];
	return result;
}
	

@dynamic longPressButton;

	

@dynamic macroCommands;

	
- (NSMutableSet*)macroCommandsSet {
	[self willAccessValueForKey:@"macroCommands"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"macroCommands"];
  
	[self didAccessValueForKey:@"macroCommands"];
	return result;
}
	

@dynamic offDevice;

	

@dynamic onDevice;

	






@end




