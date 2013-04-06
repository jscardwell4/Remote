// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CommandSet.m instead.

#import "_CommandSet.h"


const struct CommandSetAttributes CommandSetAttributes = {
	.name = @"name",
	.type = @"type",
};



const struct CommandSetRelationships CommandSetRelationships = {
	.buttonGroup = @"buttonGroup",
	.commandSetCollections = @"commandSetCollections",
	.commands = @"commands",
	.delegates = @"delegates",
};






@implementation CommandSetID
@end

@implementation _CommandSet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CommandSet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CommandSet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CommandSet" inManagedObjectContext:moc_];
}

- (CommandSetID*)objectID {
	return (CommandSetID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic name;






@dynamic type;



- (int16_t)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}


- (void)setTypeValue:(int16_t)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}


- (int16_t)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result shortValue];
}

- (void)setPrimitiveTypeValue:(int16_t)value_ {
	[self setPrimitiveType:[NSNumber numberWithShort:value_]];
}





@dynamic buttonGroup;

	

@dynamic commandSetCollections;

	
- (NSMutableSet*)commandSetCollectionsSet {
	[self willAccessValueForKey:@"commandSetCollections"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"commandSetCollections"];
  
	[self didAccessValueForKey:@"commandSetCollections"];
	return result;
}
	

@dynamic commands;

	
- (NSMutableSet*)commandsSet {
	[self willAccessValueForKey:@"commands"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"commands"];
  
	[self didAccessValueForKey:@"commands"];
	return result;
}
	

@dynamic delegates;

	
- (NSMutableSet*)delegatesSet {
	[self willAccessValueForKey:@"delegates"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"delegates"];
  
	[self didAccessValueForKey:@"delegates"];
	return result;
}
	






@end




