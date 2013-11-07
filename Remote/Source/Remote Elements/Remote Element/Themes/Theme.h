//
//  RETheme.h
//  Remote
//
//  Created by Jason Cardwell on 4/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "NamedModelObject.h"
#import "RETypedefs.h"


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme
////////////////////////////////////////////////////////////////////////////////


@interface Theme : NamedModelObject

@property (nonatomic, strong, readonly) NSSet * elements;

+ (instancetype)themeWithName:(NSString *)name;
+ (instancetype)themeWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (BOOL)isValidThemeName:(NSString *)name;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Applying Themes
////////////////////////////////////////////////////////////////////////////////


@class RemoteElement;

@interface Theme (ApplyingThemes)

- (void)applyThemeToElement:(RemoteElement *)element;
- (void)applyThemeToElements:(NSSet *)elements;
- (NSDictionary *)themedAttributesFromAttributes:(NSDictionary *)attributes
                              templateAttributes:(NSDictionary *)templateAttributes
                                           flags:(REThemeOverrideFlags)flags;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Builtin Theme
////////////////////////////////////////////////////////////////////////////////


MSEXTERN_STRING REThemeNightshadeName;
MSEXTERN_STRING REThemePowerBlueName;

@interface BuiltinTheme : Theme

//+ (BOOL)isValidThemeName:(NSString *)name;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Theme
////////////////////////////////////////////////////////////////////////////////


@interface CustomTheme : Theme @end

