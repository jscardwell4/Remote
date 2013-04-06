// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DelayCommand.m instead.

#import "_DelayCommand.h"


const struct DelayCommandAttributes DelayCommandAttributes = {
	.duration = @"duration",
};







const struct DelayCommandUserInfo DelayCommandUserInfo = {
};


@implementation DelayCommandID
@end

@implementation _DelayCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DelayCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DelayCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DelayCommand" inManagedObjectContext:moc_];
}

- (DelayCommandID*)objectID {
	return (DelayCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"durationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"duration"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic duration;



- (float)durationValue {
	NSNumber *result = [self duration];
	return [result floatValue];
}


- (void)setDurationValue:(float)value_ {
	[self setDuration:[NSNumber numberWithFloat:value_]];
}


- (float)primitiveDurationValue {
	NSNumber *result = [self primitiveDuration];
	return [result floatValue];
}

- (void)setPrimitiveDurationValue:(float)value_ {
	[self setPrimitiveDuration:[NSNumber numberWithFloat:value_]];
}










@end




