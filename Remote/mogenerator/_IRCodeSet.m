// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IRCodeSet.m instead.

#import "_IRCodeSet.h"




const struct IRCodeSetRelationships IRCodeSetRelationships = {
	.codes = @"codes",
	.manufacturer = @"manufacturer",
};






@implementation IRCodeSetID
@end

@implementation _IRCodeSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IRCodeSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IRCodeSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IRCodeSet" inManagedObjectContext:moc_];
}

- (IRCodeSetID*)objectID {
	return (IRCodeSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic codes;

	
- (NSMutableSet*)codesSet {
	[self willAccessValueForKey:@"codes"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"codes"];
  
	[self didAccessValueForKey:@"codes"];
	return result;
}
	

@dynamic manufacturer;

	






@end




