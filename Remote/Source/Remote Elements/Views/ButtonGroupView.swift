//
//  ButtonGroupView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ButtonGroupView: RemoteElementView {

	var label: UILabel!

	weak var tuckedConstraint: NSLayoutConstraint?
	weak var untuckedConstraint: NSLayoutConstraint?
	weak var tuckGesture: MSSwipeGestureRecognizer?
	weak var untuckGesture: MSSwipeGestureRecognizer?



	/** tuck */
	func tuck() {
		if model.isPanel && tuckedConstraint != nil && untuckedConstraint != nil {
			UIView.animateWithDuration(0.25, animations: {
				self.untuckedConstraint.priority = 1
				self.tuckedConstraint.priority = 999
				self.window.setNeedsUpdateConstraints()
				self.setNeedsLayout()
				self.layoutIfNeeded()
				},
				completion: {
					(finished: Bool) -> Void in
						self.tuckGesture.enabled = false
						self.untuckGesture.enabled = true
				})
		}
	}

	/** untuck */
	func untuck() {
		if model.isPanel && tuckedConstraint != nil && untuckedConstraint != nil {
			UIView.animateWithDuration(0.25, animations: {
				self.untuckedConstraint.priority = 999
				self.tuckedConstraint.priority = 1
				self.window.setNeedsUpdateConstraints()
				self.setNeedsLayout()
				self.layoutIfNeeded()
				},
				completion: {
					(finished: Bool) -> Void in
						self.tuckGesture.enabled = true
						self.untuckGesture.enabled = false
				})
		}
	}

	/** updateConstraints */
	override func updateConstraints() {
		removeAllConstraints()
		super.updateConstraints()
		stretchSubview(label)
	}

	/**
	handleSwipe:

	:param: gesture UISwipeGestureRecognizer
	*/
	func handleSwipe(gesture: UISwipeGestureRecognizer) {
		if gesture.state == .Ended {
			if gesture === tuckGesture { tuck() }
			else if gesture === untuckGesture { untuck() }
		}
	}

	/** attachTuckGestures */
	func attachTuckGestures() {
		let tuckGesture = MSSwipeGestureRecognizer(target: self, action: "handleSwipe:")
		tuckGesture.nametag = "'\(name)'-tuck"
		tuckGesture.enabled = false
		tuckGesture.direction = tuckDirection
		tuckGesture.quadrant = quadrant
		window?.addGestureRecognizer(tuckGesture)
		self.tuckGesture = tuckGesture

		let untuckGesture = MSSwipeGestureRecognizer(target: self, action: "handleSwipe:")
		untuckGesture.nametag = "'\(name)'-untuck"
		untuckGesture.enabled = false
		untuckGesture.direction = untuckDirection
		untuckGesture.quadrant = quadrant
		window?.addGestureRecognizer(untuckGesture)
		self.untuckGesture = untuckGesture
	}

	/** didMoveToWindow */
	override func didMoveToWindow() {
		if model.isPanel && !editing && window != nil { attachTuckGestures() }
		super.didMoveToWindow()
	}

	/**
	kvoRegistration

	:returns: [String:(MSKVOReceptionist) -> Void]
	*/
	override func kvoRegistration() -> [String:(MSKVOReceptionist) -> Void] {
		let registry = super.kvoRegistration()
		registry["label"] = {
			(receptionist: MSKVOReceptionist) -> Void in
				if let v = receptionist.observer as? ButtonGroupView {
					if let text = receptionist.change[NSKeyValueChangeNewKey] as? NSAttributedString { v.label.attributedText = text }
					else { v.label.attributedText = nil }
				}
		}
		return registry
	}

	/** initializeIVARs */
	override func initializeIVARs() {
		super.initializeIVARs()
		shrinkwrap = true
		resizable = true
		moveable = true
		if model.role & REButtonGroupRoleToolbar == REButtonGroupRoleToolbar {
			setContentCompressionResistancePriority(.Required, forAxis: .Horizontal)
			setContentCompressionResistancePriority(.Required, forAxis: .Vertical)
		}
	}

	/** didMoveToSuperview */
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		if superview != nil && model.isPanel && !editing {
			var attribute1 = NSLayoutAttribute.NotAnAttribute
			var attribute2 = attribute1
			switch model.panelLocation {
				case .Top:
					attribute1 = .Bottom
					attribute2 = .Top
					tuckDirection = .Up
					untuckDirection = .Down
					quadrant = .Up

				case .Bottom:
					attribute1 = .Top
					attribute2 = .Bottom
					tuckDirection = .Down
					untuckDirection = .Up
					quadrant = .Down

				case .Left:
					attribute1 = .Right
					attribute2 = .Left
					tuckDirection = .Left
					untuckDirection = .Right
					quadrant = .Left

				case .Right:
					attribute1 = .Left
					attribute2 = .Right
					tuckDirection = .Right
					untuckDirection = .Left
					quadrant = .Right

				default:
					break
			}

			let tuckedConstraint = NSLayoutConstraint(item: self,
				                                        attribute: attribute1,
				                                        relatedBy: .Equal,
				                                        toItem: superview,
				                                        attribute: attribute2,
				                                        multiplier: 1.0,
				                                        constant: 0.0)
			tuckedConstraint.priority = 999
			self.tuckedConstraint = tuckedConstraint

			let untuckedConstraint = NSLayoutConstraint(item: self,
				                                        attribute: attribute2,
				                                        relatedBy: .Equal,
				                                        toItem: superview,
				                                        attribute: attribute1,
				                                        multiplier: 1.0,
				                                        constant: 0.0)
			untuckedConstraint.priority = 1
			self.untuckedConstraint = untuckedConstraint

			superview.addConstraints([tuckedConstraint, untuckedConstraint])
		}
	}

	/**
	addSubelementView:

	:param: view RemoteElementView
	*/
	override func addSubelementView(view: RemoteElementView) {
		if locked {
			view.resizable = false
			view.moveable = false
		}
		if let buttonView = view as? ButtonView {
			if buttonView.role == REButtonRoleTuck {
				buttonView.tapAction = {self.tuck()}
			}
		}
		super.addSubelementView(view)
	}

	/** addInternalSubviews */
	override func addInternalSubviews() {
		super.addInternalSubviews()
		let label = UILabel.newForAutolayout()
		label.backgroundColor = UIColor.clearColor()
		addViewToContent(label)
		self.label = label
	}

	override var editingMode: REEditingMode {
		didSet {
			resizable = editingMode == .NotEditing
			moveable = editingMode == .NotEditing
			subelementInteractionEnabled = editingMode != .Remote
		}
	}

	/**
	intrinsicContentSize

	:returns: CGSize
	*/
	override func intrinsicContentSize() -> CGSize {
		if model.role == .Toolbar { return CGSize(width: UIScreen.mainScreen().bounds.width, height: 44.0) }
		else { return CGSize(square: UIViewNoIntrinsicMetric) }
	}

	/**
	buttonViewDidExecute:

	:param: buttonView ButtonView
	*/
	func buttonViewDidExecute(buttonView: ButtonView) {
		if model.autohide { dispatch_after(when: 1.0, queue: dispatch_get_main_queue()) { self.tuck() } }
	}

}
