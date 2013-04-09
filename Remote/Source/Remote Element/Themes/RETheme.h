//
//  RETheme.h
//  Remote
//
//  Created by Jason Cardwell on 4/8/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Abstract Theme
////////////////////////////////////////////////////////////////////////////////
@interface RETheme : NSManagedObject

@property (nonatomic, copy, readonly) NSString * name;

+ (instancetype)themeWithName:(NSString *)name;
+ (instancetype)themeWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@end

@class RemoteElement;
@interface RETheme (ApplyingThemes)

- (void)applyThemeToElement:(RemoteElement *)element;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Builtin Themes
////////////////////////////////////////////////////////////////////////////////
MSKIT_EXTERN_STRING REThemeNightshadeName;
MSKIT_EXTERN_STRING REThemePowerBlueName;

@interface REBuiltinTheme : RETheme

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Custom Themes
////////////////////////////////////////////////////////////////////////////////
@interface RECustomTheme : RETheme

@end