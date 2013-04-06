// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PowerCommand.m instead.

#import "_PowerCommand.h"


const struct PowerCommandAttributes PowerCommandAttributes = {
	.state = @"state",
};



const struct PowerCommandRelationships PowerCommandRelationships = {
	.device = @"device",
};






@implementation PowerCommandID
@end

@implementation _PowerCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"PowerCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"PowerCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"PowerCommand" inManagedObjectContext:moc_];
}

- (PowerCommandID*)objectID {
	return (PowerCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"stateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"state"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic state;



- (BOOL)stateValue {
	NSNumber *result = [self state];
	return [result boolValue];
}


- (void)setStateValue:(BOOL)value_ {
	[self setState:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveStateValue {
	NSNumber *result = [self primitiveState];
	return [result boolValue];
}

- (void)setPrimitiveStateValue:(BOOL)value_ {
	[self setPrimitiveState:[NSNumber numberWithBool:value_]];
}





@dynamic device;

	






@end




