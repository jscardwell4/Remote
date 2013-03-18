//
// ControlStateSet.m
// Remote
//
// Created by Jason Cardwell on 3/26/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//
#import "ControlStateSet.h"
#import "ControlStateSet_Private.h"
#import "REButton.h"

static int   ddLogLevel = DefaultDDLogLevel;

#pragma unused(ddLogLevel)

#pragma mark - ControlStateSet

@implementation ControlStateSet

@dynamic disabled;
@dynamic disabledAndSelected;
@dynamic highlighted;
@dynamic highlightedAndDisabled;
@dynamic highlightedAndSelected;
@dynamic normal;
@dynamic selected;
@dynamic selectedHighlightedAndDisabled;
@dynamic button;

+ (ControlStateSet *)controlStateSetInContext:(NSManagedObjectContext *)context {
    if (!context) return nil;

    ControlStateSet * stateSet =
        [NSEntityDescription insertNewObjectForEntityForName:ClassString([self class])
                                      inManagedObjectContext:context];

    return stateSet;
}

+ (ControlStateSet *)controlStateSetForButton:(REButton *)button {
    if (!button) return nil;

    ControlStateSet * stateSet =
        [NSEntityDescription insertNewObjectForEntityForName:ClassString([self class])
                                      inManagedObjectContext:button.managedObjectContext];

    stateSet.button = button;

    return stateSet;
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
- (id)objectForState:(NSUInteger)state {
    id   object = nil;

    switch (state) {
        case 1 :
            object = self.highlighted;
            break;

        case 2 :
            object = self.disabled;
            break;

        case 3 :
            object = self.highlightedAndDisabled;
            break;

        case 4 :
            object = self.selected;
            break;

        case 5 :
            object = self.highlightedAndSelected;
            break;

        case 6 :
            object = self.disabledAndSelected;
            break;

        case 7 :
            object = self.selectedHighlightedAndDisabled;
            break;

        default :
            object = self.normal;
            break;
    }  /* switch */

    return object;
}

- (void)setObject:(id)object forState:(NSUInteger)state {
    switch (state) {
        case 1 :
            self.highlighted = object;
            break;

        case 2 :
            self.disabled = object;
            break;

        case 3 :
            self.highlightedAndDisabled = object;
            break;

        case 4 :
            self.selected = object;
            break;

        case 5 :
            self.highlightedAndSelected = object;
            break;

        case 6 :
            self.disabledAndSelected = object;
            break;

        case 7 :
            self.selectedHighlightedAndDisabled = object;
            break;

        default :
            self.normal = object;
    }  /* switch */
}

- (id)alternateObjectStateForState:(UIControlState)state
                  substitutedState:(UIControlState *)substitutedState {
    id     object              = [self objectForState:state];
    BOOL   substitutePointerOK = (substitutedState != NULL);

    if (ValueIsNotNil(object) && substitutePointerOK) {
        *substitutedState = state;

        return object;
    }

    // Pass through a series of conditional statements to obtain a substitute if necessary
    if (state & UIControlStateDisabled && state != UIControlStateDisabled) {
        object = self.disabled;

        if (ValueIsNotNil(object) && substitutePointerOK) *substitutedState = UIControlStateDisabled;
    }

    if (ValueIsNil(object) && (state & UIControlStateHighlighted) && state != UIControlStateHighlighted) {
        object = self.highlighted;

        if (ValueIsNotNil(object) && substitutePointerOK) *substitutedState = UIControlStateHighlighted;
    }

    if (ValueIsNil(object) && (state & UIControlStateSelected) && state != UIControlStateSelected) {
        object = self.selected;

        if (ValueIsNotNil(object) && substitutePointerOK) *substitutedState = UIControlStateSelected;
    }

    if (ValueIsNil(object) && state != UIControlStateNormal) {
        object = self.normal;

        if (ValueIsNotNil(object) && substitutePointerOK) *substitutedState = UIControlStateNormal;
    }

    return NilSafeValue(object);
}

@end
