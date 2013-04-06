// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButtonGroupConfigurationDelegate.m instead.

#import "_REButtonGroupConfigurationDelegate.h"


const struct REButtonGroupConfigurationDelegateAttributes REButtonGroupConfigurationDelegateAttributes = {
	.labels = @"labels",
};



const struct REButtonGroupConfigurationDelegateRelationships REButtonGroupConfigurationDelegateRelationships = {
	.commandSets = @"commandSets",
};






@implementation REButtonGroupConfigurationDelegateID
@end

@implementation _REButtonGroupConfigurationDelegate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REButtonGroupConfigurationDelegate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REButtonGroupConfigurationDelegate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REButtonGroupConfigurationDelegate" inManagedObjectContext:moc_];
}

- (REButtonGroupConfigurationDelegateID*)objectID {
	return (REButtonGroupConfigurationDelegateID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic labels;






@dynamic commandSets;

	
- (NSMutableSet*)commandSetsSet {
	[self willAccessValueForKey:@"commandSets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"commandSets"];
  
	[self didAccessValueForKey:@"commandSets"];
	return result;
}
	






@end




