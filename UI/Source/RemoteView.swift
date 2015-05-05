//
//  RemoteView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

public final class RemoteView: RemoteElementView {

  /**
  intrinsicContentSize

  :returns: CGSize
  */
  override public func intrinsicContentSize() -> CGSize { return UIScreen.mainScreen().bounds.size }

  public var remote: Remote { return model as! Remote }

  override public var resizable: Bool { get { return false } set {} }
  override public var moveable: Bool { get { return false } set {} }

  public typealias PanelAssignment = Remote.PanelAssignment
  public typealias Trigger = PanelAssignment.Trigger
  public typealias Location = PanelAssignment.Location
  public typealias Axis = Location.Axis

  private(set) var panelViews: [UUIDIndex:PanelAssignment] = [:]

  private var panelDelegates: [Trigger:[Axis:PanelDelegate]] = [.OneFinger: [:], .TwoFinger: [:], .ThreeFinger: [:]]

	/** initializeIVARs */
	override func initializeIVARs() {
		setContentCompressionResistancePriority(1000.0, forAxis: .Horizontal)
		setContentCompressionResistancePriority(1000.0, forAxis: .Vertical)
		setContentHuggingPriority(1000.0, forAxis: .Horizontal)
		setContentHuggingPriority(1000.0, forAxis: .Vertical)
		super.initializeIVARs()
    MSLogVerbose("panels for remote named '\(model.name)': \((model as! Remote).panels)")
	}

  /** attachGestureRecognizers */
  override func attachGestureRecognizers() {
    super.attachGestureRecognizers()
    apply(flatMap(flatMap(panelDelegates.values.array){$0.values.array}){$0.gestures}) {
      self.addGestureRecognizer($0)
      $0.addTarget(self, action: "handleSwipe:")
    }
  }

  /**
  handleSwipe:

  :param: gesture UISwipeGestureRecognizer
  */
  func handleSwipe(gesture: UISwipeGestureRecognizer) {
    assert(contains(1...3, gesture.numberOfTouchesRequired))

    let trigger = Trigger(rawValue: gesture.numberOfTouchesRequired)
    let location: Location?

    switch gesture.direction {
      case let d where d == .Up:    location = .Top
      case let d where d == .Down:  location = .Bottom
      case let d where d == .Left:  location = .Left
      case let d where d == .Right: location = .Right
      default:                      location = nil
    }

    if let trigger = trigger, location = location {
      actionTriggeredForPanelAssignment(PanelAssignment(location: location, trigger: trigger))
    }

  }

  /** updateConstraints */
  override public func updateConstraints() {
    super.updateConstraints()
    MSLogDebug(description)
  }

  /**
  actionTriggeredForPanelAssignment:

  :param: panelAssignment PanelAssignment
  */
  func actionTriggeredForPanelAssignment(assignment: PanelAssignment) {
    if let delegate = panelDelegates[assignment.trigger]?[assignment.location.axis] {
      setNeedsLayout()
      UIView.animateWithDuration(0.25) { delegate.updateViewStateForSwipeLocation(assignment.location); self.layoutIfNeeded() }
    }
  }

  /**
  addSubelementView:

  :param: view RemoteElementView
  */
  override public func addSubelementView(view: RemoteElementView) {
    if let buttonGroupView = view as? ButtonGroupView {
      super.addSubelementView(view)
      if let assignment = findFirst(remote.panels, {$1 == buttonGroupView.model.uuidIndex})?.0 {
        var triggerEntry = panelDelegates[assignment.trigger]!

        let delegate: PanelDelegate
        if let entry = triggerEntry[assignment.location.axis] { delegate = entry }
        else {
          delegate = PanelDelegate(axis: assignment.location.axis, trigger: assignment.trigger)
          apply(delegate.gestures) { $0.addTarget(self, action: "handleSwipe:"); self.addGestureRecognizer($0) }
          triggerEntry[assignment.location.axis] = delegate
          panelDelegates[assignment.trigger] = triggerEntry
        }

        buttonGroupView.tuckAction = {self.actionTriggeredForPanelAssignment(assignment)}
        delegate.setView(buttonGroupView, forLocation: assignment.location)
        panelViews[buttonGroupView.model.uuidIndex] = assignment
      }
    }
  }

  /**
  removeSubelementView:

  :param: view RemoteElementView
  */
  override public func removeSubelementView(view: RemoteElementView) {
    if let buttonGroupView = view as? ButtonGroupView {
      if let assignment = panelViews[buttonGroupView.model.uuidIndex],
        var delegates = panelDelegates[assignment.trigger],
        let delegate = delegates[assignment.location.axis]
      {
        delegate.setView(nil, forLocation: assignment.location)
        if delegate.view == nil && delegate.opposingView == nil {
          removeGestureRecognizer(delegate.gesture)
          removeGestureRecognizer(delegate.opposingGesture)
          var panelDelegates = self.panelDelegates
          delegates[assignment.location.axis] = nil
          panelDelegates[assignment.trigger] = delegates
          self.panelDelegates = panelDelegates
        }
        panelViews[buttonGroupView.model.uuidIndex] = nil
      }
      super.removeSubelementView(view)
    }
  }

  override public var description: String {
    var result = super.description
    result += "\n\tpanelDelegates = "
    let delegates = flatMap(panelDelegates.values.array, {$0.values.array}).map({$0.description.indentedBy(8)})
    if delegates.isEmpty { result += "nil" }
    else { result += "{\n" + ",\n\n".join(delegates) + "\n\t}" }
    return result
  }

  /**
  drawRect:

  :param: rect CGRect
  */
  override public func drawRect(rect: CGRect) {
    if let image = backgroundImage {
      let attrs = Painter.Attributes(rect: rect, alpha: CGFloat(backgroundImageAlpha))
      Painter.drawImage(image, withAttributes: attrs)
    }
  }

}
