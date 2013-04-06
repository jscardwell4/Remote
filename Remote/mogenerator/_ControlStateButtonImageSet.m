// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateButtonImageSet.m instead.

#import "_ControlStateButtonImageSet.h"




const struct ControlStateButtonImageSetRelationships ControlStateButtonImageSetRelationships = {
	.button = @"button",
};






@implementation ControlStateButtonImageSetID
@end

@implementation _ControlStateButtonImageSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateButtonImageSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ControlStateButtonImageSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ControlStateButtonImageSet" inManagedObjectContext:moc_];
}

- (ControlStateButtonImageSetID*)objectID {
	return (ControlStateButtonImageSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic button;

	






@end




