// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HTTPCommand.m instead.

#import "_HTTPCommand.h"


const struct HTTPCommandAttributes HTTPCommandAttributes = {
	.url = @"url",
};








@implementation HTTPCommandID
@end

@implementation _HTTPCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"HTTPCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"HTTPCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"HTTPCommand" inManagedObjectContext:moc_];
}

- (HTTPCommandID*)objectID {
	return (HTTPCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic url;











@end




