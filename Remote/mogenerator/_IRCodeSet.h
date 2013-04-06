// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IRCodeSet.h instead.

#import <CoreData/CoreData.h>
#import "BankObject.h"





extern const struct IRCodeSetRelationships {
	 NSString *codes;
	 NSString *manufacturer;
} IRCodeSetRelationships;






@class FactoryIRCode;
@class Manufacturer;


@interface IRCodeSetID : BankObjectID {}
@end

@interface _IRCodeSet : BankObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IRCodeSetID*)objectID;





@property (nonatomic, retain) NSSet *codes;

- (NSMutableSet*)codesSet;




@property (nonatomic, retain) Manufacturer *manufacturer;

//- (BOOL)validateManufacturer:(id*)value_ error:(NSError**)error_;





@end


@interface _IRCodeSet (CodesCoreDataGeneratedAccessors)
- (void)addCodes:(NSSet*)value_;
- (void)removeCodes:(NSSet*)value_;
- (void)addCodesObject:(FactoryIRCode*)value_;
- (void)removeCodesObject:(FactoryIRCode*)value_;
@end


@interface _IRCodeSet (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveCodes;
- (void)setPrimitiveCodes:(NSMutableSet*)value;



- (Manufacturer*)primitiveManufacturer;
- (void)setPrimitiveManufacturer:(Manufacturer*)value;


@end
