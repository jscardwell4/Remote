// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RemotePreset.m instead.

#import "_RemotePreset.h"









@implementation RemotePresetID
@end

@implementation _RemotePreset

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RemotePreset" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RemotePreset";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RemotePreset" inManagedObjectContext:moc_];
}

- (RemotePresetID*)objectID {
	return (RemotePresetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




