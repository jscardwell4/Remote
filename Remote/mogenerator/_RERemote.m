// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RERemote.m instead.

#import "_RERemote.h"


const struct RERemoteAttributes RERemoteAttributes = {
	.topBarHiddenOnLoad = @"topBarHiddenOnLoad",
};








@implementation RERemoteID
@end

@implementation _RERemote

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"RERemote" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"RERemote";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"RERemote" inManagedObjectContext:moc_];
}

- (RERemoteID*)objectID {
	return (RERemoteID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"topBarHiddenOnLoadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"topBarHiddenOnLoad"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic topBarHiddenOnLoad;



- (BOOL)topBarHiddenOnLoadValue {
	NSNumber *result = [self topBarHiddenOnLoad];
	return [result boolValue];
}


- (void)setTopBarHiddenOnLoadValue:(BOOL)value_ {
	[self setTopBarHiddenOnLoad:[NSNumber numberWithBool:value_]];
}


- (BOOL)primitiveTopBarHiddenOnLoadValue {
	NSNumber *result = [self primitiveTopBarHiddenOnLoad];
	return [result boolValue];
}

- (void)setPrimitiveTopBarHiddenOnLoadValue:(BOOL)value_ {
	[self setPrimitiveTopBarHiddenOnLoad:[NSNumber numberWithBool:value_]];
}










@end




