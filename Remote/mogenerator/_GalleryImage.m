// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GalleryImage.m instead.

#import "_GalleryImage.h"


const struct GalleryImageAttributes GalleryImageAttributes = {
	.baseFileName = @"baseFileName",
	.displayName = @"displayName",
	.fileDirectory = @"fileDirectory",
	.fileNameExtension = @"fileNameExtension",
	.imageData = @"imageData",
	.leftCap = @"leftCap",
	.size = @"size",
	.tag = @"tag",
	.topCap = @"topCap",
	.useRetinaScale = @"useRetinaScale",
};



const struct GalleryImageRelationships GalleryImageRelationships = {
	.group = @"group",
	.remoteElement = @"remoteElement",
};






@implementation GalleryImageID
@end

@implementation _GalleryImage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REImage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REImage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REImage" inManagedObjectContext:moc_];
}

- (GalleryImageID*)objectID {
	return (GalleryImageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"leftCapValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"leftCap"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"topCapValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"topCap"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"useRetinaScaleValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"useRetinaScale"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic baseFileName;






@dynamic displayName;






@dynamic fileDirectory;






@dynamic fileNameExtension;






@dynamic imageData;






@dynamic leftCap;



- (float)leftCapValue {
	NSNumber *result = [self leftCap];
	return [result floatValue];
}


- (void)setLeftCapValue:(float)value_ {
	[self setLeftCap:[NSNumber numberWithFloat:value_]];
}


- (float)primitiveLeftCapValue {
	NSNumber *result = [self primitiveLeftCap];
	return [result floatValue];
}

- (void)setPrimitiveLeftCapValue:(float)value_ {
	[self setPrimitiveLeftCap:[NSNumber numberWithFloat:value_]];
}





@dynamic size;






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





@dynamic topCap;



- (float)topCapValue {
	NSNumber *result = [self topCap];
	return [result floatValue];
}


- (void)setTopCapValue:(float)value_ {
	[self setTopCap:[NSNumber numberWithFloat:value_]];
}


- (float)primitiveTopCapValue {
	NSNumber *result = [self primitiveTopCap];
	return [result floatValue];
}

- (void)setPrimitiveTopCapValue:(float)value_ {
	[self setPrimitiveTopCap:[NSNumber numberWithFloat:value_]];
}





@dynamic useRetinaScale;



- (BOOL)useRetinaScaleValue {
	NSNumber *result = [self useRetinaScale];
	return [result boolValue];
}


- (void)setUseRetinaScaleValue:(BOOL)value_ {
	[self setUseRetinaScale:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveUseRetinaScaleValue {
	NSNumber *result = [self primitiveUseRetinaScale];
	return [result boolValue];
}

- (void)setPrimitiveUseRetinaScaleValue:(BOOL)value_ {
	[self setPrimitiveUseRetinaScale:[NSNumber numberWithBool:value_]];
}





@dynamic group;

	

@dynamic remoteElement;

	
- (NSMutableSet*)remoteElementSet {
	[self willAccessValueForKey:@"remoteElement"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"remoteElement"];
  
	[self didAccessValueForKey:@"remoteElement"];
	return result;
}
	






@end




