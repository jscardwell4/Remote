// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REActivityButton.m instead.

#import "_REActivityButton.h"




const struct REActivityButtonRelationships REActivityButtonRelationships = {
	.deviceConfigurations = @"deviceConfigurations",
};






@implementation REActivityButtonID
@end

@implementation _REActivityButton

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REActivityButton" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REActivityButton";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REActivityButton" inManagedObjectContext:moc_];
}

- (REActivityButtonID*)objectID {
	return (REActivityButtonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic deviceConfigurations;

	
- (NSMutableSet*)deviceConfigurationsSet {
	[self willAccessValueForKey:@"deviceConfigurations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"deviceConfigurations"];
  
	[self didAccessValueForKey:@"deviceConfigurations"];
	return result;
}
	






@end




