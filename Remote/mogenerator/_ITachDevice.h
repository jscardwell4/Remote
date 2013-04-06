// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ITachDevice.h instead.

#import <CoreData/CoreData.h>
#import "NetworkDevice.h"



extern const struct ITachDeviceAttributes {
	 NSString *configURL;
	 NSString *make;
	 NSString *model;
	 NSString *pcb_pn;
	 NSString *pkg_level;
	 NSString *revision;
	 NSString *sdkClass;
	 NSString *status;
} ITachDeviceAttributes;


























@interface ITachDeviceID : NetworkDeviceID {}
@end

@interface _ITachDevice : NetworkDevice {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ITachDeviceID*)objectID;





@property (nonatomic, retain) NSString* configURL;



//- (BOOL)validateConfigURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* make;



//- (BOOL)validateMake:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* model;



//- (BOOL)validateModel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* pcb_pn;



//- (BOOL)validatePcb_pn:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* pkg_level;



//- (BOOL)validatePkg_level:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* revision;



//- (BOOL)validateRevision:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* sdkClass;



//- (BOOL)validateSdkClass:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* status;



//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;





+ (NSArray*)fetchAlliTachDevices:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchAlliTachDevices:(NSManagedObjectContext*)moc_ error:(NSError**)error_;




@end



@interface _ITachDevice (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveConfigURL;
- (void)setPrimitiveConfigURL:(NSString*)value;




- (NSString*)primitiveMake;
- (void)setPrimitiveMake:(NSString*)value;




- (NSString*)primitiveModel;
- (void)setPrimitiveModel:(NSString*)value;




- (NSString*)primitivePcb_pn;
- (void)setPrimitivePcb_pn:(NSString*)value;




- (NSString*)primitivePkg_level;
- (void)setPrimitivePkg_level:(NSString*)value;




- (NSString*)primitiveRevision;
- (void)setPrimitiveRevision:(NSString*)value;




- (NSString*)primitiveSdkClass;
- (void)setPrimitiveSdkClass:(NSString*)value;




- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;




@end
