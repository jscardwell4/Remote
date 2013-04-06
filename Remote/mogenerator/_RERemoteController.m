// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RERemoteController.m instead.

#import "_RERemoteController.h"


const struct RERemoteControllerAttributes RERemoteControllerAttributes = {
	.currentActivityKey = @"currentActivityKey",
	.currentRemoteKey = @"currentRemoteKey",
};



const struct RERemoteControllerRelationships RERemoteControllerRelationships = {
	.remoteElements = @"remoteElements",
	.switchToConfigCommands = @"switchToConfigCommands",
	.switchToRemoteCommands = @"switchToRemoteCommands",
	.topToolbar = @"topToolbar",
};






@implementation RERemoteControllerID
@end

@implementation _RERemoteController

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RERemoteController" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RERemoteController";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RERemoteController" inManagedObjectContext:moc_];
}

- (RERemoteControllerID*)objectID {
	return (RERemoteControllerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic currentActivityKey;






@dynamic currentRemoteKey;






@dynamic remoteElements;

	
- (NSMutableSet*)remoteElementsSet {
	[self willAccessValueForKey:@"remoteElements"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"remoteElements"];
  
	[self didAccessValueForKey:@"remoteElements"];
	return result;
}
	

@dynamic switchToConfigCommands;

	
- (NSMutableSet*)switchToConfigCommandsSet {
	[self willAccessValueForKey:@"switchToConfigCommands"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"switchToConfigCommands"];
  
	[self didAccessValueForKey:@"switchToConfigCommands"];
	return result;
}
	

@dynamic switchToRemoteCommands;

	
- (NSMutableSet*)switchToRemoteCommandsSet {
	[self willAccessValueForKey:@"switchToRemoteCommands"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"switchToRemoteCommands"];
  
	[self didAccessValueForKey:@"switchToRemoteCommands"];
	return result;
}
	

@dynamic topToolbar;

	






@end




