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
import DataModel

public class ButtonView: RemoteElementView {

  var button: Button { return model as! Button }

  // MARK: - Cached model values

  public private(set) var title: NSAttributedString? { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }
  public private(set) var icon: UIImage? { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }
  public private(set) var foregroundColor: UIColor? { didSet { setNeedsDisplay() } }
  private var _backgroundColor: UIColor? { didSet { setNeedsDisplay() } }
  public override var backgroundColor: UIColor? { get { return _backgroundColor } set { _backgroundColor = newValue } }

  // MARK: - Actions

  var tapAction: ((Void) -> Void)?
  var pressAction: ((Void) -> Void)?

	/**
	executeActionWithOption:

	:param: option CommandOption
	*/
	func executeActionWithOption(option: Command.Option) {
		if !isEditing {
			if button.command != nil && button.command!.indicator { activityIndicator.startAnimating() }
      MSLogDebug("executing command for button named '\(button.name)'")
			button.executeCommandWithOption(option) {
				(success: Bool, error: NSError?) -> Void in
					if self.activityIndicator.isAnimating() {
						NSOperationQueue.mainQueue().addOperationWithBlock {
							self.activityIndicator.stopAnimating()
						}
					}
			}
		}
	}

  // MARK: - Gestures

  weak var tapGesture :UITapGestureRecognizer!
  weak var longPressGesture: UILongPressGestureRecognizer!

  /** attachGestureRecognizers */
	override func attachGestureRecognizers() {
		super.attachGestureRecognizers()

		let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
		longPressGesture.delaysTouchesBegan = false
		addGestureRecognizer(longPressGesture)
		self.longPressGesture = longPressGesture

		let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
		tapGesture.numberOfTapsRequired    = 1
		tapGesture.numberOfTouchesRequired = 1
		tapGesture.delaysTouchesBegan      = false
		addGestureRecognizer(tapGesture)
		self.tapGesture = tapGesture
	}

	/**
	Single tap action executes the primary button command

	:param: gestureRecognizer UITapGestureRecognizer
	*/
	func handleTap(gestureRecognizer: UITapGestureRecognizer) {
    MSLogDebug("tapped button '\(button.name)'")
		if gestureRecognizer.state == .Ended {
			button.highlighted = true
			MSDelayedRunOnMain(1, {self.button.highlighted = false})
			tapAction?() ?? executeActionWithOption(.Default)
		}
	}

