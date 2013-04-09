//
//  RETheme+ApplyingThemes.m
//  Remote
//
//  Created by Jason Cardwell on 4/9/13.
//  Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RETheme_Private.h"
#import "RemoteElement.h"

@implementation RETheme (ApplyingThemes)

- (NSAttributedString *)themedStringFromString:(NSAttributedString *)string forState:(NSUInteger)state
{
    if (!string) return nil;
    
    NSDictionary * attributes = [self.titleStyles[state] attributesAtIndex:0 effectiveRange:NULL];
    NSMutableAttributedString * themedString = [string mutableCopy];
    [themedString applyAttributes:attributes];
    return themedString;
}

- (void)applyThemeToElement:(RemoteElement *)element
{
    switch (element.baseType)
    {
        case RETypeRemote:
            [self applyThemeToRemote:(RERemote *)element];
            break;

        case RETypeButtonGroup:
            [self applyThemeToButtonGroup:(REButtonGroup *)element];
            break;

        case RETypeButton:
            [self applyThemeToButton:(REButton *)element];
            break;

        default:
            assert(NO);
            break;
    }
}

- (void)applyThemeToRemote:(RERemote *)remote
{
    remote.backgroundColor = self.backgroundColors[0];
}

- (void)applyThemeToButtonGroup:(REButtonGroup *)buttonGroup
{
    buttonGroup.backgroundColor = self.backgroundColors[0];
    buttonGroup.label =[self themedStringFromString:buttonGroup.label forState:UIControlStateNormal];
}

- (void)applyThemeToButton:(REButton *)button
{
    button.style = REStyleApplyGloss|REStyleGlossStyle2;
    [button.backgroundColors copyObjectsFromSet:self.backgroundColors];
    [button.icons.iconColors copyObjectsFromSet:self.iconColors];
    for (int i = 0; i < 8; i++)
        button.titles[i] = [self themedStringFromString:button.titles[i] forState:i];
}

@end
