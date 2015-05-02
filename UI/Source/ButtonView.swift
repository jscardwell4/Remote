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

	weak var tapGesture :UITapGestureRecognizer!
	weak var longPressGesture: UILongPressGestureRecognizer!
	weak var labelView: UILabel!
	weak var activityIndicator: UIActivityIndicatorView!

  public private(set) var title: NSAttributedString? { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }
  public private(set) var icon: UIImage? { didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() } }

  var tapAction: ((Void) -> Void)?
  var pressAction: ((Void) -> Void)?
  var button: Button { return model as! Button }

  // Prevent subelement views for the button
	/* override public func addSubelementView(view: RemoteElementView) {}*/
	/* override public func removeSubelementView(view: RemoteElementView) {}*/
	/* override public func addSubelementViews(views: Set<RemoteElementView>) {}*/
	/* override public func removeSubelementViews(views: Set<RemoteElementView>) {}*/
	/* override public var subelementViews: OrderedSet<RemoteElementView> { return [] }*/

	/**
	executeActionWithOption:

	:param: option CommandOption
	*/
	func executeActionWithOption(option: Command.Option) {
		if !isEditing {
			if button.command != nil && button.command!.indicator { activityIndicator.startAnimating() }
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
		if gestureRecognizer.state == .Ended {
			pressAction?() ?? executeActionWithOption(.LongPress)

		} else if gestureRecognizer.state == .Possible {
			button.highlighted = true
			setNeedsDisplay()
		}
	}

	/** addInternalSubviews */
	override func addInternalSubviews() {
		super.addInternalSubviews()

		/*subelementInteractionEnabled = false*/
		/*contentInteractionEnabled    = false*/

		/*let labelView = UILabel.newForAutolayout()*/
		/*addViewToContent(labelView)*/
		/*self.labelView = labelView*/

		let activityIndicator = UIActivityIndicatorView.newForAutolayout()
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
		activityIndicator.color = UIColor.whiteColor()
		addSubview(activityIndicator) /** addViewToOverlay(activityIndicator) */
		self.activityIndicator = activityIndicator
	}

	/** updateConstraints */
	override public func updateConstraints() {
		super.updateConstraints()

    let identifier = createIdentifier(self, ["Button", "Internal"])
    if constraintsWithIdentifier(identifier).count == 0 {
      let titleInsets = button.titleEdgeInsets
      let format = "\n".join(/*"label.left = self.left + \(titleInsets.left) @900",*/
                             /*"label.top = self.top + \(titleInsets.top) @900",*/
                             /*"label.bottom = self.bottom - \(titleInsets.bottom) @900",*/
                             /*"label.right = self.right - \(titleInsets.right) @900",*/
                             "activity.center = self.center")
      constrain(format, views: [/*"label": labelView,*/ "activity": activityIndicator], identifier: identifier)
    }
	}


 /**
	intrinsicContentSize

	:returns: CGSize
	*/
	override public func intrinsicContentSize() -> CGSize { return minimumSize }

	override public var minimumSize: CGSize {
		var frame = CGRect(size: RemoteElementView.MinimumSize)
//	  let titleSets = model.modes.map{self.button.titlesForMode($0 as NSString)}
//	  let titles = titleSets.map{$0.allValues}
//
//	  if titles.count > 0 {
//	  	var maxWidth: CGFloat = 0.0
//	  	var maxHeight: CGFloat = 0.0
//
//	  	for title in (titles.map{$0.string}) {
//	  		var titleSize = title.size
//	  		let titleInsets = model.titleEdgeInsets
//	  		titleSize.width += titleInsets.left + titleInsets.right
//	  		titleSize.height += titleInsets.top + titleInsets.bottom
//	  		maxWidth = max(titleSize.width, maxWidth)
//	  		maxHeight = max(titleSize.height, maxHeight)
//	  	}
//
//	    frame.size.width = max(maxWidth, frame.width)
//	    frame.size.height = max(maxHeight, frame.height)
//	  }
//
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

	/**
	kvoRegistration

	:returns: [Property:KVOReceptionist.Observation]
	*/
	override func kvoRegistration() -> [Property:KVOReceptionist.Observation] {
		var registry = super.kvoRegistration()
    registry["title"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.title = ($0.object as? Button)?.title
    }
		registry["icon"] = {
      RemoteElementView.dumpObservation($0)
      ($0.observer as? ButtonView)?.icon = ($0.object as? Button)?.icon?.colorImage
    }
		return registry
	}

  /** updateViewFromModel */
  override func updateViewFromModel() {
    longPressGesture.enabled = button.longPressCommand != nil
    title = button.title
    icon  = button.icon?.colorImage
    invalidateIntrinsicContentSize()
    super.updateViewFromModel()
  }

	override public var editingMode: RemoteElement.BaseType {
		didSet {
			tapGesture.enabled = !isEditing
			longPressGesture.enabled = !isEditing
		}
	}

  /** setNeedsDisplay */
  /*override public func setNeedsDisplay() {
    labelView?.attributedText = button.title
    super.setNeedsDisplay()
  }*/

	/**
	drawRect:

	:param: rect CGRect
	*/
	override public func drawRect(rect: CGRect) {

    let drawBackground = button.style & .DrawBackground != nil
    let shape = button.shape == .Undefined ? .Rectangle : button.shape
    var attrs = Painter.Attributes(rect: rect)
    let context = UIGraphicsGetCurrentContext()

    // TODO: Check points against path for the sides of min/max font height, i.e. shrink more for diamond/triangle shapes
    let baseRect = rect.rectByInsetting(dx: 4, dy: 4).integerRect

    let bleedRect = baseRect.rectByInsetting(dx: 4, dy: 4)

    let accentColor = attrs.accentColor ?? Painter.defaultAccentColor
    let accentShadow: NSShadow? = button.highlighted ? NSShadow(color: accentColor, offset: CGSize.zeroSize, blurRadius: 5) : nil

    // Draw background
    if drawBackground {

    // Draw shape filled with accent color
    attrs = Painter.Attributes(rect: bleedRect)
    attrs.color = accentColor
    Painter.drawShape(shape, withAttributes: attrs)

    CGContextSaveGState(context)                                                            // context: •
    accentShadow?.setShadow()
    CGContextBeginTransparencyLayer(context, nil)                                           // transparency: •

      attrs.color = backgroundColor ?? Painter.defaultBackgroundColor
      attrs.accentColor = accentColor
      attrs.rect = baseRect
      attrs.stroke = button.style & .DrawBorder != nil
      Painter.drawBaseWithShape(shape, attributes: attrs)

      CGContextSaveGState(context)                                                            // context: ••
      CGContextSetBlendMode(context, kCGBlendModeDestinationOut)
      CGContextBeginTransparencyLayer(context, nil)                                           // transparency: ••

      if let image = icon {

        var imageAttrs = attrs
        imageAttrs.rect = baseRect
        imageAttrs.alpha = 0.9
        imageAttrs.shadow = Painter.innerShadow
        imageAttrs.accentShadow = accentShadow

        Painter.drawImage(image, withAttributes: imageAttrs, boundByShape: shape)
      }

      if let attributedText = title {

        var txtAttrs = attrs
        txtAttrs.rect = baseRect
        txtAttrs.shadow = accentShadow
        txtAttrs.fontAttributes = attributedText.attributesAtIndex(0, effectiveRange: nil)

        Painter.drawText(attributedText.string, withAttributes: txtAttrs, boundByShape: shape)
      }
      
      CGContextEndTransparencyLayer(context)                                                  // transparency: •
      CGContextRestoreGState(context)                                                         // context: •

      CGContextEndTransparencyLayer(context)                                                  // transparency:
      CGContextRestoreGState(context)                                                         // context:
    } else if let icon = button.icon?.colorImage {
      let insetRect = button.contentEdgeInsets.insetRect(bounds)
      let imageSize = insetRect.size.contains(icon.size)
        ? icon.size
        : icon.size.aspectMappedToSize(insetRect.size, binding: true)
      let imageRect = CGRect(x: insetRect.midX - imageSize.width / 2.0,
        y: insetRect.midY - imageSize.height / 2.0,
        width: imageSize.width,
        height: imageSize.height)
      icon.drawInRect(imageRect)
    }



    if button.style & .ApplyGloss != nil {

      var glossAttrs = Painter.Attributes(rect: baseRect)
      glossAttrs.alpha = 0.1
      glossAttrs.blendMode = kCGBlendModeSoftLight
      
      Painter.drawGlossWithShape(shape, attributes: glossAttrs)
    }


	}

}
