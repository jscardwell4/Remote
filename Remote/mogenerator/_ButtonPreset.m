// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ButtonPreset.m instead.

#import "_ButtonPreset.h"









@implementation ButtonPresetID
@end

@implementation _ButtonPreset

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ButtonPreset" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ButtonPreset";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ButtonPreset" inManagedObjectContext:moc_];
}

- (ButtonPresetID*)objectID {
	return (ButtonPresetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




