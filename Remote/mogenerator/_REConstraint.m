// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REConstraint.m instead.

#import "_REConstraint.h"


const struct REConstraintAttributes REConstraintAttributes = {
	.constant = @"constant",
	.firstAttribute = @"firstAttribute",
	.key = @"key",
	.multiplier = @"multiplier",
	.priority = @"priority",
	.relation = @"relation",
	.secondAttribute = @"secondAttribute",
	.tag = @"tag",
	.uuid = @"uuid",
};



const struct REConstraintRelationships REConstraintRelationships = {
	.firstItem = @"firstItem",
	.owner = @"owner",
	.secondItem = @"secondItem",
};






@implementation REConstraintID
@end

@implementation _REConstraint

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REConstraint" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REConstraint";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REConstraint" inManagedObjectContext:moc_];
}

- (REConstraintID*)objectID {
	return (REConstraintID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"constantValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"constant"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"firstAttributeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"firstAttribute"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"multiplierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"multiplier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"relationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"relation"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"secondAttributeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"secondAttribute"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic constant;



- (float)constantValue {
	NSNumber *result = [self constant];
	return [result floatValue];
}


- (void)setConstantValue:(float)value_ {
	[self setConstant:[NSNumber numberWithFloat:value_]];
}


- (float)primitiveConstantValue {
	NSNumber *result = [self primitiveConstant];
	return [result floatValue];
}

- (void)setPrimitiveConstantValue:(float)value_ {
	[self setPrimitiveConstant:[NSNumber numberWithFloat:value_]];
}





@dynamic firstAttribute;



- (int16_t)firstAttributeValue {
	NSNumber *result = [self firstAttribute];
	return [result shortValue];
}


- (void)setFirstAttributeValue:(int16_t)value_ {
	[self setFirstAttribute:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveFirstAttributeValue {
	NSNumber *result = [self primitiveFirstAttribute];
	return [result shortValue];
}

- (void)setPrimitiveFirstAttributeValue:(int16_t)value_ {
	[self setPrimitiveFirstAttribute:[NSNumber numberWithShort:value_]];
}





@dynamic key;






@dynamic multiplier;



- (float)multiplierValue {
	NSNumber *result = [self multiplier];
	return [result floatValue];
}


- (void)setMultiplierValue:(float)value_ {
	[self setMultiplier:[NSNumber numberWithFloat:value_]];
}


- (float)primitiveMultiplierValue {
	NSNumber *result = [self primitiveMultiplier];
	return [result floatValue];
}

- (void)setPrimitiveMultiplierValue:(float)value_ {
	[self setPrimitiveMultiplier:[NSNumber numberWithFloat:value_]];
}





@dynamic priority;



- (float)priorityValue {
	NSNumber *result = [self priority];
	return [result floatValue];
}


- (void)setPriorityValue:(float)value_ {
	[self setPriority:[NSNumber numberWithFloat:value_]];
}


- (float)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result floatValue];
}

- (void)setPrimitivePriorityValue:(float)value_ {
	[self setPrimitivePriority:[NSNumber numberWithFloat:value_]];
}





@dynamic relation;



- (int16_t)relationValue {
	NSNumber *result = [self relation];
	return [result shortValue];
}


- (void)setRelationValue:(int16_t)value_ {
	[self setRelation:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveRelationValue {
	NSNumber *result = [self primitiveRelation];
	return [result shortValue];
}

- (void)setPrimitiveRelationValue:(int16_t)value_ {
	[self setPrimitiveRelation:[NSNumber numberWithShort:value_]];
}





@dynamic secondAttribute;



- (int16_t)secondAttributeValue {
	NSNumber *result = [self secondAttribute];
	return [result shortValue];
}


- (void)setSecondAttributeValue:(int16_t)value_ {
	[self setSecondAttribute:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveSecondAttributeValue {
	NSNumber *result = [self primitiveSecondAttribute];
	return [result shortValue];
}

- (void)setPrimitiveSecondAttributeValue:(int16_t)value_ {
	[self setPrimitiveSecondAttribute:[NSNumber numberWithShort:value_]];
}





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





@dynamic uuid;






@dynamic firstItem;

	

@dynamic owner;

	

@dynamic secondItem;

	






@end




