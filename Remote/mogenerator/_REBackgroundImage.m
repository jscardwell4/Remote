// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REBackgroundImage.m instead.

#import "_REBackgroundImage.h"









@implementation REBackgroundImageID
@end

@implementation _REBackgroundImage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REBackgroundImage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REBackgroundImage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REBackgroundImage" inManagedObjectContext:moc_];
}

- (REBackgroundImageID*)objectID {
	return (REBackgroundImageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




