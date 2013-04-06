// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to UserIRCode.m instead.

#import "_UserIRCode.h"









@implementation UserIRCodeID
@end

@implementation _UserIRCode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"UserIRCode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"UserIRCode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"UserIRCode" inManagedObjectContext:moc_];
}

- (UserIRCodeID*)objectID {
	return (UserIRCodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




