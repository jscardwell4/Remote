// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SwitchToConfigCommand.m instead.

#import "_SwitchToConfigCommand.h"


const struct SwitchToConfigCommandAttributes SwitchToConfigCommandAttributes = {
	.configuration = @"configuration",
};



const struct SwitchToConfigCommandRelationships SwitchToConfigCommandRelationships = {
	.remoteController = @"remoteController",
};






@implementation SwitchToConfigCommandID
@end

@implementation _SwitchToConfigCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SwitchToConfigCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SwitchToConfigCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SwitchToConfigCommand" inManagedObjectContext:moc_];
}

- (SwitchToConfigCommandID*)objectID {
	return (SwitchToConfigCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic configuration;






@dynamic remoteController;

	






@end




