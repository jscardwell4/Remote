//
// ButtonBuilder.h
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "REButton.h"

@class   REActivityButton, Command;

@interface ButtonBuilder : NSObject

+ (ButtonBuilder *)buttonBuilderWithContext:(NSManagedObjectContext *)context;

- (BOOL)generateButtonPreviews:(BOOL)replaceExisting;

- (REActivityButton *)launchActivityButtonWithTitle:(NSString *)title activity:(NSUInteger)activity;

- (NSMutableDictionary *)buttonTitleAttributesWithFontName:(NSString *)fontName
                                                  fontSize:(CGFloat)fontSize
                                               highlighted:(NSMutableDictionary *)highlighted;

- (REButton *)buttonWithDefaultStyle:(REButtonStyleDefault)style
                           context:(NSManagedObjectContext *)context;

@property (nonatomic, weak) NSManagedObjectContext * buildContext;

@end
