// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ControlStateSet.m instead.

#import "_ControlStateSet.h"


const struct ControlStateSetAttributes ControlStateSetAttributes = {
	.disabled = @"disabled",
	.disabledAndSelected = @"disabledAndSelected",
	.highlighted = @"highlighted",
	.highlightedAndDisabled = @"highlightedAndDisabled",
	.highlightedAndSelected = @"highlightedAndSelected",
	.normal = @"normal",
	.selected = @"selected",
	.selectedHighlightedAndDisabled = @"selectedHighlightedAndDisabled",
	.uuid = @"uuid",
};








@implementation ControlStateSetID
@end

@implementation _ControlStateSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ControlStateSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ControlStateSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ControlStateSet" inManagedObjectContext:moc_];
}

- (ControlStateSetID*)objectID {
	return (ControlStateSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic disabled;






@dynamic disabledAndSelected;






@dynamic highlighted;






@dynamic highlightedAndDisabled;






@dynamic highlightedAndSelected;






@dynamic normal;






@dynamic selected;






@dynamic selectedHighlightedAndDisabled;






@dynamic uuid;











@end




