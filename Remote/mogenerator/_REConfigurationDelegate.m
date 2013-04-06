// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REConfigurationDelegate.m instead.

#import "_REConfigurationDelegate.h"


const struct REConfigurationDelegateAttributes REConfigurationDelegateAttributes = {
	.configurations = @"configurations",
};



const struct REConfigurationDelegateRelationships REConfigurationDelegateRelationships = {
	.delegate = @"delegate",
	.remoteElement = @"remoteElement",
	.subscribers = @"subscribers",
};






@implementation REConfigurationDelegateID
@end

@implementation _REConfigurationDelegate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REConfigurationDelegate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REConfigurationDelegate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REConfigurationDelegate" inManagedObjectContext:moc_];
}

- (REConfigurationDelegateID*)objectID {
	return (REConfigurationDelegateID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic configurations;






@dynamic delegate;

	

@dynamic remoteElement;

	

@dynamic subscribers;

	
- (NSMutableSet*)subscribersSet {
	[self willAccessValueForKey:@"subscribers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subscribers"];
  
	[self didAccessValueForKey:@"subscribers"];
	return result;
}
	






@end




