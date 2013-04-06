// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SendIRCommand.m instead.

#import "_SendIRCommand.h"


const struct SendIRCommandAttributes SendIRCommandAttributes = {
	.portOverride = @"portOverride",
};



const struct SendIRCommandRelationships SendIRCommandRelationships = {
	.code = @"code",
};






@implementation SendIRCommandID
@end

@implementation _SendIRCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SendIRCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SendIRCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SendIRCommand" inManagedObjectContext:moc_];
}

- (SendIRCommandID*)objectID {
	return (SendIRCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"portOverrideValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"portOverride"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic portOverride;



- (int16_t)portOverrideValue {
	NSNumber *result = [self portOverride];
	return [result shortValue];
}


- (void)setPortOverrideValue:(int16_t)value_ {
	[self setPortOverride:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitivePortOverrideValue {
	NSNumber *result = [self primitivePortOverride];
	return [result shortValue];
}

- (void)setPrimitivePortOverrideValue:(int16_t)value_ {
	[self setPrimitivePortOverride:[NSNumber numberWithShort:value_]];
}





@dynamic code;

	






@end




