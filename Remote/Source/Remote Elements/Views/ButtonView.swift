//
//  ButtonView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ButtonView: RemoteElementView {

	weak var tapGesture :UITapGestureRecognizer!
	weak var longPressGesture: MSLongPressGestureRecognizer!
	weak var labelView: UILabel!
	weak var activityIndicator: UIActivityIndicatorView!

	/**
	addSubelementView:

	:param: view RemoteElementView
	*/
	override func addSubelementView(view: RemoteElementView) {}

	/**
	removeSubelementView:

	:param: view RemoteElementView
	*/
	override func removeSubelementView(view: RemoteElementView) {}

	/**
	addSubelementViews:

	:param: views NSSet
	*/
	override func addSubelementViews(views: NSSet) {}

	/**
	removeSubelementViews:

	:param: views NSSet
	*/
	override func removeSubelementViews(views: NSSet) {}

	override var subelementViews: [RemoteElementView] { return [] }

/* - (void)executeActionWithOptions:(CommandOptions)options {

  if (!self.editing) {

    if (self.model.command.indicator) [_activityIndicator startAnimating];

    [self.model executeCommandWithOptions:options
                               completion:^(BOOL success, NSError * error) {
                                 if ([self.activityIndicator isAnimating])
                                   MSRunAsyncOnMain(^{ [self.activityIndicator stopAnimating]; });
                               }];
  }

}
 */

/*
- (void)attachGestureRecognizers {
  [super attachGestureRecognizers];

  MSLongPressGestureRecognizer * longPressGesture =
    [MSLongPressGestureRecognizer gestureWithTarget:self action:@selector(handleLongPress:)];

  longPressGesture.delaysTouchesBegan = NO;
  longPressGesture.delegate           = self;
  [self addGestureRecognizer:longPressGesture];
  self.longPressGesture = longPressGesture;

  UITapGestureRecognizer * tapGesture =
    [UITapGestureRecognizer gestureWithTarget:self action:@selector(handleTap:)];

  tapGesture.numberOfTapsRequired    = 1;
  tapGesture.numberOfTouchesRequired = 1;
  tapGesture.delaysTouchesBegan      = NO;
  tapGesture.delegate                = self;
  [self addGestureRecognizer:tapGesture];
  self.tapGesture = tapGesture;
} */

/// Single tap action executes the primary button command
/* - (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {

  if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {

    self.model.highlighted = YES;

    __weak ButtonView * weakself = self;
    MSDelayedRunOnMain(1.0, ^{ weakself.model.highlighted = NO; });

    if (self.tapAction) self.tapAction();
    else [self executeActionWithOptions:CommandOptionDefault];
  }
} */

/// Long press action executes the secondary button command
/* - (void)handleLongPress:(MSLongPressGestureRecognizer *)gestureRecognizer {

  if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {

    if (self.pressAction) self.pressAction();
    else [self executeActionWithOptions:CommandOptionLongPress];

  } else if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
    self.model.highlighted = YES;
    [self setNeedsDisplay];
  }
} */

/* - (void)addInternalSubviews {
  [super addInternalSubviews];

  self.subelementInteractionEnabled = NO;
  self.contentInteractionEnabled    = NO;

  UILabel * labelView = [UILabel newForAutolayout];
  [self addViewToContent:labelView];
  self.labelView = labelView;

  UIActivityIndicatorView * activityIndicator = [UIActivityIndicatorView newForAutolayout];
  activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  activityIndicator.color                      = [UIColor whiteColor];
  [self addViewToOverlay:activityIndicator];
  self.activityIndicator = activityIndicator;
} */

