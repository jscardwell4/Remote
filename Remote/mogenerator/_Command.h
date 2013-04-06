// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Command.h instead.

#import <CoreData/CoreData.h>



extern const struct CommandAttributes {
	 NSString *indicator;
	 NSString *tag;
	 NSString *uuid;
} CommandAttributes;



extern const struct CommandRelationships {
	 NSString *button;
	 NSString *buttonDelegates;
	 NSString *commandSets;
	 NSString *longPressButton;
	 NSString *macroCommands;
	 NSString *offDevice;
	 NSString *onDevice;
} CommandRelationships;





extern const struct CommandUserInfo {
	 NSString *com.apple.syncservices.Syncable;
} CommandUserInfo;


@class REButton;
@class REButtonConfigurationDelegate;
@class CommandSet;
@class REButton;
@class MacroCommand;
@class ComponentDevice;
@class ComponentDevice;








@interface CommandID : NSManagedObjectID {}
@end

@interface _Command : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommandID*)objectID;





@property (nonatomic, retain) NSNumber* indicator;




@property (atomic) BOOL indicatorValue;
- (BOOL)indicatorValue;
- (void)setIndicatorValue:(BOOL)value_;


//- (BOOL)validateIndicator:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* tag;




@property (atomic) int16_t tagValue;
- (int16_t)tagValue;
- (void)setTagValue:(int16_t)value_;


//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) REButton *button;

//- (BOOL)validateButton:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *buttonDelegates;

- (NSMutableSet*)buttonDelegatesSet;




@property (nonatomic, retain) NSSet *commandSets;

- (NSMutableSet*)commandSetsSet;




@property (nonatomic, retain) REButton *longPressButton;

//- (BOOL)validateLongPressButton:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *macroCommands;

- (NSMutableSet*)macroCommandsSet;




@property (nonatomic, retain) ComponentDevice *offDevice;

//- (BOOL)validateOffDevice:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ComponentDevice *onDevice;

//- (BOOL)validateOnDevice:(id*)value_ error:(NSError**)error_;





@end


@interface _Command (ButtonDelegatesCoreDataGeneratedAccessors)
- (void)addButtonDelegates:(NSSet*)value_;
- (void)removeButtonDelegates:(NSSet*)value_;
- (void)addButtonDelegatesObject:(REButtonConfigurationDelegate*)value_;
- (void)removeButtonDelegatesObject:(REButtonConfigurationDelegate*)value_;
@end

@interface _Command (CommandSetsCoreDataGeneratedAccessors)
- (void)addCommandSets:(NSSet*)value_;
- (void)removeCommandSets:(NSSet*)value_;
- (void)addCommandSetsObject:(CommandSet*)value_;
- (void)removeCommandSetsObject:(CommandSet*)value_;
@end

@interface _Command (MacroCommandsCoreDataGeneratedAccessors)
- (void)addMacroCommands:(NSSet*)value_;
- (void)removeMacroCommands:(NSSet*)value_;
- (void)addMacroCommandsObject:(MacroCommand*)value_;
- (void)removeMacroCommandsObject:(MacroCommand*)value_;
@end


@interface _Command (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIndicator;
- (void)setPrimitiveIndicator:(NSNumber*)value;

- (BOOL)primitiveIndicatorValue;
- (void)setPrimitiveIndicatorValue:(BOOL)value_;




- (NSNumber*)primitiveTag;
- (void)setPrimitiveTag:(NSNumber*)value;

- (int16_t)primitiveTagValue;
- (void)setPrimitiveTagValue:(int16_t)value_;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;





- (REButton*)primitiveButton;
- (void)setPrimitiveButton:(REButton*)value;



- (NSMutableSet*)primitiveButtonDelegates;
- (void)setPrimitiveButtonDelegates:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCommandSets;
- (void)setPrimitiveCommandSets:(NSMutableSet*)value;



- (REButton*)primitiveLongPressButton;
- (void)setPrimitiveLongPressButton:(REButton*)value;



- (NSMutableSet*)primitiveMacroCommands;
- (void)setPrimitiveMacroCommands:(NSMutableSet*)value;



- (ComponentDevice*)primitiveOffDevice;
- (void)setPrimitiveOffDevice:(ComponentDevice*)value;



- (ComponentDevice*)primitiveOnDevice;
- (void)setPrimitiveOnDevice:(ComponentDevice*)value;


@end
