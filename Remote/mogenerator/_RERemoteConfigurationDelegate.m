// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RERemoteConfigurationDelegate.m instead.

#import "_RERemoteConfigurationDelegate.h"









@implementation RERemoteConfigurationDelegateID
@end

@implementation _RERemoteConfigurationDelegate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RERemoteConfigurationDelegate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RERemoteConfigurationDelegate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RERemoteConfigurationDelegate" inManagedObjectContext:moc_];
}

- (RERemoteConfigurationDelegateID*)objectID {
	return (RERemoteConfigurationDelegateID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