/* - (void)updateConstraints {
  [super updateConstraints];

  NSString * labelNametag    = ClassNametagWithSuffix(@"InternalLabel");
  NSString * activityNametag = ClassNametagWithSuffix(@"InternalActivity");

  if (![[self constraintsWithNametagPrefix:labelNametag] count]) {
    UIEdgeInsets titleInsets = self.model.titleEdgeInsets;
    NSString   * constraints =
      $(@"'%1$@' label.left = self.left + %3$f @900\n"
        "'%1$@' label.top = self.top + %4$f @900\n"
        "'%1$@' label.bottom = self.bottom - %5$f @900\n"
        "'%1$@' label.right = self.right - %6$f @900\n"
        "'%2$@' activity.centerX = self.centerX\n"
        "'%2$@' activity.centerY = self.centerY",
        labelNametag, activityNametag,
        titleInsets.left, titleInsets.top, titleInsets.bottom, titleInsets.right);

    NSDictionary * views = @{@"self": self, @"label": self.labelView, @"activity": self.activityIndicator};

    [self addConstraints:[NSLayoutConstraint constraintsByParsingString:constraints views:views]];
  }
} */


 /**
	intrinsicContentSize

	:returns: CGSize
	*/
	override func intrinsicContentSize() -> CGSize { return minimumSize }
/*
- (CGSize)minimumSize {

  CGRect frame = (CGRect) { .size = REMinimumSize };

  NSMutableSet * titles = [NSMutableSet set];

  for (NSString *mode in self.model.modes) {
    ControlStateTitleSet * titleSet = [self.model titlesForMode:mode];
    if (titleSet) [titles addObjectsFromArray:[titleSet allValues]];
  }

  if ([titles count]) {

    CGFloat maxWidth = 0.0, maxHeight = 0.0;

    for (NSAttributedString * title in [titles valueForKeyPath:@"string"]) {

      CGSize titleSize = [title size];
      UIEdgeInsets titleInsets = self.model.titleEdgeInsets;

      titleSize.width  += titleInsets.left + titleInsets.right;
      titleSize.height += titleInsets.top + titleInsets.bottom;

      maxWidth = MAX(titleSize.width, maxWidth);
      maxHeight = MAX(titleSize.height, maxHeight);

    }

    frame.size.width = MAX(maxWidth, frame.size.width);
    frame.size.height = MAX(maxHeight, frame.size.height);
  }

  if (self.model.proportionLock && !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {

    CGSize currentSize = self.bounds.size;

    if (currentSize.width > currentSize.height)
      frame.size.height = (frame.size.width * currentSize.height) / currentSize.width;

    else
      frame.size.width = (frame.size.height * currentSize.width) / currentSize.height;
  }

  return frame.size;
}
*/
	/**
	kvoRegistration

	:returns: [String:(MSKVOReceptionist) -> Void]
	*/
	override func kvoRegistration() -> [String:(MSKVOReceptionist) -> Void] {
		let registry = super.kvoRegistration()
		registry["title"] = {
			(receptionist: MSKVOReceptionist) -> Void in
				if let v = receptionist.observer as? ButtonView {
					v.labelView.attributedText = receptionist.change[NSKeyValueChangeNewKey] as? NSAttributedString
					v.invalidateIntrinsicContentSize()
					v.setNeedsDisplay()
				}
		}
		registry["icon"] = {
			(receptionist: MSKVOReceptionist) -> Void in
				if let v = receptionist.observer as? ButtonView {
					v.invalidateIntrinsicContentSize()
					v.setNeedsDisplay()
				}
		}
		return registry
	}

	/** intializeViewFromModel */
	override func intializeViewFromModel() {
		super.intializeViewFromModel()
		longPressGesture.enabled = model.longPressCommand != nil
		labelView.attributedText = model.title
		invalidateIntrinsicContentSize()
		setNeedsDisplay()
	}

	override var editingMode: REEditingMode {
		didSet {
			tapGesture.enabled = !editing
			longPressGesture.enabled = !editing
		}
	}

	/**
	drawContentInContext:inRect:

	:param: ctx CGContextRef
	:param: rect CGRect
	*/
	override func drawContentInContext(ctx: CGContextRef, inRect rect: CGRect) {
		if let icon = model.icon.colorImage {
			UIGraphicsPushContext(ctx)
			let insetRect = model.imageEdgeInsets.insetRect(bounds)
			let imageSize = insetRect.contains(icon.size) ? icon.size : icon.size.aspectMappedToSize(insetRect.size, true)
			let imageRect = CGRect(x: insetRect.midX - imageSize.width / 2.0,
				                     y: insetRect.midY - imageSize.height /2.0,
				                     width: imageSize.width,
				                     height: imageSize.height)
			icon.drawInRect(iamgeRect)
			UIGraphicsPopContext()
		}

	}

}
