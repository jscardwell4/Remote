// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateColorSet.m instead.

#import "_ControlStateColorSet.h"


const struct ControlStateColorSetAttributes ControlStateColorSetAttributes = {
	.colorSetType = @"colorSetType",
	.disabledAndSelectedPatternImage = @"disabledAndSelectedPatternImage",
	.disabledPatternImage = @"disabledPatternImage",
	.highlightedAndDisabledPatternImage = @"highlightedAndDisabledPatternImage",
	.highlightedAndSelectedPatternImage = @"highlightedAndSelectedPatternImage",
	.highlightedPatternImage = @"highlightedPatternImage",
	.normalPatternImage = @"normalPatternImage",
	.patternColorStates = @"patternColorStates",
	.selectedHighlightedAndDisabledPatternImage = @"selectedHighlightedAndDisabledPatternImage",
	.selectedPatternImage = @"selectedPatternImage",
};



const struct ControlStateColorSetRelationships ControlStateColorSetRelationships = {
	.button = @"button",
	.icons = @"icons",
};






@implementation ControlStateColorSetID
@end

@implementation _ControlStateColorSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateColorSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ControlStateColorSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ControlStateColorSet" inManagedObjectContext:moc_];
}

- (ControlStateColorSetID*)objectID {
	return (ControlStateColorSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"colorSetTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"colorSetType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"patternColorStatesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"patternColorStates"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic colorSetType;



- (int16_t)colorSetTypeValue {
	NSNumber *result = [self colorSetType];
	return [result shortValue];
}


- (void)setColorSetTypeValue:(int16_t)value_ {
	[self setColorSetType:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveColorSetTypeValue {
	NSNumber *result = [self primitiveColorSetType];
	return [result shortValue];
}

- (void)setPrimitiveColorSetTypeValue:(int16_t)value_ {
	[self setPrimitiveColorSetType:[NSNumber numberWithShort:value_]];
}





@dynamic disabledAndSelectedPatternImage;






@dynamic disabledPatternImage;






@dynamic highlightedAndDisabledPatternImage;






@dynamic highlightedAndSelectedPatternImage;






@dynamic highlightedPatternImage;






@dynamic normalPatternImage;






@dynamic patternColorStates;



- (int16_t)patternColorStatesValue {
	NSNumber *result = [self patternColorStates];
	return [result shortValue];
}


- (void)setPatternColorStatesValue:(int16_t)value_ {
	[self setPatternColorStates:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitivePatternColorStatesValue {
	NSNumber *result = [self primitivePatternColorStates];
	return [result shortValue];
}

- (void)setPrimitivePatternColorStatesValue:(int16_t)value_ {
	[self setPrimitivePatternColorStates:[NSNumber numberWithShort:value_]];
}





@dynamic selectedHighlightedAndDisabledPatternImage;






@dynamic selectedPatternImage;






@dynamic button;

	

@dynamic icons;

	






@end




