// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REButton.h instead.

#import <CoreData/CoreData.h>
#import "RemoteElement.h"



extern const struct REButtonAttributes {
	 NSString *contentEdgeInsets;
	 NSString *imageEdgeInsets;
	 NSString *titleEdgeInsets;
} REButtonAttributes;



extern const struct REButtonRelationships {
	 NSString *backgroundColors;
	 NSString *command;
	 NSString *icons;
	 NSString *images;
	 NSString *longPressCommand;
	 NSString *titles;
} REButtonRelationships;






@class ControlStateColorSet;
@class Command;
@class ControlStateIconImageSet;
@class ControlStateButtonImageSet;
@class Command;
@class ControlStateTitleSet;



@class NSObject;


@class NSObject;


@class NSObject;

@interface REButtonID : RemoteElementID {}
@end

@interface _REButton : RemoteElement {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REButtonID*)objectID;





@property (nonatomic, retain) id contentEdgeInsets;



//- (BOOL)validateContentEdgeInsets:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id imageEdgeInsets;



//- (BOOL)validateImageEdgeInsets:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) id titleEdgeInsets;



//- (BOOL)validateTitleEdgeInsets:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) ControlStateColorSet *backgroundColors;

//- (BOOL)validateBackgroundColors:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Command *command;

//- (BOOL)validateCommand:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ControlStateIconImageSet *icons;

//- (BOOL)validateIcons:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ControlStateButtonImageSet *images;

//- (BOOL)validateImages:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Command *longPressCommand;

//- (BOOL)validateLongPressCommand:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) ControlStateTitleSet *titles;

//- (BOOL)validateTitles:(id*)value_ error:(NSError**)error_;





@end



@interface _REButton (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveContentEdgeInsets;
- (void)setPrimitiveContentEdgeInsets:(id)value;




- (id)primitiveImageEdgeInsets;
- (void)setPrimitiveImageEdgeInsets:(id)value;




- (id)primitiveTitleEdgeInsets;
- (void)setPrimitiveTitleEdgeInsets:(id)value;





- (ControlStateColorSet*)primitiveBackgroundColors;
- (void)setPrimitiveBackgroundColors:(ControlStateColorSet*)value;



- (Command*)primitiveCommand;
- (void)setPrimitiveCommand:(Command*)value;



- (ControlStateIconImageSet*)primitiveIcons;
- (void)setPrimitiveIcons:(ControlStateIconImageSet*)value;



- (ControlStateButtonImageSet*)primitiveImages;
- (void)setPrimitiveImages:(ControlStateButtonImageSet*)value;



- (Command*)primitiveLongPressCommand;
- (void)setPrimitiveLongPressCommand:(Command*)value;



- (ControlStateTitleSet*)primitiveTitles;
- (void)setPrimitiveTitles:(ControlStateTitleSet*)value;


@end
