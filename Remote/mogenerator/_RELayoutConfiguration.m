// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RELayoutConfiguration.m instead.

#import "_RELayoutConfiguration.h"


const struct RELayoutConfigurationAttributes RELayoutConfigurationAttributes = {
	.bitVector = @"bitVector",
};



const struct RELayoutConfigurationRelationships RELayoutConfigurationRelationships = {
	.element = @"element",
};






@implementation RELayoutConfigurationID
@end

@implementation _RELayoutConfiguration

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RELayoutConfiguration" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RELayoutConfiguration";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RELayoutConfiguration" inManagedObjectContext:moc_];
}

- (RELayoutConfigurationID*)objectID {
	return (RELayoutConfigurationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic bitVector;






@dynamic element;

	






@end




