//
// ButtonBuilder.h
// iPhonto
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "Button.h"

@class   ActivityButton, Command;

@interface ButtonBuilder : NSObject

+ (ButtonBuilder *)buttonBuilderWithContext:(NSManagedObjectContext *)context;

- (BOOL)generateButtonPreviews:(BOOL)replaceExisting;

- (ActivityButton *)launchActivityButtonWithTitle:(NSString *)title activity:(NSUInteger)activity;

- (NSMutableDictionary *)buttonTitleAttributesWithFontName:(NSString *)fontName
                                                  fontSize:(CGFloat)fontSize
                                               highlighted:(NSMutableDictionary *)highlighted;

- (Button *)buttonWithDefaultStyle:(ButtonStyleDefault)style
                           context:(NSManagedObjectContext *)context;

@property (nonatomic, weak) NSManagedObjectContext * buildContext;

@end
