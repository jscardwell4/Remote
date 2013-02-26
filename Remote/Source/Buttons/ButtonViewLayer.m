//
// ButtonViewLayer.m
// iPhonto
//
// Created by Jason Cardwell on 4/19/12.
// Copyright (c) 2012 Moondeer Studios. All rights reserved.
//

#import "ButtonViewLayer.h"
#import "ButtonView.h"
#import "ButtonView_Private.h"
#import "Constants.h"
#import "Painter.h"

static int       ddLogLevel = LOG_LEVEL_DEBUG;
static UIColor * selectedColor;
static UIColor * focusColor;
static UIColor * movingColor;
static UIColor * glossColor;

@interface ButtonViewLayer ()

@property (nonatomic, strong) CAShapeLayer * backdrop;
@property (nonatomic, strong) CAShapeLayer * border;
@property (nonatomic, strong) CALayer      * icon;
@property (nonatomic, strong) CALayer      * text;
@property (nonatomic, strong) CALayer      * gloss;
@property (nonatomic, strong) UIBezierPath * clippingPath;

- (void)updateText;

- (void)updateIcon;

@end

@implementation ButtonViewLayer

@synthesize
buttonView   = _buttonView,
clippingPath = _clippingPath,
cornerRadii  = _cornerRadii,
icon         = _icon,
text         = _text,
backdrop     = _backdrop,
border       = _border,
gloss        = _gloss;

+ (void)initialize {
    if (self == [ButtonViewLayer class]) {
        selectedColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
        focusColor    = [[UIColor redColor] colorWithAlphaComponent:0.5];
        movingColor   = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        glossColor    = defaultGlossColor();
    }
}

- (id)init {
    self = [super init];

    if (self) {
        CGPoint   center = CGRectGetCenter(self.bounds);
        CGRect    bounds = self.bounds;

        self.backdrop           = [CAShapeLayer layer];
        _backdrop.zPosition     = -100;
        _backdrop.contentsScale = MainScreenScale;
        _backdrop.bounds        = bounds;
        _backdrop.position      = center;

        self.gloss           = [CALayer layer];
        _gloss.contentsScale = MainScreenScale;
        _gloss.bounds        = bounds;
        _gloss.position      = center;

        self.border           = [CAShapeLayer layer];
        _border.zPosition     = 100;
        _border.contentsScale = MainScreenScale;
        _border.bounds        = bounds;
        _border.position      = center;

        self.icon           = [CALayer layer];
        _icon.zPosition     = 50;
        _icon.contentsScale = MainScreenScale;
        _icon.bounds        = bounds;
        _icon.position      = center;

        self.text           = [CALayer layer];
        _text.zPosition     = 50;
        _text.contentsScale = MainScreenScale;
        _text.bounds        = bounds;
        _text.position      = center;

        self.cornerRadii = CGSizeMake(5.0, 5.0);

        [self addSublayer:_backdrop];
        [self addSublayer:_icon];
        [self addSublayer:_text];
        [self addSublayer:_gloss];
        [self addSublayer:_border];
    }

    return self;
}

- (void)setDelegate:(id)delegate {
    if ([delegate isKindOfClass:[ButtonView class]]) {
        self.buttonView = (ButtonView *)delegate;
        DDLogDebug(@"%@\n\tdelegate:%@", ClassTagSelectorString, delegate);
    }

    [super setDelegate:delegate];
}

- (void)updateText {
    NSString * text = [self.buttonView titleForState:_buttonView.state];

    if (ValueIsNil(text)) {
        _text.contents = nil;

        return;
    }

    _text.bounds   = self.bounds;
    _text.position = CGRectGetCenter(self.bounds);

    // font to use
    UIFont * font = self.buttonView.button.font;

    if (ValueIsNil(font)) {
        DDLogWarn(@"%@\n\tunable to obtain font for drawing label text",
                  ClassTagStringForInstance(self.buttonView.key));

        return;
    }

    // determine rect to draw into
    CGRect   rect     = UIEdgeInsetsInsetRect(self.bounds, self.buttonView.titleEdgeInsets);
    CGSize   textSize = [text    sizeWithFont:font
                            constrainedToSize:rect.size
                                lineBreakMode:NSLineBreakByWordWrapping];
    CGRect   textRect = CGRectMake(0,
                                   CGRectGetMidY(rect) - textSize.height / 2.0,
                                   rect.size.width,
                                   textSize.height);

    // determine color to use
    UIColor * textColor = [_buttonView.button titleColorForState:_buttonView.state];

    if (ValueIsNil(textColor)) textColor = [UIColor whiteColor];

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, MainScreenScale);

    [textColor setFill];

    [text  drawInRect:textRect
             withFont:font
        lineBreakMode:NSLineBreakByWordWrapping
            alignment:self.buttonView.textAlignment];

    _text.contents = (__bridge id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
// self.contents = _text.contents;
// [self setNeedsDisplay];
    UIGraphicsEndImageContext();

    [_text setNeedsDisplay];
}  /* updateText */

