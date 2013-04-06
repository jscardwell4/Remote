// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankPreset.m instead.

#import "_BankPreset.h"


const struct BankPresetAttributes BankPresetAttributes = {
	.previewData = @"previewData",
};








@implementation BankPresetID
@end

@implementation _BankPreset

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BankPreset" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BankPreset";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BankPreset" inManagedObjectContext:moc_];
}

- (BankPresetID*)objectID {
	return (BankPresetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic previewData;











@end




