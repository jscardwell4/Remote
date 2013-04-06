// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankObjectGroup.m instead.

#import "_BankObjectGroup.h"


const struct BankObjectGroupAttributes BankObjectGroupAttributes = {
	.name = @"name",
};



const struct BankObjectGroupRelationships BankObjectGroupRelationships = {
	.images = @"images",
	.presets = @"presets",
};






@implementation BankObjectGroupID
@end

@implementation _BankObjectGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BankObjectGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BankObjectGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BankObjectGroup" inManagedObjectContext:moc_];
}

- (BankObjectGroupID*)objectID {
	return (BankObjectGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic images;

	
- (NSMutableSet*)imagesSet {
	[self willAccessValueForKey:@"images"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"images"];
  
	[self didAccessValueForKey:@"images"];
	return result;
}
	

@dynamic presets;

	
- (NSMutableSet*)presetsSet {
	[self willAccessValueForKey:@"presets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"presets"];
  
	[self didAccessValueForKey:@"presets"];
	return result;
}
	






@end




