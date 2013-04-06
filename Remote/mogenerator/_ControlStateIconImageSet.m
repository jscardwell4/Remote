// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateIconImageSet.m instead.

#import "_ControlStateIconImageSet.h"


const struct ControlStateIconImageSetAttributes ControlStateIconImageSetAttributes = {
	.styledIconStates = @"styledIconStates",
};



const struct ControlStateIconImageSetRelationships ControlStateIconImageSetRelationships = {
	.button = @"button",
	.iconColors = @"iconColors",
};






@implementation ControlStateIconImageSetID
@end

@implementation _ControlStateIconImageSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateIconImageSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ControlStateIconImageSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ControlStateIconImageSet" inManagedObjectContext:moc_];
}

- (ControlStateIconImageSetID*)objectID {
	return (ControlStateIconImageSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"styledIconStatesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"styledIconStates"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic styledIconStates;



- (int16_t)styledIconStatesValue {
	NSNumber *result = [self styledIconStates];
	return [result shortValue];
}


- (void)setStyledIconStatesValue:(int16_t)value_ {
	[self setStyledIconStates:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveStyledIconStatesValue {
	NSNumber *result = [self primitiveStyledIconStates];
	return [result shortValue];
}

- (void)setPrimitiveStyledIconStatesValue:(int16_t)value_ {
	[self setPrimitiveStyledIconStates:[NSNumber numberWithShort:value_]];
}





@dynamic button;

	

@dynamic iconColors;

	






@end




