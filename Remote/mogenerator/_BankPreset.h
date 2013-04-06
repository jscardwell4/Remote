// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankPreset.h instead.

#import <CoreData/CoreData.h>
#import "BankObject.h"



extern const struct BankPresetAttributes {
	 NSString *previewData;
} BankPresetAttributes;












@interface BankPresetID : BankObjectID {}
@end

@interface _BankPreset : BankObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BankPresetID*)objectID;





@property (nonatomic, retain) NSData* previewData;



//- (BOOL)validatePreviewData:(id*)value_ error:(NSError**)error_;






@end



@interface _BankPreset (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitivePreviewData;
- (void)setPrimitivePreviewData:(NSData*)value;




@end
