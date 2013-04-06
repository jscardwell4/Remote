// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PowerCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"



extern const struct PowerCommandAttributes {
	 NSString *state;
} PowerCommandAttributes;



extern const struct PowerCommandRelationships {
	 NSString *device;
} PowerCommandRelationships;






@class ComponentDevice;




@interface PowerCommandID : CommandID {}
@end

@interface _PowerCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PowerCommandID*)objectID;





@property (nonatomic, retain) NSNumber* state;




@property (atomic) BOOL stateValue;
- (BOOL)stateValue;
- (void)setStateValue:(BOOL)value_;


//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) ComponentDevice *device;

//- (BOOL)validateDevice:(id*)value_ error:(NSError**)error_;





@end



@interface _PowerCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (BOOL)primitiveStateValue;
- (void)setPrimitiveStateValue:(BOOL)value_;





- (ComponentDevice*)primitiveDevice;
- (void)setPrimitiveDevice:(ComponentDevice*)value;


@end
