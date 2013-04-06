//
// BankObject.h
// Remote
//
// Created by Jason Cardwell on 7/7/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "BOTypedefs.h"
#import "RETypedefs.h"

@class BOComponentDevice, BOIRCodeset, BankObjectGroup, BOIRCodeset, RECommand, BOImageGroup, BankObjectPreview, RemoteElement;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Bank Object
////////////////////////////////////////////////////////////////////////////////

@interface BankObject : NSManagedObject

+ (instancetype)bankObjectInContext:(NSManagedObjectContext *)context;
+ (instancetype)bankObjectWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * category;
@property (nonatomic, strong) NSString * exportFileFormat;
@property (nonatomic) BOOL               factoryObject;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - IR Code
////////////////////////////////////////////////////////////////////////////////

@interface BOIRCode : BankObject

+ (instancetype)codeForDevice:(BOComponentDevice *)device;

+ (instancetype)codeFromProntoHex:(NSString *)hex context:(NSManagedObjectContext *)context;

+ (instancetype)codeFromProntoHex:(NSString *)hex device:(BOComponentDevice *)device;

- (NSString *)globalCacheFromProntoHex;

@property (nonatomic, assign) int64_t             frequency;
@property (nonatomic, assign) int16_t             offset;
@property (nonatomic, assign) int16_t             repeatCount;
@property (nonatomic, strong) NSString          * onOffPattern;
@property (nonatomic, strong) NSString          * alternateName;
@property (nonatomic, strong) NSString          * prontoHex;
@property (nonatomic, strong) BOComponentDevice * device;
@property (nonatomic, assign) BOOL                setsDeviceInput;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Factory IR Code
////////////////////////////////////////////////////////////////////////////////

@interface BOFactoryIRCode : BOIRCode

+ (BOIRCode *)codeForCodeset:(BOIRCodeset *)set;

@property (nonatomic, strong) BOIRCodeset * codeset;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - User IR Code
////////////////////////////////////////////////////////////////////////////////
@interface BOUserIRCode : BOIRCode @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Component Device
////////////////////////////////////////////////////////////////////////////////

@interface BOComponentDevice : BankObject

+ (instancetype)fetchDeviceWithName:(NSString *)deviceName context:(NSManagedObjectContext *)context;

- (BOIRCode *)objectForKeyedSubscript:(NSString *)name;

- (void)powerOn:(RECommandCompletionHandler)completion;

- (void)powerOff:(RECommandCompletionHandler)completion;

@property (nonatomic, strong) NSString     * name;
@property (nonatomic, assign) BODevicePort   port;
@property (nonatomic, strong) NSSet        * codes;
@property (nonatomic, assign) BOPowerState   power;
@property (nonatomic, assign) BOOL           alwaysOn;
@property (nonatomic, assign) BOOL           inputPowersOn;
@property (nonatomic, strong) RECommand    * offCommand;
@property (nonatomic, strong) RECommand    * onCommand;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Image
////////////////////////////////////////////////////////////////////////////////

@interface BOImage : BankObject <MSCaching>

+ (instancetype)imageWithFileName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (instancetype)imageWithFileName:(NSString *)name group:(BOImageGroup *)group;
- (UIImage *)imageWithColor:(UIColor *)color;
+ (instancetype)fetchImageWithTag:(NSInteger)tag context:(NSManagedObjectContext *)context;
- (void)flushThumbnail;

@property (nonatomic, weak,   readonly) NSString        * fileName;
@property (nonatomic, strong)           NSString        * name;
@property (nonatomic, strong)           BankObjectGroup * group;
@property (nonatomic, weak,   readonly) UIImage         * image;
@property (nonatomic, strong, readonly) UIImage         * thumbnail;
@property (nonatomic, assign)           CGSize            thumbnailSize;
@property (nonatomic, assign)           int16_t           tag;
@property (nonatomic, strong)           NSNumber        * leftCap;
@property (nonatomic, strong)           NSNumber        * topCap;
@property (nonatomic, strong, readonly) UIImage         * stretchableImage;
@property (nonatomic, assign, readonly) CGSize            size;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Icon Image
////////////////////////////////////////////////////////////////////////////////

@interface BOIconImage : BOImage

@property (nonatomic, strong)           NSString  * iconSet;
@property (nonatomic, strong)           NSString  * subcategory;
@property (nonatomic, strong, readonly) UIImage   * preview;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Background Image
////////////////////////////////////////////////////////////////////////////////

@interface BOBackgroundImage : BOImage @end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Button Image
////////////////////////////////////////////////////////////////////////////////

@interface BOButtonImage : BOImage

@property (nonatomic, assign) BOButtonImageState state;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Manufacturer
////////////////////////////////////////////////////////////////////////////////

@interface BOManufacturer : BankObject

+ (instancetype)fetchManufacturerWithName:(NSString *)name
                                  context:(NSManagedObjectContext *)context;

+ (instancetype)manufacturerWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@property (nonatomic, strong) NSSet * codesets;

@end

@interface BOManufacturer (CoreDataGeneratedAccessors)

- (void)addCodesetsObject:(BOIRCodeset *)codeset;
- (void)removeCodesetsObject:(BOIRCodeset *)codeset;
- (void)addCodesets:(NSSet *)codesets;
- (void)removeCodesets:(NSSet *)codesets;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Presets
////////////////////////////////////////////////////////////////////////////////
@interface BOPreset : BankObject
+ (instancetype)presetWithElement:(RemoteElement *)element;
@property (nonatomic, strong) BankObjectPreview * preview;
@property (nonatomic, strong) RemoteElement     * element;
@end

@interface BORemotePreset : BOPreset @end

@interface BOButtonGroupPreset : BOPreset @end

@interface BOButtonPreset : BOPreset @end

