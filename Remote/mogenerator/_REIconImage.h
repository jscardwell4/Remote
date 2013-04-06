// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REIconImage.h instead.

#import <CoreData/CoreData.h>
#import "GalleryImage.h"



extern const struct REIconImageAttributes {
	 NSString *iconSet;
	 NSString *previewData;
	 NSString *subcategory;
} REIconImageAttributes;
















@interface REIconImageID : GalleryImageID {}
@end

@interface _REIconImage : GalleryImage {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REIconImageID*)objectID;





@property (nonatomic, retain) NSString* iconSet;



//- (BOOL)validateIconSet:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSData* previewData;



//- (BOOL)validatePreviewData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* subcategory;



//- (BOOL)validateSubcategory:(id*)value_ error:(NSError**)error_;






@end



@interface _REIconImage (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIconSet;
- (void)setPrimitiveIconSet:(NSString*)value;




- (NSData*)primitivePreviewData;
- (void)setPrimitivePreviewData:(NSData*)value;




- (NSString*)primitiveSubcategory;
- (void)setPrimitiveSubcategory:(NSString*)value;




@end
