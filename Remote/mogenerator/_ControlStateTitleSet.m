// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateTitleSet.m instead.

#import "_ControlStateTitleSet.h"




const struct ControlStateTitleSetRelationships ControlStateTitleSetRelationships = {
	.button = @"button",
	.delegate = @"delegate",
};






@implementation ControlStateTitleSetID
@end

@implementation _ControlStateTitleSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateTitleSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ControlStateTitleSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ControlStateTitleSet" inManagedObjectContext:moc_];
}

- (ControlStateTitleSetID*)objectID {
	return (ControlStateTitleSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic button;

	

@dynamic delegate;

	






@end




