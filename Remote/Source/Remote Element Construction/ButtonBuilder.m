//
// ButtonBuilder.m
// iPhonto
//
// Created by Jason Cardwell on 10/6/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "RemoteConstruction.h"

@interface ButtonBuilder ()
@property (nonatomic, strong) MacroBuilder * macroBuilder;
@end

static const int   ddLogLevel = DefaultDDLogLevel;

@implementation ButtonBuilder

+ (ButtonBuilder *)buttonBuilderWithContext:(NSManagedObjectContext *)context {
    ButtonBuilder * bb = [self new];

    bb.buildContext = context;

    return bb;
}

- (Button *)buttonWithDefaultStyle:(ButtonStyleDefault)style context:(NSManagedObjectContext *)context {
    Button              * button      = [RemoteElement remoteElementOfType:(RemoteElementType)ButtonTypeDefault context:context];
    NSDictionary        * identifiers = NSDictionaryOfVariableBindingsToIdentifiers(button);
    NSMutableDictionary * attributes  = [@{}
                                         mutableCopy];

    switch (style) {
        case ButtonStyleDefault1 :
            attributes[@"shape"]       = @(ButtonShapeRoundedRectangle);
            attributes[@"style"]       = @(ButtonStyleDrawBorder | ButtonStyleApplyGloss);
            attributes[@"constraints"] = [@"button.width ≥ 100\nbutton.height = button.width" stringByReplacingOccurrencesWithDictionary : identifiers];
            break;

        case ButtonStyleDefault2 :
            attributes[@"shape"]       = @(ButtonShapeRectangle);
            attributes[@"style"]       = @(ButtonStyleDrawBorder | ButtonStyleApplyGloss);
            attributes[@"constraints"] = [@"button.width ≥ 200\nbutton.height = button.width * 0.5" stringByReplacingOccurrencesWithDictionary : identifiers];
            break;

        case ButtonStyleDefault3 :
            attributes[@"shape"]       = @(ButtonShapeOval);
            attributes[@"style"]       = @(ButtonStyleDrawBorder | ButtonStyleApplyGloss);
            attributes[@"constraints"] = [@"button.width ≥ 44\nbutton.height = button.width" stringByReplacingOccurrencesWithDictionary : identifiers];
            break;

        case ButtonStyleDefault4 :
            attributes[@"shape"]       = @(ButtonShapeOval);
            attributes[@"style"]       = @(ButtonStyleDrawBorder | ButtonStyleApplyGloss | ButtonStyleStretchable);
            attributes[@"constraints"] = [@"button.width ≥ 100\nbutton.height = button.width * 0.6875" stringByReplacingOccurrencesWithDictionary : identifiers];
            break;

        case ButtonStyleDefault5 :
            //
            break;
    }  /* switch */

    [button setValuesForKeysWithDictionary:attributes];
// [button setAttributesFromDictionary:attributes];

    return button;
}

- (BOOL)generateButtonPreviews:(BOOL)replaceExisting {
    if (replaceExisting) {
        [_buildContext performBlockAndWait:^{
                           NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"GalleryPreview"];

                           NSError * error = nil;
                           NSArray * fetchedObjects = [self.buildContext
                                        executeFetchRequest:fetchRequest
                                                      error:&error];

                           if (fetchedObjects == nil)
                           DDLogDebug(@"%@\n\tno objects to delete", ClassTagSelectorString);
            else {
                           for (GalleryPreview * preview in fetchedObjects) {
                           [self.buildContext
                            deleteObject:preview];
                           }

                           [DataManager saveMainContext];
                           }
                       }

        ];
    }

    GalleryButtonPreview * buttonPreview = [GalleryButtonPreview buttonPreviewWithName:@"ButtonStyleDefault1" context:self.buildContext];
    Button               * button        = [self buttonWithDefaultStyle:ButtonStyleDefault1 context:self.buildContext];
    ButtonView           * buttonView    = (ButtonView *)[ButtonView remoteElementViewWithElement:button];
    UIImage              * previewImage  = [UIImage captureImageOfView:buttonView];

    [self.buildContext deleteObject:button];
    buttonPreview.image = previewImage;

    [DataManager saveMainContext];

    buttonPreview = [GalleryButtonPreview buttonPreviewWithName:@"ButtonStyleDefault2" context:self.buildContext];
    button        = [self buttonWithDefaultStyle:ButtonStyleDefault2 context:self.buildContext];
    buttonView    = (ButtonView *)[ButtonView remoteElementViewWithElement:button];
    previewImage  = [UIImage captureImageOfView:buttonView];
    [self.buildContext deleteObject:button];
    buttonPreview.image = previewImage;

    [DataManager saveMainContext];

    buttonPreview = [GalleryButtonPreview buttonPreviewWithName:@"ButtonStyleDefault3" context:self.buildContext];
    button        = [self buttonWithDefaultStyle:ButtonStyleDefault3 context:self.buildContext];
    buttonView    = (ButtonView *)[ButtonView remoteElementViewWithElement:button];
    previewImage  = [UIImage captureImageOfView:buttonView];
    [self.buildContext deleteObject:button];
    buttonPreview.image = previewImage;

    [DataManager saveMainContext];

    buttonPreview = [GalleryButtonPreview buttonPreviewWithName:@"ButtonStyleDefault4" context:self.buildContext];
    button        = [self buttonWithDefaultStyle:ButtonStyleDefault4 context:self.buildContext];
    buttonView    = (ButtonView *)[ButtonView remoteElementViewWithElement:button];
    previewImage  = [UIImage captureImageOfView:buttonView];
    [self.buildContext deleteObject:button];
    buttonPreview.image = previewImage;

    return [DataManager saveMainContext];
}  /* generateButtonPreviews */

