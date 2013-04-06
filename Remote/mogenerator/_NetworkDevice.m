// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NetworkDevice.m instead.

#import "_NetworkDevice.h"


const struct NetworkDeviceAttributes NetworkDeviceAttributes = {
	.uuid = @"uuid",
};








@implementation NetworkDeviceID
@end

@implementation _NetworkDevice

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"NetworkDevice" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"NetworkDevice";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"NetworkDevice" inManagedObjectContext:moc_];
}

- (NetworkDeviceID*)objectID {
	return (NetworkDeviceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic uuid;











@end




