// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButtonImage.h instead.

#import <CoreData/CoreData.h>
#import "GalleryImage.h"



extern const struct REButtonImageAttributes {
	 NSString *state;
} REButtonImageAttributes;












@interface REButtonImageID : GalleryImageID {}
@end

@interface _REButtonImage : GalleryImage {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REButtonImageID*)objectID;





@property (nonatomic, retain) NSNumber* state;




@property (atomic) int16_t stateValue;
- (int16_t)stateValue;
- (void)setStateValue:(int16_t)value_;


//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;






@end



@interface _REButtonImage (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (int16_t)primitiveStateValue;
- (void)setPrimitiveStateValue:(int16_t)value_;




@end
