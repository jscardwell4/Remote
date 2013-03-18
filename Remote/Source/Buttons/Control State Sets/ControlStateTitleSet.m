//
// ControlStateTitleSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ControlStateSet.h"
#import "ControlStateSet_Private.h"
#import "REButton.h"

@implementation ControlStateTitleSet

+ (ControlStateTitleSet *)titleSetForButton:(REButton *)button {
    return (ControlStateTitleSet *)[super controlStateSetForButton:button];
}

+ (ControlStateTitleSet *)titleSetInContext:(NSManagedObjectContext *)context
                                 withTitles:(NSDictionary *)titles {
    ControlStateTitleSet * titleSet = (ControlStateTitleSet *)[super controlStateSetInContext:context];

    if (titleSet) {
        [titles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
                    if ([key isKindOfClass:[NSNumber class]]) {
                    NSUInteger state = [key unsignedIntegerValue];
                    switch (state) {
                    case UIControlStateHighlighted :
                        titleSet.highlighted = obj; break;

                    case UIControlStateHighlighted | UIControlStateSelected :
                        titleSet.highlightedAndSelected = obj; break;

                    case UIControlStateHighlighted | UIControlStateDisabled :
                        titleSet.highlightedAndDisabled = obj; break;

                    case UIControlStateDisabled | UIControlStateSelected :
                        titleSet.disabledAndSelected = obj; break;

                    case UIControlStateSelected | UIControlStateHighlighted | UIControlStateDisabled :
                        titleSet.selectedHighlightedAndDisabled = obj; break;

                    case UIControlStateSelected :
                        titleSet.selected = obj; break;

                    case UIControlStateDisabled :
                        titleSet.disabled = obj; break;

                    case UIControlStateNormal :
                        titleSet.normal = obj; break;
                    } /* switch */
                    }
                }

        ];
    }

    return titleSet;
}

/*
 *
 * UIControlState bit combinations:
 * UIControlStateNormal: 0
 * UIControlStateHighlighted: 1
 * UIControlStateDisabled: 2
 * UIControlStateHighlighted|UIControlStateDisabled: 3
 * UIControlStateSelected: 4
 * UIControlStateHighlighted|UIControlStateSelected: 5
 * UIControlStateDisabled|UIControlStateSelected: 6
 * UIControlStateSelected|UIControlStateHighlighted|UIControlStateDisabled: 7
 * UIControlStateApplication: 16711680
 * UIControlStateReserved: 4278190080
 *
 */
- (NSAttributedString *)titleForState:(NSUInteger)state {
    NSAttributedString * title = (NSAttributedString *)[super objectForState:state];

    // Substitute if possible
    if (ValueIsNil(title) && state & UIControlStateDisabled) title = (NSAttributedString *)[super objectForState:UIControlStateDisabled];

    if (ValueIsNil(title) && state & UIControlStateHighlighted) title = (NSAttributedString *)[super objectForState:UIControlStateHighlighted];

    if (ValueIsNil(title) && state & UIControlStateSelected) title = (NSAttributedString *)[super objectForState:UIControlStateSelected];

    if (ValueIsNil(title)) title = (NSAttributedString *)[super objectForState:UIControlStateNormal];

    return NilSafeValue(title);
}

- (void)setTitle:(NSAttributedString *)title forState:(NSUInteger)state {
    [super setObject:title forState:state];
}

@end
