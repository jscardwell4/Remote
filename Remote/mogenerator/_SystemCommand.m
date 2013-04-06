// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SystemCommand.m instead.

#import "_SystemCommand.h"


const struct SystemCommandAttributes SystemCommandAttributes = {
	.key = @"key",
};








@implementation SystemCommandID
@end

@implementation _SystemCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SystemCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SystemCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SystemCommand" inManagedObjectContext:moc_];
}

- (SystemCommandID*)objectID {
	return (SystemCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"keyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"key"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic key;



- (int16_t)keyValue {
	NSNumber *result = [self key];
	return [result shortValue];
}


- (void)setKeyValue:(int16_t)value_ {
	[self setKey:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveKeyValue {
	NSNumber *result = [self primitiveKey];
	return [result shortValue];
}

- (void)setPrimitiveKeyValue:(int16_t)value_ {
	[self setPrimitiveKey:[NSNumber numberWithShort:value_]];
}










@end




