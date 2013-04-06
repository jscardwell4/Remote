// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to REConfigurationDelegate.h instead.

#import <CoreData/CoreData.h>



extern const struct REConfigurationDelegateAttributes {
	 NSString *configurations;
} REConfigurationDelegateAttributes;



extern const struct REConfigurationDelegateRelationships {
	 NSString *delegate;
	 NSString *remoteElement;
	 NSString *subscribers;
} REConfigurationDelegateRelationships;






@class REConfigurationDelegate;
@class RemoteElement;
@class REConfigurationDelegate;



@class NSObject;

@interface REConfigurationDelegateID : NSManagedObjectID {}
@end

@interface _REConfigurationDelegate : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (REConfigurationDelegateID*)objectID;





@property (nonatomic, retain) id configurations;



//- (BOOL)validateConfigurations:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) REConfigurationDelegate *delegate;

//- (BOOL)validateDelegate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) RemoteElement *remoteElement;

//- (BOOL)validateRemoteElement:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet *subscribers;

- (NSMutableSet*)subscribersSet;





@end


@interface _REConfigurationDelegate (SubscribersCoreDataGeneratedAccessors)
- (void)addSubscribers:(NSSet*)value_;
- (void)removeSubscribers:(NSSet*)value_;
- (void)addSubscribersObject:(REConfigurationDelegate*)value_;
- (void)removeSubscribersObject:(REConfigurationDelegate*)value_;
@end


@interface _REConfigurationDelegate (CoreDataGeneratedPrimitiveAccessors)


- (id)primitiveConfigurations;
- (void)setPrimitiveConfigurations:(id)value;





- (REConfigurationDelegate*)primitiveDelegate;
- (void)setPrimitiveDelegate:(REConfigurationDelegate*)value;



- (RemoteElement*)primitiveRemoteElement;
- (void)setPrimitiveRemoteElement:(RemoteElement*)value;



- (NSMutableSet*)primitiveSubscribers;
- (void)setPrimitiveSubscribers:(NSMutableSet*)value;


@end
