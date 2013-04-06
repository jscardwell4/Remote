// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REPickerLabelButtonGroup.m instead.

#import "_REPickerLabelButtonGroup.h"


const struct REPickerLabelButtonGroupAttributes REPickerLabelButtonGroupAttributes = {
	.commandSetLabels = @"commandSetLabels",
	.commandSets = @"commandSets",
};








@implementation REPickerLabelButtonGroupID
@end

@implementation _REPickerLabelButtonGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"REPickerLabelButtonGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"REPickerLabelButtonGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"REPickerLabelButtonGroup" inManagedObjectContext:moc_];
}

- (REPickerLabelButtonGroupID*)objectID {
	return (REPickerLabelButtonGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic commandSetLabels;






@dynamic commandSets;











@end