- (void)updateIcon {
    UIImage * icon = [_buttonView iconForState:_buttonView.state];

    if (ValueIsNil(icon)) {
        _icon.contents = nil;

        return;
    }

    _icon.bounds   = self.bounds;
    _icon.position = CGRectGetCenter(self.bounds);

    // determine rect to draw into
    CGRect   rect      = UIEdgeInsetsInsetRect(self.bounds, _buttonView.imageEdgeInsets);
    CGSize   imageSize = CGSizeFitToSize(icon.size, rect.size); // [icon sizeThatFits:rect.size];
    CGRect   imageRect = CGRectMake(CGRectGetMidX(rect) - imageSize.width / 2.0,
                                    CGRectGetMidY(rect) - imageSize.height / 2.0,
                                    imageSize.width,
                                    imageSize.height);

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, MainScreenScale);
    [icon drawInRect:imageRect];
    _icon.contents = (__bridge id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();

    [_icon setNeedsDisplay];
}

- (void)updateContent {
    if (ValueIsNil(_buttonView) || ValueIsNil(_buttonView.button)) return;

    ButtonShape   shape = self.buttonView.style & ButtonShapeMask;

    switch (shape) {
        case ButtonShapeRoundedRectangle :
            self.clippingPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                      byRoundingCorners:UIRectCornerAllCorners
                                                            cornerRadii:_cornerRadii];
            break;

        case ButtonShapeOval :
            self.clippingPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
            break;

        case ButtonShapeRectangle :
            self.clippingPath = [UIBezierPath bezierPathWithRect:self.bounds];
            break;
    }

    if (ValueIsNil(_clippingPath)) return;

    UIColor * backdropColor = [_buttonView backgroundColorForState:_buttonView.state];

    if (ValueIsNil(backdropColor)) {
        backdropColor = [_buttonView backgroundColorForState:UIControlStateNormal];

        if (ValueIsNil(backdropColor)) backdropColor = defaultBGColor();
    }

    _backdrop.fillColor = backdropColor.CGColor;
    _backdrop.path      = _clippingPath.CGPath;

    ButtonStyle   appearance = self.buttonView.style & ButtonStyleMask;

    if (appearance & ButtonStyleApplyGloss) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, MainScreenScale);

        CGContextRef   ctx = UIGraphicsGetCurrentContext();

        CGContextAddPath(ctx, _clippingPath.CGPath);
        CGContextClip(ctx);
        [Painter drawGlossGradientWithColor:glossColor inRect:self.bounds inContext:ctx];
        _gloss.bounds   = self.bounds;
        _gloss.position = CGRectGetCenter(self.bounds);
        _gloss.contents = (__bridge id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();
    } else
        _gloss.contents = nil;

    _border.path      = _clippingPath.CGPath;
    _border.fillColor = [UIColor clearColor].CGColor;

    UIColor * borderColor = nil;

    switch (_buttonView.editingStyle) {
        case EditingStyleSelected :
            borderColor = selectedColor;
            break;

        case EditingStyleFocus :
            borderColor = focusColor;
            break;

        case EditingStyleMoving :
            borderColor = movingColor;
            break;

        default :
            borderColor = (appearance & ButtonStyleDrawBorder) ?[UIColor blackColor] :[UIColor clearColor];
            break;
    } /* switch */

    _border.strokeColor = borderColor.CGColor;
    _border.lineWidth   = 3.0;
    _border.lineJoin    = kCALineJoinRound;

    [self updateText];
    [self updateIcon];
    [self setNeedsDisplay];
}     /* updateContent */

@end