- (ActivityButton *)launchActivityButtonWithTitle:(NSString *)title activity:(NSUInteger)activity {
    NSMutableDictionary * titleHighlightedAttributes = [@{}
                                                        mutableCopy];
    NSMutableDictionary * titleAttributes            = [self buttonTitleAttributesWithFontName:nil fontSize:0 highlighted:titleHighlightedAttributes];
    NSAttributedString  * attributedTitle            = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
    NSAttributedString  * attributedTitleHighlighted = [[NSAttributedString alloc] initWithString:title attributes:titleHighlightedAttributes];
    NSInteger             switchIndex                = -1;
    MacroCommand        * command                    = [self.macroBuilder activityMacroForActivity:activity toInitiateState:YES switchIndex:&switchIndex];
    Command             * longPressCommand           = nil;

    if (switchIndex >= 0) longPressCommand = command[switchIndex];

    ActivityButton * button = (ActivityButton *)MakeActivityOnButton(
        @"titleEdgeInsets" : InsetsValue(UIEdgeInsetsMake(20, 20, 20, 20)),
        @"shape" : @(ButtonShapeRoundedRectangle),
        @"style" : @(ButtonStyleApplyGloss | ButtonStyleDrawBorder),
        @"key" :[NSString stringWithFormat:@"activity%u", activity],
        @"titles" : MakeTitleSet(@{@0 : attributedTitle, @1 : attributedTitleHighlighted}
                                 ),
        @"deviceConfigurations" :[self.macroBuilder deviceConfigsForActivity:activity],
        @"command" : command,
        @"longPressCommand" : CollectionSafeValue(longPressCommand),
        @"displayName" :[title stringByReplacingOccurrencesOfString:@"\n" withString:@" "]);

    return button;
}

- (NSMutableDictionary *)buttonTitleAttributesWithFontName:(NSString *)fontName
                                                  fontSize:(CGFloat)fontSize
                                               highlighted:(NSMutableDictionary *)highlighted {
    static NSMutableParagraphStyle * paragraphStyle  = nil;
    static NSDictionary            * titleAttributes = nil;
    static dispatch_once_t           onceToken;

    dispatch_once(&onceToken, ^{
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        titleAttributes = @{
            NSFontAttributeName : [UIFont fontWithName:kDefaultFontName size:20.0],
            NSKernAttributeName : [NSNull null],
            NSLigatureAttributeName : @1,
            NSForegroundColorAttributeName : defaultTitleColor(),
            NSStrokeWidthAttributeName : @(-2.0),
            NSStrokeColorAttributeName : [defaultTitleColor() colorWithAlphaComponent:0.5],
            NSParagraphStyleAttributeName : paragraphStyle
        };
    }

                  );

    NSMutableDictionary * buttonTitleAttributes = [titleAttributes mutableCopy];

    if (fontName) buttonTitleAttributes[NSFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];

    if (highlighted) {
        [highlighted addEntriesFromDictionary:buttonTitleAttributes];
NSStrokeColorAttributeName:[defaultTitleHighlightColor() colorWithAlphaComponent:0.5],
        highlighted[NSForegroundColorAttributeName] = defaultTitleHighlightColor();
    }

    return buttonTitleAttributes;
}

- (MacroBuilder *)macroBuilder {
    if (!_macroBuilder) self.macroBuilder = [MacroBuilder macroBuilderWithContext:self.buildContext];

    return _macroBuilder;
}

@end
