// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankObjectPreview.h instead.

#import <CoreData/CoreData.h>



extern const struct BankObjectPreviewAttributes {
	 NSString *imageData;
	 NSString *name;
	 NSString *tag;
} BankObjectPreviewAttributes;
















@interface BankObjectPreviewID : NSManagedObjectID {}
@end

@interface _BankObjectPreview : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BankObjectPreviewID*)objectID;





@property (nonatomic, retain) NSData* imageData;



//- (BOOL)validateImageData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* tag;




@property (atomic) int16_t tagValue;
- (int16_t)tagValue;
- (void)setTagValue:(int16_t)value_;


//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;






@end



@interface _BankObjectPreview (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveImageData;
- (void)setPrimitiveImageData:(NSData*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveTag;
- (void)setPrimitiveTag:(NSNumber*)value;

- (int16_t)primitiveTagValue;
- (void)setPrimitiveTagValue:(int16_t)value_;




@end
