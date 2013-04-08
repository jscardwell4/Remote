//
// ButtonBuilder.m
// Remote
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

static const int ddLogLevel = LOG_LEVEL_WARN;
static const int msLogContext = DEFAULT_LOG_CONTEXT;
#pragma unused(ddLogLevel, msLogContext)

@implementation REButtonBuilder

+ (REActivityButton *)launchActivityButtonWithTitle:(NSString *)title activity:(NSUInteger)activity
{
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSMutableDictionary * attrH = [@{} mutableCopy];

    NSMutableDictionary * attrN = [self buttonTitleAttributesWithFontName:nil
                                                                 fontSize:0
                                                              highlighted:attrH];

    NSAttributedString * titleN = [NSAttributedString attributedStringWithString:title
                                                                      attributes:attrN];

    NSAttributedString * titleH = [NSAttributedString attributedStringWithString:title
                                                                      attributes:attrH];
    NSInteger   switchIndex = -1;

    REMacroCommand * command = [REMacroBuilder    activityMacroForActivity:activity
                                                           toInitiateState:YES
                                                               switchIndex:&switchIndex];
    assert(command);

    RECommand * longPressCommand = nil;

    if (switchIndex >= 0) longPressCommand = command[switchIndex];

    NSSet * configs = [REMacroBuilder deviceConfigsForActivity:activity];

    NSValue                * titleEdgeInsets = NSValueWithUIEdgeInsets(UIEdgeInsetsMake(20, 20, 20, 20));
    REControlStateTitleSet * titleSet        = MakeTitleSet(@{ @"normal"      : titleN,
                                                               @"highlighted": titleH });
    NSString * displayName = [title stringByRemovingLineBreaks];
    NSString * key         = $(@"activity%u", activity);
    NSNumber * shape       = @(REShapeRoundedRectangle);
    NSNumber * style       = @(REStyleApplyGloss | REStyleDrawBorder);

    REActivityButton * button =
        MakeActivityOnButton(@"titleEdgeInsets"       : titleEdgeInsets,
                             @"shape"                 : shape,
                             @"style"                 : style,
                             @"key"                   : key,
                             @"titles"                : titleSet,
                             @"deviceConfigurations"  : configs,
                             @"command"               : command,
                             @"longPressCommand"      : CollectionSafeValue(longPressCommand),
                             @"displayName"           : displayName);
    return button;
}



+ (NSMutableDictionary *)buttonTitleAttributesWithFontName:(NSString *)fontName
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

    if (fontName)
        buttonTitleAttributes[NSFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];

    if (highlighted)
    {
        [highlighted addEntriesFromDictionary:buttonTitleAttributes];
        highlighted[NSStrokeColorAttributeName] = [defaultTitleHighlightColor() colorWithAlphaComponent:0.5],
        highlighted[NSForegroundColorAttributeName] = defaultTitleHighlightColor();
    }

    return buttonTitleAttributes;
}

@end
