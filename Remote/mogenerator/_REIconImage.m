// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REIconImage.m instead.

#import "_REIconImage.h"


const struct REIconImageAttributes REIconImageAttributes = {
	.iconSet = @"iconSet",
	.previewData = @"previewData",
	.subcategory = @"subcategory",
};








@implementation REIconImageID
@end

@implementation _REIconImage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REIconImage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REIconImage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REIconImage" inManagedObjectContext:moc_];
}

- (REIconImageID*)objectID {
	return (REIconImageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic iconSet;






@dynamic previewData;






@dynamic subcategory;











@end




