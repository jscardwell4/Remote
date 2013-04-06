// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankObjectButtonPreview.m instead.

#import "_BankObjectButtonPreview.h"









@implementation BankObjectButtonPreviewID
@end

@implementation _BankObjectButtonPreview

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BankObjectButtonPreview" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BankObjectButtonPreview";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BankObjectButtonPreview" inManagedObjectContext:moc_];
}

- (BankObjectButtonPreviewID*)objectID {
	return (BankObjectButtonPreviewID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end




