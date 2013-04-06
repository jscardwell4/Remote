// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankObject.m instead.

#import "_BankObject.h"


const struct BankObjectAttributes BankObjectAttributes = {
	.category = @"category",
	.exportFileFormat = @"exportFileFormat",
	.factoryObject = @"factoryObject",
	.name = @"name",
};








@implementation BankObjectID
@end

@implementation _BankObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BankObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BankObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BankObject" inManagedObjectContext:moc_];
}

- (BankObjectID*)objectID {
	return (BankObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"factoryObjectValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"factoryObject"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic category;






@dynamic exportFileFormat;






@dynamic factoryObject;



- (BOOL)factoryObjectValue {
	NSNumber *result = [self factoryObject];
	return [result boolValue];
}


- (void)setFactoryObjectValue:(BOOL)value_ {
	[self setFactoryObject:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveFactoryObjectValue {
	NSNumber *result = [self primitiveFactoryObject];
	return [result boolValue];
}

- (void)setPrimitiveFactoryObjectValue:(BOOL)value_ {
	[self setPrimitiveFactoryObject:[NSNumber numberWithBool:value_]];
}





@dynamic name;











@end




