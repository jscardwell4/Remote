//
// ButtonBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int   ddLogLevel = DefaultDDLogLevel;

@implementation REButtonBuilder

+ (instancetype)builderWithContext:(NSManagedObjectContext *)context
{
    REButtonBuilder * builder = [super builderWithContext:context];
    builder->_macroBuilder = [MacroBuilder builderWithContext:context];
    return builder;
}

- (REActivityButton *)launchActivityButtonWithTitle:(NSString *)title activity:(NSUInteger)activity
{
    __block REActivityButton *  button = nil;
    [_buildContext performBlockAndWait:
     ^{
        NSMutableDictionary * attrHigh = [@{} mutableCopy];

        NSMutableDictionary * attr     = [self buttonTitleAttributesWithFontName:nil
                                                                        fontSize:0
                                                                     highlighted:attrHigh];

        NSAttributedString * attrTitle = [NSAttributedString  attributedStringWithString:title
                                                                              attributes:attr];

        NSAttributedString * attrTitleHigh = [NSAttributedString  attributedStringWithString:title
                                                                                  attributes:attrHigh];
        NSInteger switchIndex = -1;

        REMacroCommand * command     = [_macroBuilder activityMacroForActivity:activity
                                                               toInitiateState:YES
                                                                   switchIndex:&switchIndex];

        RECommand * longPressCommand = nil;

        if (switchIndex >= 0) longPressCommand = command[switchIndex];

        NSSet * configs = [_macroBuilder deviceConfigsForActivity:activity];

        button =
            MakeActivityOnButton(@"titleEdgeInsets"       : NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20)),
                                 @"shape"                 : @(REShapeRoundedRectangle),
                                 @"style"                 : @(REStyleApplyGloss | REStyleDrawBorder),
                                 @"key"                   :   $(@"activity%u", activity),
                                 @"titles"                : MakeTitleSet(@{ @"normal"      : attrTitle,
                                                                            @"highlighted" : attrTitleHigh }),
                                 @"deviceConfigurations"  : configs,
                                 @"command"               : command,
                                 @"longPressCommand"      : CollectionSafeValue(longPressCommand),
                                 @"displayName"           : [title stringByReplacingOccurrencesOfString:@"\n"
                                                                                         withString:@" "]);
     }];

    return button;
}


- (NSMutableDictionary *)buttonTitleAttributesWithFontName:(NSString *)fontName
                                                  fontSize:(CGFloat)fontSize
                                               highlighted:(NSMutableDictionary *)highlighted
{
    static NSMutableParagraphStyle * paragraphStyle  = nil;
    static NSDictionary            * titleAttributes = nil;
    static dispatch_once_t           onceToken;

    dispatch_once(&onceToken, ^{
        paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        titleAttributes = @{
            NSFontAttributeName            : [UIFont fontWithName:kDefaultFontName size:20.0],
            NSKernAttributeName            : NullObject,
            NSLigatureAttributeName        : @1,
            NSForegroundColorAttributeName : defaultTitleColor(),
            NSStrokeWidthAttributeName     : @(-2.0),
            NSStrokeColorAttributeName     : [defaultTitleColor() colorWithAlphaComponent:0.5],
            NSParagraphStyleAttributeName  : paragraphStyle
        };
    });

    NSMutableDictionary * buttonTitleAttributes = [titleAttributes mutableCopy];

    if (fontName) buttonTitleAttributes[NSFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];

    if (highlighted)
    {
        [highlighted addEntriesFromDictionary:buttonTitleAttributes];
        highlighted[NSStrokeColorAttributeName] = [defaultTitleHighlightColor() colorWithAlphaComponent:0.5],
        highlighted[NSForegroundColorAttributeName] = defaultTitleHighlightColor();
    }

    return buttonTitleAttributes;
}

@end
