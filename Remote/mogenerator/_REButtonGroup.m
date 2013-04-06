// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButtonGroup.m instead.

#import "_REButtonGroup.h"


const struct REButtonGroupAttributes REButtonGroupAttributes = {
	.label = @"label",
	.labelConstraints = @"labelConstraints",
};



const struct REButtonGroupRelationships REButtonGroupRelationships = {
	.commandSet = @"commandSet",
	.topToolbarForController = @"topToolbarForController",
};






@implementation REButtonGroupID
@end

@implementation _REButtonGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REButtonGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REButtonGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REButtonGroup" inManagedObjectContext:moc_];
}

- (REButtonGroupID*)objectID {
	return (REButtonGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic label;






@dynamic labelConstraints;






@dynamic commandSet;

	

@dynamic topToolbarForController;

	






@end




