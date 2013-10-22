//
//  MSLongPressGestureRecognizer.m
//  MSKit
//
//  Created by Jason Cardwell on 10/13/12.
//  Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "MSLongPressGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "MSKitMacros.h"
#import "MSKitLoggingFunctions.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation MSLongPressGestureRecognizer {
    NSMutableArray * _mstargets;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        if (target && action)
            _mstargets = [@[@[SelectorString(action),target]] mutableCopy];
        else
            _mstargets = [@[] mutableCopy];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action {
    [super addTarget:target action:action];
    if (target && action)
        [_mstargets addObject:@[SelectorString(action),target]];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (NSArray * actionTargetPair in self->_mstargets) {
        SEL selector = NSSelectorFromString(actionTargetPair[0]);
        id target = actionTargetPair[1];
        objc_msgSend(target,selector,self);
    }
    [super touchesBegan:touches withEvent:event];
}

@end
