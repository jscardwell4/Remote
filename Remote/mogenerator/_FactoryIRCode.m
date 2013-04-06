// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FactoryIRCode.m instead.

#import "_FactoryIRCode.h"




const struct FactoryIRCodeRelationships FactoryIRCodeRelationships = {
	.codeSet = @"codeSet",
};






@implementation FactoryIRCodeID
@end

@implementation _FactoryIRCode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FactoryIRCode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FactoryIRCode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FactoryIRCode" inManagedObjectContext:moc_];
}

- (FactoryIRCodeID*)objectID {
	return (FactoryIRCodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic codeSet;

	






@end




