//
// RELabelView.m
// Remote
//
// Created by Jason Cardwell on 3/17/13.
// Copyright (c) 2013 Moondeer Studios. All rights reserved.
//
#import "RELabelView.h"

@implementation RELabelView

- (id)init {
    if ((self = [super init])) {
        self.preserveLines = YES; self.clipsToBounds = NO;
    }

    return self;
}

- (void)setBaseWidth:(CGFloat)baseWidth {
    _baseWidth = baseWidth; _fontScale = 1.0f;
}

- (NSUInteger)lineBreaks {
    return [self.text numberOfMatchesForRegEx:@"\\n"];
}

- (void)drawTextInRect:(CGRect)rect {
    UIGraphicsPushContext(UIGraphicsGetCurrentContext());
    if (self.preserveLines) {
        CGFloat   w = rect.size.width;

        if (!_baseWidth)
            self.baseWidth = rect.size.width;
        else if (w != _baseWidth)
            self.fontScale = w / _baseWidth;
        else
            _fontScale = 1.0f;

        if (_fontScale != 1.0f) {
            CGContextScaleCTM(UIGraphicsGetCurrentContext(), _fontScale, _fontScale);
            CGContextTranslateCTM(UIGraphicsGetCurrentContext(),
                                  0,
                                  rect.origin.y + (_baseWidth - w) / 2.0f);
            rect.size.width = _baseWidth;
        }
    }

    [super drawTextInRect:rect];
    UIGraphicsPopContext();
}

@end

@implementation REButtonLabelView



@end
