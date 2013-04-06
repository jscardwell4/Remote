// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PresetInfo.h instead.

#import <CoreData/CoreData.h>



extern const struct PresetInfoAttributes {
	 NSString *presetName;
} PresetInfoAttributes;



extern const struct PresetInfoRelationships {
	 NSString *galleryGroup;
} PresetInfoRelationships;






@class BankObjectGroup;




@interface PresetInfoID : NSManagedObjectID {}
@end

@interface _PresetInfo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PresetInfoID*)objectID;





@property (nonatomic, retain) NSString* presetName;



//- (BOOL)validatePresetName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) BankObjectGroup *galleryGroup;

//- (BOOL)validateGalleryGroup:(id*)value_ error:(NSError**)error_;





@end



@interface _PresetInfo (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePresetName;
- (void)setPrimitivePresetName:(NSString*)value;





- (BankObjectGroup*)primitiveGalleryGroup;
- (void)setPrimitiveGalleryGroup:(BankObjectGroup*)value;


@end
