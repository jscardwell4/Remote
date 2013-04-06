// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SendIRCommand.h instead.

#import <CoreData/CoreData.h>
#import "Command.h"



extern const struct SendIRCommandAttributes {
	 NSString *portOverride;
} SendIRCommandAttributes;



extern const struct SendIRCommandRelationships {
	 NSString *code;
} SendIRCommandRelationships;






@class IRCode;




@interface SendIRCommandID : CommandID {}
@end

@interface _SendIRCommand : Command {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SendIRCommandID*)objectID;





@property (nonatomic, retain) NSNumber* portOverride;




@property (atomic) int16_t portOverrideValue;
- (int16_t)portOverrideValue;
- (void)setPortOverrideValue:(int16_t)value_;


//- (BOOL)validatePortOverride:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) IRCode *code;

//- (BOOL)validateCode:(id*)value_ error:(NSError**)error_;





@end



@interface _SendIRCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitivePortOverride;
- (void)setPrimitivePortOverride:(NSNumber*)value;

- (int16_t)primitivePortOverrideValue;
- (void)setPrimitivePortOverrideValue:(int16_t)value_;





- (IRCode*)primitiveCode;
- (void)setPrimitiveCode:(IRCode*)value;


@end
