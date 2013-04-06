// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REConstraint.h instead.

#import <CoreData/CoreData.h>



extern const struct REConstraintAttributes {
	 NSString *constant;
	 NSString *firstAttribute;
	 NSString *key;
	 NSString *multiplier;
	 NSString *priority;
	 NSString *relation;
	 NSString *secondAttribute;
	 NSString *tag;
	 NSString *uuid;
} REConstraintAttributes;



extern const struct REConstraintRelationships {
	 NSString *firstItem;
	 NSString *owner;
	 NSString *secondItem;
} REConstraintRelationships;






@class RemoteElement;
@class RemoteElement;
@class RemoteElement;




















@interface REConstraintID : NSManagedObjectID {}
@end

@interface _REConstraint : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REConstraintID*)objectID;





@property (nonatomic, retain) NSNumber* constant;




@property (atomic) float constantValue;
- (float)constantValue;
- (void)setConstantValue:(float)value_;


//- (BOOL)validateConstant:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* firstAttribute;




@property (atomic) int16_t firstAttributeValue;
- (int16_t)firstAttributeValue;
- (void)setFirstAttributeValue:(int16_t)value_;


//- (BOOL)validateFirstAttribute:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* multiplier;




@property (atomic) float multiplierValue;
- (float)multiplierValue;
- (void)setMultiplierValue:(float)value_;


//- (BOOL)validateMultiplier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* priority;




@property (atomic) float priorityValue;
- (float)priorityValue;
- (void)setPriorityValue:(float)value_;


//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* relation;




@property (atomic) int16_t relationValue;
- (int16_t)relationValue;
- (void)setRelationValue:(int16_t)value_;


//- (BOOL)validateRelation:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* secondAttribute;




@property (atomic) int16_t secondAttributeValue;
- (int16_t)secondAttributeValue;
- (void)setSecondAttributeValue:(int16_t)value_;


//- (BOOL)validateSecondAttribute:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSNumber* tag;




@property (atomic) int16_t tagValue;
- (int16_t)tagValue;
- (void)setTagValue:(int16_t)value_;


//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) RemoteElement *firstItem;

//- (BOOL)validateFirstItem:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RemoteElement *owner;

//- (BOOL)validateOwner:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RemoteElement *secondItem;

//- (BOOL)validateSecondItem:(id*)value_ error:(NSError**)error_;





@end



@interface _REConstraint (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveConstant;
- (void)setPrimitiveConstant:(NSNumber*)value;

- (float)primitiveConstantValue;
- (void)setPrimitiveConstantValue:(float)value_;




- (NSNumber*)primitiveFirstAttribute;
- (void)setPrimitiveFirstAttribute:(NSNumber*)value;

- (int16_t)primitiveFirstAttributeValue;
- (void)setPrimitiveFirstAttributeValue:(int16_t)value_;




- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSNumber*)primitiveMultiplier;
- (void)setPrimitiveMultiplier:(NSNumber*)value;

- (float)primitiveMultiplierValue;
- (void)setPrimitiveMultiplierValue:(float)value_;




- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (float)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(float)value_;




- (NSNumber*)primitiveRelation;
- (void)setPrimitiveRelation:(NSNumber*)value;

- (int16_t)primitiveRelationValue;
- (void)setPrimitiveRelationValue:(int16_t)value_;




- (NSNumber*)primitiveSecondAttribute;
- (void)setPrimitiveSecondAttribute:(NSNumber*)value;

- (int16_t)primitiveSecondAttributeValue;
- (void)setPrimitiveSecondAttributeValue:(int16_t)value_;




- (NSNumber*)primitiveTag;
- (void)setPrimitiveTag:(NSNumber*)value;

- (int16_t)primitiveTagValue;
- (void)setPrimitiveTagValue:(int16_t)value_;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;





- (RemoteElement*)primitiveFirstItem;
- (void)setPrimitiveFirstItem:(RemoteElement*)value;



- (RemoteElement*)primitiveOwner;
- (void)setPrimitiveOwner:(RemoteElement*)value;



- (RemoteElement*)primitiveSecondItem;
- (void)setPrimitiveSecondItem:(RemoteElement*)value;


@end
