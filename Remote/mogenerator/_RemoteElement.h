// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to RemoteElement.h instead.

#import <CoreData/CoreData.h>



extern const struct RemoteElementAttributes {
	 NSString *appearance;
	 NSString *backgroundColor;
	 NSString *backgroundImageAlpha;
	 NSString *displayName;
	 NSString *flags;
	 NSString *key;
	 NSString *tag;
	 NSString *uuid;
} RemoteElementAttributes;



extern const struct RemoteElementRelationships {
	 NSString *backgroundImage;
	 NSString *configurationDelegate;
	 NSString *constraints;
	 NSString *controller;
	 NSString *firstItemConstraints;
	 NSString *layoutConfiguration;
	 NSString *parentElement;
	 NSString *secondItemConstraints;
	 NSString *subelements;
} RemoteElementRelationships;






@class GalleryImage;
@class REConfigurationDelegate;
@class REConstraint;
@class RERemoteController;
@class REConstraint;
@class RELayoutConfiguration;
@class RemoteElement;
@class REConstraint;
@class RemoteElement;





@class NSObject;













@interface RemoteElementID : NSManagedObjectID {}
@end

@interface _RemoteElement : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (RemoteElementID*)objectID;





@property (nonatomic, retain) NSNumber* appearance;




@property (atomic) int64_t appearanceValue;
- (int64_t)appearanceValue;
- (void)setAppearanceValue:(int64_t)value_;


//- (BOOL)validateAppearance:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id backgroundColor;



//- (BOOL)validateBackgroundColor:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* backgroundImageAlpha;




@property (atomic) float backgroundImageAlphaValue;
- (float)backgroundImageAlphaValue;
- (void)setBackgroundImageAlphaValue:(float)value_;


//- (BOOL)validateBackgroundImageAlpha:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* flags;




@property (atomic) int64_t flagsValue;
- (int64_t)flagsValue;
- (void)setFlagsValue:(int64_t)value_;


//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* tag;




@property (atomic) int16_t tagValue;
- (int16_t)tagValue;
- (void)setTagValue:(int16_t)value_;


//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) GalleryImage *backgroundImage;

//- (BOOL)validateBackgroundImage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) REConfigurationDelegate *configurationDelegate;

//- (BOOL)validateConfigurationDelegate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *constraints;

- (NSMutableSet*)constraintsSet;




@property (nonatomic, retain) RERemoteController *controller;

//- (BOOL)validateController:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *firstItemConstraints;

- (NSMutableSet*)firstItemConstraintsSet;




@property (nonatomic, retain) RELayoutConfiguration *layoutConfiguration;

//- (BOOL)validateLayoutConfiguration:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RemoteElement *parentElement;

//- (BOOL)validateParentElement:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *secondItemConstraints;

- (NSMutableSet*)secondItemConstraintsSet;




@property (nonatomic, retain) NSOrderedSet *subelements;

- (NSMutableOrderedSet*)subelementsSet;





@end


@interface _RemoteElement (ConstraintsCoreDataGeneratedAccessors)
- (void)addConstraints:(NSSet*)value_;
- (void)removeConstraints:(NSSet*)value_;
- (void)addConstraintsObject:(REConstraint*)value_;
- (void)removeConstraintsObject:(REConstraint*)value_;
@end

@interface _RemoteElement (FirstItemConstraintsCoreDataGeneratedAccessors)
- (void)addFirstItemConstraints:(NSSet*)value_;
- (void)removeFirstItemConstraints:(NSSet*)value_;
- (void)addFirstItemConstraintsObject:(REConstraint*)value_;
- (void)removeFirstItemConstraintsObject:(REConstraint*)value_;
@end

@interface _RemoteElement (SecondItemConstraintsCoreDataGeneratedAccessors)
- (void)addSecondItemConstraints:(NSSet*)value_;
- (void)removeSecondItemConstraints:(NSSet*)value_;
- (void)addSecondItemConstraintsObject:(REConstraint*)value_;
- (void)removeSecondItemConstraintsObject:(REConstraint*)value_;
@end

@interface _RemoteElement (SubelementsCoreDataGeneratedAccessors)
- (void)addSubelements:(NSOrderedSet*)value_;
- (void)removeSubelements:(NSOrderedSet*)value_;
- (void)addSubelementsObject:(RemoteElement*)value_;
- (void)removeSubelementsObject:(RemoteElement*)value_;
@end


@interface _RemoteElement (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAppearance;
- (void)setPrimitiveAppearance:(NSNumber*)value;

- (int64_t)primitiveAppearanceValue;
- (void)setPrimitiveAppearanceValue:(int64_t)value_;




- (id)primitiveBackgroundColor;
- (void)setPrimitiveBackgroundColor:(id)value;




- (NSNumber*)primitiveBackgroundImageAlpha;
- (void)setPrimitiveBackgroundImageAlpha:(NSNumber*)value;

- (float)primitiveBackgroundImageAlphaValue;
- (void)setPrimitiveBackgroundImageAlphaValue:(float)value_;




- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int64_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int64_t)value_;




- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSNumber*)primitiveTag;
- (void)setPrimitiveTag:(NSNumber*)value;

- (int16_t)primitiveTagValue;
- (void)setPrimitiveTagValue:(int16_t)value_;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;





- (GalleryImage*)primitiveBackgroundImage;
- (void)setPrimitiveBackgroundImage:(GalleryImage*)value;



- (REConfigurationDelegate*)primitiveConfigurationDelegate;
- (void)setPrimitiveConfigurationDelegate:(REConfigurationDelegate*)value;



- (NSMutableSet*)primitiveConstraints;
- (void)setPrimitiveConstraints:(NSMutableSet*)value;



- (RERemoteController*)primitiveController;
- (void)setPrimitiveController:(RERemoteController*)value;



- (NSMutableSet*)primitiveFirstItemConstraints;
- (void)setPrimitiveFirstItemConstraints:(NSMutableSet*)value;



- (RELayoutConfiguration*)primitiveLayoutConfiguration;
- (void)setPrimitiveLayoutConfiguration:(RELayoutConfiguration*)value;



- (RemoteElement*)primitiveParentElement;
- (void)setPrimitiveParentElement:(RemoteElement*)value;



- (NSMutableSet*)primitiveSecondItemConstraints;
- (void)setPrimitiveSecondItemConstraints:(NSMutableSet*)value;



- (NSMutableOrderedSet*)primitiveSubelements;
- (void)setPrimitiveSubelements:(NSMutableOrderedSet*)value;


@end
