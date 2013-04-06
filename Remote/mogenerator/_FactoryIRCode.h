// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FactoryIRCode.h instead.

#import <CoreData/CoreData.h>
#import "IRCode.h"





extern const struct FactoryIRCodeRelationships {
	 NSString *codeSet;
} FactoryIRCodeRelationships;






@class IRCodeSet;


@interface FactoryIRCodeID : IRCodeID {}
@end

@interface _FactoryIRCode : IRCode {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FactoryIRCodeID*)objectID;





@property (nonatomic, retain) IRCodeSet *codeSet;

//- (BOOL)validateCodeSet:(id*)value_ error:(NSError**)error_;





@end



@interface _FactoryIRCode (CoreDataGeneratedPrimitiveAccessors)



- (IRCodeSet*)primitiveCodeSet;
- (void)setPrimitiveCodeSet:(IRCodeSet*)value;


@end
