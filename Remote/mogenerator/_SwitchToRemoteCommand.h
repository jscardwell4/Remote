// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SwitchToRemoteCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"



extern const struct SwitchToRemoteCommandAttributes {
	 NSString *remoteKey;
} SwitchToRemoteCommandAttributes;



extern const struct SwitchToRemoteCommandRelationships {
	 NSString *remoteController;
} SwitchToRemoteCommandRelationships;






@class RERemoteController;




@interface SwitchToRemoteCommandID : CommandID {}
@end

@interface _SwitchToRemoteCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SwitchToRemoteCommandID*)objectID;





@property (nonatomic, retain) NSString* remoteKey;



//- (BOOL)validateRemoteKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) RERemoteController *remoteController;

//- (BOOL)validateRemoteController:(id*)value_ error:(NSError**)error_;





@end



@interface _SwitchToRemoteCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRemoteKey;
- (void)setPrimitiveRemoteKey:(NSString*)value;





- (RERemoteController*)primitiveRemoteController;
- (void)setPrimitiveRemoteController:(RERemoteController*)value;


@end