	/**
	Long press action executes the secondary button command

	:param: gestureRecognizer UILongPressGestureRecognizer
	*/
	func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    MSLogDebug("pressed button '\(button.name)'")
		if gestureRecognizer.state == .Ended {
			pressAction?() ?? executeActionWithOption(.LongPress)

		} else if gestureRecognizer.state == .Possible {
			button.highlighted = true
			setNeedsDisplay()
		}
	}

  // MARK: - Internal views

  /*weak var labelView: UILabel!*/
  weak var activityIndicator: UIActivityIndicatorView!

	/** addInternalSubviews */
	override func addInternalSubviews() {
		super.addInternalSubviews()

		let activityIndicator = UIActivityIndicatorView.newForAutolayout()
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
		activityIndicator.color = UIColor.whiteColor()
		addSubview(activityIndicator)
		self.activityIndicator = activityIndicator
	}

  // MARK: - Constraints

	/** updateConstraints */
	override public func updateConstraints() {
		super.updateConstraints()

    let identifier = createIdentifier(self, ["Button", "Internal"])
    if constraintsWithIdentifier(identifier).count == 0 {
      constrain(identifier: identifier, activityIndicator.centerX => self.centerX, activityIndicator.centerY => self.centerY)
    }
	}

  // MARK: - Size

 /**
	intrinsicContentSize

	:returns: CGSize
	*/
	override public func intrinsicContentSize() -> CGSize { return minimumSize }

	override public var minimumSize: CGSize {
		var frame = CGRect(size: RemoteElementView.MinimumSize)
    if let title = button.title {
      var titleSize = title.size()
      let titleInsets = button.titleEdgeInsets
      titleSize.width += titleInsets.left + titleInsets.right
      titleSize.height += titleInsets.top + titleInsets.bottom
      frame.size.width = max(titleSize.width, frame.size.width)
      frame.size.height = max(titleSize.height, frame.size.height)
    }

	  if model.constraintManager.proportionLock && bounds.size != CGSize.zeroSize {
	  	let currentSize = bounds.size

	    if currentSize.width > currentSize.height {
	    	frame.size.height = (frame.size.width * currentSize.height) / currentSize.width
    	} else {
    		frame.size.width = (frame.size.height * currentSize.width) / currentSize.height
    	}
    }

	  return frame.size
	}

  // MARK: - KVO

	/**
	kvoRegistration

	:returns: [Property:KVOReceptionist.Observation]
	*/
	override func kvoRegistration() -> [Property:KVOReceptionist.Observation] {
		var registry = super.kvoRegistration()
    registry["background"] = nil
    registry["backgroundColor"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.backgroundColor = ($0.object as? Button)?.backgroundColor
    }
    registry["foregroundColor"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.foregroundColor = ($0.object as? Button)?.foregroundColor
    }
    registry["title"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.title = ($0.object as? Button)?.title
    }
		registry["icon"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.icon = ($0.object as? Button)?.icon?.colorImage
    }
    registry["longPressCommand"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.longPressGesture.enabled = ($0.object as? Button)?.longPressCommand != nil
    }
    registry["state"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.updateStateSensitiveProperties()
    }
		return registry
	}

  // MARK: - Updating

  /** updateViewFromModel */
  override func updateViewFromModel() {
    super.updateViewFromModel()
    longPressGesture.enabled = button.longPressCommand != nil
    updateStateSensitiveProperties()
  }

  /** updateStateSensitiveProperties */
  func updateStateSensitiveProperties() {
    title = button.title
    icon  = button.icon?.colorImage
    backgroundColor = button.backgroundColor
    foregroundColor = button.foregroundColor
    invalidateIntrinsicContentSize()
  }

  // MARK: - Editing

	override public var editingMode: RemoteElement.BaseType {
		didSet {
			tapGesture.enabled = !isEditing
			longPressGesture.enabled = !isEditing
		}
	}

  // MARK: - Drawing

	/**
	drawRect:

	:param: rect CGRect
	*/
	override public func drawRect(rect: CGRect) {
    if hasOption(.DrawBackground, button.style) { drawWithBackgroundInRect(rect) } else  { drawWithoutBackgroundInRect(rect) }
	}

  /**
  drawWithoutBackgroundInRect:

  :param: rect CGRect
  */
  private func drawWithoutBackgroundInRect(rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    let fgColor = foregroundColor ?? Painter.defaultForegroundColor
    let shadow: NSShadow? = button.highlighted ? NSShadow(color: fgColor, offset: CGSize.zeroSize, blurRadius: 5) : nil

    CGContextSaveGState(context)
    shadow?.setShadow()
    CGContextBeginTransparencyLayer(context, nil)

    CGContextSaveGState(context)
    fgColor.setFill()
    UIRectFill(rect)

    CGContextSetBlendMode(context, kCGBlendModeDestinationIn)
    CGContextBeginTransparencyLayer(context, nil)

    if let image = icon {
      let imageAttrs = Painter.Attributes(
        rect: (button.contentEdgeInsets + button.imageEdgeInsets).insetRect(bounds),
        foregroundColor: fgColor,
        accentShadow: shadow
      )
      Painter.drawImage(image, withAttributes: imageAttrs, boundByShape: button.shape)
    }


    if let attributedText = title where attributedText.length > 0 {
      let txtAttrs = Painter.Attributes(
        rect: (button.contentEdgeInsets + button.titleEdgeInsets).insetRect(bounds),
        shadow: shadow,
        text: attributedText.string,
        fontAttributes: attributedText.attributesAtIndex(0, effectiveRange: nil)
      )
      Painter.drawText(attributedText.string, withAttributes: txtAttrs, boundByShape: button.shape)
    }

    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)

    CGContextEndTransparencyLayer(context)
    CGContextRestoreGState(context)

  }

  /**
  drawWithBackgroundInRect:

  :param: rect CGRect
  */
  private func drawWithBackgroundInRect(rect: CGRect) {

    if button.shape == .Undefined { return }

    let context = UIGraphicsGetCurrentContext()

    let baseRect = rect.integerRect
    let bleedRect = baseRect.rectByInsetting(dx: 4, dy: 4)

    let bgColor = backgroundColor ?? Painter.defaultBackgroundColor
    let fgColor = foregroundColor ?? Painter.defaultForegroundColor
    let accentShadow: NSShadow? = button.highlighted ? NSShadow(color: fgColor, offset: CGSize.zeroSize, blurRadius: 5) : nil

    // Draw shape filled with accent color
    let bleedThroughAttrs = Painter.Attributes(rect: bleedRect, color: fgColor)
    Painter.drawShape(button.shape, withAttributes: bleedThroughAttrs)

    CGContextSaveGState(context)                                                            // context: •
    accentShadow?.setShadow()
    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: •

    let baseAttrs = Painter.Attributes(
      rect: baseRect,
      color: bgColor,
      accentColor: fgColor,
      foregroundColor: fgColor
    )
    Painter.drawBaseWithShape(button.shape, attributes: baseAttrs)

    CGContextSaveGState(context)                                                            // context: ••
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut)
    accentShadow?.setShadow()
    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: ••

    if let image = icon {

      let imageAttrs = Painter.Attributes(
        rect: bleedRect,
        color: fgColor,
        accentShadow: accentShadow
      )
      Painter.drawImage(image, withAttributes: imageAttrs, boundByShape: button.shape)
    }

    if let attributedText = title where attributedText.length > 0 {

      let txtAttrs = Painter.Attributes(
        rect: baseRect,
        shadow: accentShadow,
        text: attributedText.string,
        fontAttributes: attributedText.attributesAtIndex(0, effectiveRange: nil)
      )
      Painter.drawText(attributedText.string, withAttributes: txtAttrs, boundByShape: button.shape)
    }

    CGContextEndTransparencyLayer(context)                                                  // transparency: •
    CGContextRestoreGState(context)                                                         // context: •

    CGContextEndTransparencyLayer(context)                                                  // transparency:
    CGContextRestoreGState(context)                                                         // context:

    if hasOption(.ApplyGloss, button.style) {
      let glossAttrs = Painter.Attributes(rect: baseRect, alpha: 0.15, blendMode: kCGBlendModeSoftLight)
      Painter.drawGlossWithShape(button.shape, attributes: glossAttrs)
    }
  }

}
