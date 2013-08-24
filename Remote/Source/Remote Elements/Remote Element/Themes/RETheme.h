//
//  RETheme.h
//  Remote
//
//  Created by Jason Cardwell on 4/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "MSModelObject.h"
#import "RETypedefs.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme
////////////////////////////////////////////////////////////////////////////////


@interface RETheme : MSModelObject <MSNamedModelObject>

@property (nonatomic, copy,   readonly) NSString * name;
@property (nonatomic, strong, readonly) NSSet    * elements;

+ (instancetype)themeWithName:(NSString *)name;
+ (instancetype)themeWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (BOOL)isValidThemeName:(NSString *)name;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Applying Themes
////////////////////////////////////////////////////////////////////////////////


@class RemoteElement;

@interface RETheme (ApplyingThemes)

- (void)applyThemeToElement:(RemoteElement *)element;
- (void)applyThemeToElements:(NSSet *)elements;
- (NSDictionary *)themedAttributesFromAttributes:(NSDictionary *)attributes
                              templateAttributes:(NSDictionary *)templateAttributes
                                           flags:(REThemeFlags)flags;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Builtin Theme
////////////////////////////////////////////////////////////////////////////////


MSKIT_EXTERN_STRING REThemeNightshadeName;
MSKIT_EXTERN_STRING REThemePowerBlueName;

@interface REBuiltinTheme : RETheme

//+ (BOOL)isValidThemeName:(NSString *)name;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Theme
////////////////////////////////////////////////////////////////////////////////


@interface RECustomTheme : RETheme @end

