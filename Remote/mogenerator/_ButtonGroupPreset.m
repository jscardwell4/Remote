// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ButtonGroupPreset.m instead.

#import "_ButtonGroupPreset.h"









@implementation ButtonGroupPresetID
@end

@implementation _ButtonGroupPreset

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ButtonGroupPreset" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ButtonGroupPreset";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ButtonGroupPreset" inManagedObjectContext:moc_];
}

- (ButtonGroupPresetID*)objectID {
	return (ButtonGroupPresetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




