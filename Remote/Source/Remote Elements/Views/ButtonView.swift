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

  var tapAction: ((Void) -> Void)?
  var pressAction: ((Void) -> Void)?
  var button: Button { return model as Button }

  /**
  viewWithModel:

  :param: model Button

  :returns: ButtonView
  */
  @objc(viewWithButton:)
  override class func viewWithModel(model: Button) -> ButtonView {
    switch model.role {
      case RemoteElement.Role.BatteryStatus:    return BatteryStatusButtonView(model: model)
      case RemoteElement.Role.ConnectionStatus: return ConnectionStatusButtonView(model: model)
      default:                                return ButtonView(model: model)
    }
  }

  /** init */
  override init() { super.init() }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  Overridden properties prevent synthesized initializers

  :param: model RemoteElement
  */
  required init(model: RemoteElement) { super.init(model: model) }

  /**
  Overridden properties prevent synthesized initializers

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

	/**
	executeActionWithOptions:

	:param: options CommandOptions
	*/
	func executeActionWithOptions(options: CommandOptions) {
		if !isEditing {
			if button.command != nil && button.command!.indicator { activityIndicator.startAnimating() }
			button.executeCommandWithOptions(options) {
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

		let longPressGesture = MSLongPressGestureRecognizer(target: self, action: "handleLongPress:")
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
			tapAction?() ?? executeActionWithOptions(.Default)
		}
	}

	/**
	Long press action executes the secondary button command

	:param: gestureRecognizer MSLongPressGestureRecognizer
	*/
	func handleLongPress(gestureRecognizer: MSLongPressGestureRecognizer) {
		if gestureRecognizer.state == .Ended {
			pressAction?() ?? executeActionWithOptions(.LongPress)

		} else if gestureRecognizer.state == .Possible {
			button.highlighted = true
			setNeedsDisplay()
		}
	}

	/** addInternalSubviews */
	override func addInternalSubviews() {
		super.addInternalSubviews()

		subelementInteractionEnabled = false
		contentInteractionEnabled    = false

		let labelView = UILabel.newForAutolayout()
		addViewToContent(labelView)
		self.labelView = labelView

		let activityIndicator = UIActivityIndicatorView.newForAutolayout()
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
		activityIndicator.color = UIColor.whiteColor()
		addViewToOverlay(activityIndicator)
		self.activityIndicator = activityIndicator
	}

	/** updateConstraints */
	override func updateConstraints() {
		super.updateConstraints()

    let identifier = createIdentifier(self, ["Button", "Internal"])
    if constraintsWithIdentifier(identifier).count == 0 {
      let titleInsets = button.titleEdgeInsets
      let format = "\n".join("label.left = self.left + \(titleInsets.left) @900",
                             "label.top = self.top + \(titleInsets.top) @900",
                             "label.bottom = self.bottom - \(titleInsets.bottom) @900",
                             "label.right = self.right - \(titleInsets.right) @900",
                             "activity.center = self.center")
      constrain(format, views: ["label": labelView, "activity": activityIndicator], identifier: identifier)
    }
	}


 /**
	intrinsicContentSize

	:returns: CGSize
	*/
	override func intrinsicContentSize() -> CGSize { return minimumSize }

	override var minimumSize: CGSize {
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

	:returns: [String:(MSKVOReceptionist) -> Void]
	*/
	override func kvoRegistration() -> [String:(MSKVOReceptionist!) -> Void] {
		var registry = super.kvoRegistration()
		registry["title"] = {
			(receptionist: MSKVOReceptionist!) -> Void in
				if let v = receptionist.observer as? ButtonView {
					v.labelView.attributedText = receptionist.change[NSKeyValueChangeNewKey] as? NSAttributedString
					v.invalidateIntrinsicContentSize()
					v.setNeedsDisplay()
				}
		}
		registry["icon"] = {
			(receptionist: MSKVOReceptionist!) -> Void in
				if let v = receptionist.observer as? ButtonView {
					v.invalidateIntrinsicContentSize()
					v.setNeedsDisplay()
				}
		}
		return registry
	}

	/** initializeViewFromModel */
	override func initializeViewFromModel() {
		super.initializeViewFromModel()
		longPressGesture.enabled = button.longPressCommand != nil
		labelView.attributedText = button.title
		invalidateIntrinsicContentSize()
		setNeedsDisplay()
	}

	override var editingMode: RemoteElement.BaseType {
		didSet {
			tapGesture.enabled = !isEditing
			longPressGesture.enabled = !isEditing
		}
	}

	/**
	drawContentInContext:inRect:

	:param: ctx CGContextRef
	:param: rect CGRect
	*/
	override func drawContentInContext(ctx: CGContextRef, inRect rect: CGRect) {
		if let icon = button.icon?.colorImage {
			UIGraphicsPushContext(ctx)
			let insetRect = button.imageEdgeInsets.insetRect(bounds)
      let imageSize = insetRect.size.contains(icon.size)
                        ? icon.size
                        : icon.size.aspectMappedToSize(insetRect.size, binding: true)
			let imageRect = CGRect(x: insetRect.midX - imageSize.width / 2.0,
				                     y: insetRect.midY - imageSize.height / 2.0,
				                     width: imageSize.width,
				                     height: imageSize.height)
			icon.drawInRect(imageRect)
			UIGraphicsPopContext()
		}

	}

}
