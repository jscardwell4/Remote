// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButton.m instead.

#import "_REButton.h"


const struct REButtonAttributes REButtonAttributes = {
	.contentEdgeInsets = @"contentEdgeInsets",
	.imageEdgeInsets = @"imageEdgeInsets",
	.titleEdgeInsets = @"titleEdgeInsets",
};



const struct REButtonRelationships REButtonRelationships = {
	.backgroundColors = @"backgroundColors",
	.command = @"command",
	.icons = @"icons",
	.images = @"images",
	.longPressCommand = @"longPressCommand",
	.titles = @"titles",
};






@implementation REButtonID
@end

@implementation _REButton

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REButton" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REButton";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REButton" inManagedObjectContext:moc_];
}

- (REButtonID*)objectID {
	return (REButtonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic contentEdgeInsets;






@dynamic imageEdgeInsets;






@dynamic titleEdgeInsets;






@dynamic backgroundColors;

	

@dynamic command;

	

@dynamic icons;

	

@dynamic images;

	

@dynamic longPressCommand;

	

@dynamic titles;

	






@end




