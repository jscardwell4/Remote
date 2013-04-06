// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommandContainer.m instead.

#import "_CommandContainer.h"


const struct CommandContainerAttributes CommandContainerAttributes = {
	.index = @"index",
	.uuid = @"uuid",
};








@implementation CommandContainerID
@end

@implementation _CommandContainer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CommandContainer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CommandContainer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CommandContainer" inManagedObjectContext:moc_];
}

- (CommandContainerID*)objectID {
	return (CommandContainerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic index;






@dynamic uuid;











@end




