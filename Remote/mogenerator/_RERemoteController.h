// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RERemoteController.h instead.

#import <CoreData/CoreData.h>



extern const struct RERemoteControllerAttributes {
	 NSString *currentActivityKey;
	 NSString *currentRemoteKey;
} RERemoteControllerAttributes;



extern const struct RERemoteControllerRelationships {
	 NSString *remoteElements;
	 NSString *switchToConfigCommands;
	 NSString *switchToRemoteCommands;
	 NSString *topToolbar;
} RERemoteControllerRelationships;






@class RemoteElement;
@class SwitchToConfigCommand;
@class SwitchToRemoteCommand;
@class REButtonGroup;






@interface RERemoteControllerID : NSManagedObjectID {}
@end

@interface _RERemoteController : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RERemoteControllerID*)objectID;





@property (nonatomic, retain) NSString* currentActivityKey;



//- (BOOL)validateCurrentActivityKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* currentRemoteKey;



//- (BOOL)validateCurrentRemoteKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *remoteElements;

- (NSMutableSet*)remoteElementsSet;




@property (nonatomic, retain) NSSet *switchToConfigCommands;

- (NSMutableSet*)switchToConfigCommandsSet;




@property (nonatomic, retain) NSSet *switchToRemoteCommands;

- (NSMutableSet*)switchToRemoteCommandsSet;




@property (nonatomic, retain) REButtonGroup *topToolbar;

//- (BOOL)validateTopToolbar:(id*)value_ error:(NSError**)error_;





@end


@interface _RERemoteController (RemoteElementsCoreDataGeneratedAccessors)
- (void)addRemoteElements:(NSSet*)value_;
- (void)removeRemoteElements:(NSSet*)value_;
- (void)addRemoteElementsObject:(RemoteElement*)value_;
- (void)removeRemoteElementsObject:(RemoteElement*)value_;
@end

@interface _RERemoteController (SwitchToConfigCommandsCoreDataGeneratedAccessors)
- (void)addSwitchToConfigCommands:(NSSet*)value_;
- (void)removeSwitchToConfigCommands:(NSSet*)value_;
- (void)addSwitchToConfigCommandsObject:(SwitchToConfigCommand*)value_;
- (void)removeSwitchToConfigCommandsObject:(SwitchToConfigCommand*)value_;
@end

@interface _RERemoteController (SwitchToRemoteCommandsCoreDataGeneratedAccessors)
- (void)addSwitchToRemoteCommands:(NSSet*)value_;
- (void)removeSwitchToRemoteCommands:(NSSet*)value_;
- (void)addSwitchToRemoteCommandsObject:(SwitchToRemoteCommand*)value_;
- (void)removeSwitchToRemoteCommandsObject:(SwitchToRemoteCommand*)value_;
@end


@interface _RERemoteController (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCurrentActivityKey;
- (void)setPrimitiveCurrentActivityKey:(NSString*)value;




- (NSString*)primitiveCurrentRemoteKey;
- (void)setPrimitiveCurrentRemoteKey:(NSString*)value;





- (NSMutableSet*)primitiveRemoteElements;
- (void)setPrimitiveRemoteElements:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSwitchToConfigCommands;
- (void)setPrimitiveSwitchToConfigCommands:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSwitchToRemoteCommands;
- (void)setPrimitiveSwitchToRemoteCommands:(NSMutableSet*)value;



- (REButtonGroup*)primitiveTopToolbar;
- (void)setPrimitiveTopToolbar:(REButtonGroup*)value;


@end
