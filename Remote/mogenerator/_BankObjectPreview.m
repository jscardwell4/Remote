// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankObjectPreview.m instead.

#import "_BankObjectPreview.h"


const struct BankObjectPreviewAttributes BankObjectPreviewAttributes = {
	.imageData = @"imageData",
	.name = @"name",
	.tag = @"tag",
};








@implementation BankObjectPreviewID
@end

@implementation _BankObjectPreview

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BankObjectPreview" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BankObjectPreview";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BankObjectPreview" inManagedObjectContext:moc_];
}

- (BankObjectPreviewID*)objectID {
	return (BankObjectPreviewID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"tagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic imageData;






@dynamic name;






@dynamic tag;



- (int16_t)tagValue {
	NSNumber *result = [self tag];
	return [result shortValue];
}


- (void)setTagValue:(int16_t)value_ {
	[self setTag:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveTagValue {
	NSNumber *result = [self primitiveTag];
	return [result shortValue];
}

- (void)setPrimitiveTagValue:(int16_t)value_ {
	[self setPrimitiveTag:[NSNumber numberWithShort:value_]];
}










@end




