// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BankObjectGroup.h instead.

#import <CoreData/CoreData.h>



extern const struct BankObjectGroupAttributes {
	 NSString *name;
} BankObjectGroupAttributes;



extern const struct BankObjectGroupRelationships {
	 NSString *images;
	 NSString *presets;
} BankObjectGroupRelationships;






@class GalleryImage;
@class PresetInfo;




@interface BankObjectGroupID : NSManagedObjectID {}
@end

@interface _BankObjectGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BankObjectGroupID*)objectID;





@property (nonatomic, retain) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSSet *images;

- (NSMutableSet*)imagesSet;




@property (nonatomic, retain) NSSet *presets;

- (NSMutableSet*)presetsSet;





@end


@interface _BankObjectGroup (ImagesCoreDataGeneratedAccessors)
- (void)addImages:(NSSet*)value_;
- (void)removeImages:(NSSet*)value_;
- (void)addImagesObject:(GalleryImage*)value_;
- (void)removeImagesObject:(GalleryImage*)value_;
@end

@interface _BankObjectGroup (PresetsCoreDataGeneratedAccessors)
- (void)addPresets:(NSSet*)value_;
- (void)removePresets:(NSSet*)value_;
- (void)addPresetsObject:(PresetInfo*)value_;
- (void)removePresetsObject:(PresetInfo*)value_;
@end


@interface _BankObjectGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveImages;
- (void)setPrimitiveImages:(NSMutableSet*)value;



- (NSMutableSet*)primitivePresets;
- (void)setPrimitivePresets:(NSMutableSet*)value;


@end
