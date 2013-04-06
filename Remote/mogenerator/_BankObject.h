// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankObject.h instead.

#import <CoreData/CoreData.h>



extern const struct BankObjectAttributes {
	 NSString *category;
	 NSString *exportFileFormat;
	 NSString *factoryObject;
	 NSString *name;
} BankObjectAttributes;


















@interface BankObjectID : NSManagedObjectID {}
@end

@interface _BankObject : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BankObjectID*)objectID;





@property (nonatomic, retain) NSString* category;



//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* exportFileFormat;



//- (BOOL)validateExportFileFormat:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* factoryObject;




@property (atomic) BOOL factoryObjectValue;
- (BOOL)factoryObjectValue;
- (void)setFactoryObjectValue:(BOOL)value_;


//- (BOOL)validateFactoryObject:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;






@end



@interface _BankObject (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCategory;
- (void)setPrimitiveCategory:(NSString*)value;




- (NSString*)primitiveExportFileFormat;
- (void)setPrimitiveExportFileFormat:(NSString*)value;




- (NSNumber*)primitiveFactoryObject;
- (void)setPrimitiveFactoryObject:(NSNumber*)value;

- (BOOL)primitiveFactoryObjectValue;
- (void)setPrimitiveFactoryObjectValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




@end
