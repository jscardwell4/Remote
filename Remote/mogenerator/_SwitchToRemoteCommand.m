// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SwitchToRemoteCommand.m instead.

#import "_SwitchToRemoteCommand.h"


const struct SwitchToRemoteCommandAttributes SwitchToRemoteCommandAttributes = {
	.remoteKey = @"remoteKey",
};



const struct SwitchToRemoteCommandRelationships SwitchToRemoteCommandRelationships = {
	.remoteController = @"remoteController",
};






@implementation SwitchToRemoteCommandID
@end

@implementation _SwitchToRemoteCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SwitchToRemoteCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SwitchToRemoteCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SwitchToRemoteCommand" inManagedObjectContext:moc_];
}

- (SwitchToRemoteCommandID*)objectID {
	return (SwitchToRemoteCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic remoteKey;






@dynamic remoteController;

	






@end




