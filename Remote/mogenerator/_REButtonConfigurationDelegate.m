// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButtonConfigurationDelegate.m instead.

#import "_REButtonConfigurationDelegate.h"




const struct REButtonConfigurationDelegateRelationships REButtonConfigurationDelegateRelationships = {
	.commands = @"commands",
	.titleSets = @"titleSets",
};






@implementation REButtonConfigurationDelegateID
@end

@implementation _REButtonConfigurationDelegate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REButtonConfigurationDelegate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REButtonConfigurationDelegate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REButtonConfigurationDelegate" inManagedObjectContext:moc_];
}

- (REButtonConfigurationDelegateID*)objectID {
	return (REButtonConfigurationDelegateID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic commands;

	
- (NSMutableSet*)commandsSet {
	[self willAccessValueForKey:@"commands"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"commands"];
  
	[self didAccessValueForKey:@"commands"];
	return result;
}
	

@dynamic titleSets;

	
- (NSMutableSet*)titleSetsSet {
	[self willAccessValueForKey:@"titleSets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"titleSets"];
  
	[self didAccessValueForKey:@"titleSets"];
	return result;
}
	






@end




