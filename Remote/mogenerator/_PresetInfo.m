// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PresetInfo.m instead.

#import "_PresetInfo.h"


const struct PresetInfoAttributes PresetInfoAttributes = {
	.presetName = @"presetName",
};



const struct PresetInfoRelationships PresetInfoRelationships = {
	.galleryGroup = @"galleryGroup",
};






@implementation PresetInfoID
@end

@implementation _PresetInfo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"PresetInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"PresetInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"PresetInfo" inManagedObjectContext:moc_];
}

- (PresetInfoID*)objectID {
	return (PresetInfoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic presetName;






@dynamic galleryGroup;

	






@end




