// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MacroCommand.m instead.

#import "_MacroCommand.h"




const struct MacroCommandRelationships MacroCommandRelationships = {
	.commands = @"commands",
};






@implementation MacroCommandID
@end

@implementation _MacroCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MacroCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MacroCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MacroCommand" inManagedObjectContext:moc_];
}

- (MacroCommandID*)objectID {
	return (MacroCommandID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic commands;

	
- (NSMutableOrderedSet*)commandsSet {
	[self willAccessValueForKey:@"commands"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"commands"];
  
	[self didAccessValueForKey:@"commands"];
	return result;
}
	






@end


@implementation _MacroCommand (CommandsCoreDataGeneratedAccessors)
- (void)addCommands:(NSOrderedSet*)value_ {
	[self.commandsSet unionOrderedSet:value_];
}
- (void)removeCommands:(NSOrderedSet*)value_ {
	[self.commandsSet minusOrderedSet:value_];
}
- (void)addCommandsObject:(Command*)value_ {
	[self.commandsSet addObject:value_];
}
- (void)removeCommandsObject:(Command*)value_ {
	[self.commandsSet removeObject:value_];
}
@end



