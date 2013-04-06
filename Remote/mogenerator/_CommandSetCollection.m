// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommandSetCollection.m instead.

#import "_CommandSetCollection.h"




const struct CommandSetCollectionRelationships CommandSetCollectionRelationships = {
	.commandSets = @"commandSets",
};






@implementation CommandSetCollectionID
@end

@implementation _CommandSetCollection

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CommandSetCollection" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CommandSetCollection";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CommandSetCollection" inManagedObjectContext:moc_];
}

- (CommandSetCollectionID*)objectID {
	return (CommandSetCollectionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic commandSets;

	
- (NSMutableSet*)commandSetsSet {
	[self willAccessValueForKey:@"commandSets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"commandSets"];
  
	[self didAccessValueForKey:@"commandSets"];
	return result;
}
	






@end




