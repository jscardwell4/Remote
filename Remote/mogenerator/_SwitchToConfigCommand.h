// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SwitchToConfigCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"



extern const struct SwitchToConfigCommandAttributes {
	 NSString *configuration;
} SwitchToConfigCommandAttributes;



extern const struct SwitchToConfigCommandRelationships {
	 NSString *remoteController;
} SwitchToConfigCommandRelationships;






@class RERemoteController;




@interface SwitchToConfigCommandID : CommandID {}
@end

@interface _SwitchToConfigCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SwitchToConfigCommandID*)objectID;





@property (nonatomic, retain) NSString* configuration;



//- (BOOL)validateConfiguration:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) RERemoteController *remoteController;

//- (BOOL)validateRemoteController:(id*)value_ error:(NSError**)error_;





@end



@interface _SwitchToConfigCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveConfiguration;
- (void)setPrimitiveConfiguration:(NSString*)value;





- (RERemoteController*)primitiveRemoteController;
- (void)setPrimitiveRemoteController:(RERemoteController*)value;


@end
