// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ITachDevice.m instead.

#import "_ITachDevice.h"


const struct ITachDeviceAttributes ITachDeviceAttributes = {
	.configURL = @"configURL",
	.make = @"make",
	.model = @"model",
	.pcb_pn = @"pcb_pn",
	.pkg_level = @"pkg_level",
	.revision = @"revision",
	.sdkClass = @"sdkClass",
	.status = @"status",
};








@implementation ITachDeviceID
@end

@implementation _ITachDevice

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ITachDevice" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ITachDevice";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ITachDevice" inManagedObjectContext:moc_];
}

- (ITachDeviceID*)objectID {
	return (ITachDeviceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic configURL;






@dynamic make;






@dynamic model;






@dynamic pcb_pn;






@dynamic pkg_level;






@dynamic revision;






@dynamic sdkClass;






@dynamic status;











+ (NSArray*)fetchAlliTachDevices:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *result = [self fetchAlliTachDevices:moc_ error:&error];
	if (error) {
#ifdef NSAppKitVersionNumber10_0
		[NSApp presentError:error];
#else
		NSLog(@"error: %@", error);
#endif
	}
	return result;
}
+ (NSArray*)fetchAlliTachDevices:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;

	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionary];
	
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"AlliTachDevices"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"AlliTachDevices\".");

	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



@end




