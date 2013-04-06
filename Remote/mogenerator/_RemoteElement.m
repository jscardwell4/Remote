// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RemoteElement.m instead.

#import "_RemoteElement.h"


const struct RemoteElementAttributes RemoteElementAttributes = {
	.appearance = @"appearance",
	.backgroundColor = @"backgroundColor",
	.backgroundImageAlpha = @"backgroundImageAlpha",
	.displayName = @"displayName",
	.flags = @"flags",
	.key = @"key",
	.tag = @"tag",
	.uuid = @"uuid",
};



const struct RemoteElementRelationships RemoteElementRelationships = {
	.backgroundImage = @"backgroundImage",
	.configurationDelegate = @"configurationDelegate",
	.constraints = @"constraints",
	.controller = @"controller",
	.firstItemConstraints = @"firstItemConstraints",
	.layoutConfiguration = @"layoutConfiguration",
	.parentElement = @"parentElement",
	.secondItemConstraints = @"secondItemConstraints",
	.subelements = @"subelements",
};






@implementation RemoteElementID
@end

@implementation _RemoteElement

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RemoteElement" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RemoteElement";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RemoteElement" inManagedObjectContext:moc_];
}

- (RemoteElementID*)objectID {
	return (RemoteElementID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"appearanceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"appearance"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"backgroundImageAlphaValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"backgroundImageAlpha"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
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




@dynamic appearance;



- (int64_t)appearanceValue {
	NSNumber *result = [self appearance];
	return [result longLongValue];
}


- (void)setAppearanceValue:(int64_t)value_ {
	[self setAppearance:[NSNumber numberWithLongLong:value_]];
}


- (int64_t)primitiveAppearanceValue {
	NSNumber *result = [self primitiveAppearance];
	return [result longLongValue];
}

- (void)setPrimitiveAppearanceValue:(int64_t)value_ {
	[self setPrimitiveAppearance:[NSNumber numberWithLongLong:value_]];
}





@dynamic backgroundColor;






@dynamic backgroundImageAlpha;



- (float)backgroundImageAlphaValue {
	NSNumber *result = [self backgroundImageAlpha];
	return [result floatValue];
}


- (void)setBackgroundImageAlphaValue:(float)value_ {
	[self setBackgroundImageAlpha:[NSNumber numberWithFloat:value_]];
}


- (float)primitiveBackgroundImageAlphaValue {
	NSNumber *result = [self primitiveBackgroundImageAlpha];
	return [result floatValue];
}

- (void)setPrimitiveBackgroundImageAlphaValue:(float)value_ {
	[self setPrimitiveBackgroundImageAlpha:[NSNumber numberWithFloat:value_]];
}





@dynamic displayName;






@dynamic flags;



- (int64_t)flagsValue {
	NSNumber *result = [self flags];
	return [result longLongValue];
}


- (void)setFlagsValue:(int64_t)value_ {
	[self setFlags:[NSNumber numberWithLongLong:value_]];
}


- (int64_t)primitiveFlagsValue {
	NSNumber *result = [self primitiveFlags];
	return [result longLongValue];
}

- (void)setPrimitiveFlagsValue:(int64_t)value_ {
	[self setPrimitiveFlags:[NSNumber numberWithLongLong:value_]];
}





@dynamic key;






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






@dynamic backgroundImage;

	

@dynamic configurationDelegate;

	

@dynamic constraints;

	
- (NSMutableSet*)constraintsSet {
	[self willAccessValueForKey:@"constraints"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"constraints"];
  
	[self didAccessValueForKey:@"constraints"];
	return result;
}
	

@dynamic controller;

	

@dynamic firstItemConstraints;

	
- (NSMutableSet*)firstItemConstraintsSet {
	[self willAccessValueForKey:@"firstItemConstraints"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"firstItemConstraints"];
  
	[self didAccessValueForKey:@"firstItemConstraints"];
	return result;
}
	

@dynamic layoutConfiguration;

	

@dynamic parentElement;

	

@dynamic secondItemConstraints;

	
- (NSMutableSet*)secondItemConstraintsSet {
	[self willAccessValueForKey:@"secondItemConstraints"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"secondItemConstraints"];
  
	[self didAccessValueForKey:@"secondItemConstraints"];
	return result;
}
	

@dynamic subelements;

	
- (NSMutableOrderedSet*)subelementsSet {
	[self willAccessValueForKey:@"subelements"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"subelements"];
  
	[self didAccessValueForKey:@"subelements"];
	return result;
}
	






@end


@implementation _RemoteElement (SubelementsCoreDataGeneratedAccessors)
- (void)addSubelements:(NSOrderedSet*)value_ {
	[self.subelementsSet unionOrderedSet:value_];
}
- (void)removeSubelements:(NSOrderedSet*)value_ {
	[self.subelementsSet minusOrderedSet:value_];
}
- (void)addSubelementsObject:(RemoteElement*)value_ {
	[self.subelementsSet addObject:value_];
}
- (void)removeSubelementsObject:(RemoteElement*)value_ {
	[self.subelementsSet removeObject:value_];
}
@end



