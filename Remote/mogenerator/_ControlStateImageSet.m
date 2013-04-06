// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateImageSet.m instead.

#import "_ControlStateImageSet.h"









@implementation ControlStateImageSetID
@end

@implementation _ControlStateImageSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateImageSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ControlStateImageSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ControlStateImageSet" inManagedObjectContext:moc_];
}

- (ControlStateImageSetID*)objectID {
	return (ControlStateImageSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




