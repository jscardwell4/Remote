// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GalleryImage.h instead.

#import <CoreData/CoreData.h>
#import "BankObject.h"



extern const struct GalleryImageAttributes {
	 NSString *baseFileName;
	 NSString *displayName;
	 NSString *fileDirectory;
	 NSString *fileNameExtension;
	 NSString *imageData;
	 NSString *leftCap;
	 NSString *size;
	 NSString *tag;
	 NSString *topCap;
	 NSString *useRetinaScale;
} GalleryImageAttributes;



extern const struct GalleryImageRelationships {
	 NSString *group;
	 NSString *remoteElement;
} GalleryImageRelationships;






@class BankObjectGroup;
@class RemoteElement;















@class NSObject;







@interface GalleryImageID : BankObjectID {}
@end

@interface _GalleryImage : BankObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GalleryImageID*)objectID;





@property (nonatomic, retain) NSString* baseFileName;



//- (BOOL)validateBaseFileName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* fileDirectory;



//- (BOOL)validateFileDirectory:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* fileNameExtension;



//- (BOOL)validateFileNameExtension:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSData* imageData;



//- (BOOL)validateImageData:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* leftCap;




@property (atomic) float leftCapValue;
- (float)leftCapValue;
- (void)setLeftCapValue:(float)value_;


//- (BOOL)validateLeftCap:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id size;



//- (BOOL)validateSize:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* tag;




@property (atomic) int16_t tagValue;
- (int16_t)tagValue;
- (void)setTagValue:(int16_t)value_;


//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* topCap;




@property (atomic) float topCapValue;
- (float)topCapValue;
- (void)setTopCapValue:(float)value_;


//- (BOOL)validateTopCap:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* useRetinaScale;




@property (atomic) BOOL useRetinaScaleValue;
- (BOOL)useRetinaScaleValue;
- (void)setUseRetinaScaleValue:(BOOL)value_;


//- (BOOL)validateUseRetinaScale:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) BankObjectGroup *group;

//- (BOOL)validateGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *remoteElement;

- (NSMutableSet*)remoteElementSet;





@end


@interface _GalleryImage (RemoteElementCoreDataGeneratedAccessors)
- (void)addRemoteElement:(NSSet*)value_;
- (void)removeRemoteElement:(NSSet*)value_;
- (void)addRemoteElementObject:(RemoteElement*)value_;
- (void)removeRemoteElementObject:(RemoteElement*)value_;
@end


@interface _GalleryImage (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBaseFileName;
- (void)setPrimitiveBaseFileName:(NSString*)value;




- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSString*)primitiveFileDirectory;
- (void)setPrimitiveFileDirectory:(NSString*)value;




- (NSString*)primitiveFileNameExtension;
- (void)setPrimitiveFileNameExtension:(NSString*)value;




- (NSData*)primitiveImageData;
- (void)setPrimitiveImageData:(NSData*)value;




- (NSNumber*)primitiveLeftCap;
- (void)setPrimitiveLeftCap:(NSNumber*)value;

- (float)primitiveLeftCapValue;
- (void)setPrimitiveLeftCapValue:(float)value_;




- (id)primitiveSize;
- (void)setPrimitiveSize:(id)value;




- (NSNumber*)primitiveTag;
- (void)setPrimitiveTag:(NSNumber*)value;

- (int16_t)primitiveTagValue;
- (void)setPrimitiveTagValue:(int16_t)value_;




- (NSNumber*)primitiveTopCap;
- (void)setPrimitiveTopCap:(NSNumber*)value;

- (float)primitiveTopCapValue;
- (void)setPrimitiveTopCapValue:(float)value_;




- (NSNumber*)primitiveUseRetinaScale;
- (void)setPrimitiveUseRetinaScale:(NSNumber*)value;

- (BOOL)primitiveUseRetinaScaleValue;
- (void)setPrimitiveUseRetinaScaleValue:(BOOL)value_;





- (BankObjectGroup*)primitiveGroup;
- (void)setPrimitiveGroup:(BankObjectGroup*)value;



- (NSMutableSet*)primitiveRemoteElement;
- (void)setPrimitiveRemoteElement:(NSMutableSet*)value;


@end
