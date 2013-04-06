// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Manufacturer.m instead.

#import "_Manufacturer.h"




const struct ManufacturerRelationships ManufacturerRelationships = {
	.codesets = @"codesets",
};






@implementation ManufacturerID
@end

@implementation _Manufacturer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Manufacturer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Manufacturer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Manufacturer" inManagedObjectContext:moc_];
}

- (ManufacturerID*)objectID {
	return (ManufacturerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic codesets;

	
- (NSMutableSet*)codesetsSet {
	[self willAccessValueForKey:@"codesets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"codesets"];
  
	[self didAccessValueForKey:@"codesets"];
	return result;
}
	






@end




