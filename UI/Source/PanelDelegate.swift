//
//  PanelDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 5/4/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

/**
Responsible for maintaining the swipe gestures and constraints for panels on the same axis.
Also used to keep weak references to the panels
*/
class PanelDelegate {

  typealias Axis = Remote.PanelAssignment.Location.Axis

  let axis: Axis

  typealias Location = Remote.PanelAssignment.Location

  let location: Location
  let opposingLocation: Location

  typealias Trigger = Remote.PanelAssignment.Trigger

  let trigger: Trigger

  let gesture: UISwipeGestureRecognizer
  let opposingGesture: UISwipeGestureRecognizer
  var gestures: [UISwipeGestureRecognizer] { return [gesture, opposingGesture] }

  /**
  setView:forLocation:

  :param: v ButtonGroupView?
  :param: l Location
  */
  func setView(v: ButtonGroupView?, forLocation l: Location) {
    if l == location { view = v } else if l == opposingLocation { opposingView = v }
  }

  static let ViewTuckedIdentifier = createIdentifier(PanelDelegate.self, "View", "Tucked")
  static let ViewUntuckedIdentifier = createIdentifier(PanelDelegate.self, "View", "Untucked")
  static let OpposingViewTuckedIdentifier = createIdentifier(PanelDelegate.self, "OpposingView", "Tucked")
  static let OpposingViewUntuckedIdentifier = createIdentifier(PanelDelegate.self, "OpposingView", "Untucked")

  weak var view: ButtonGroupView? {
    didSet {
      if let v = view, superV = v.superview {
        switch location {
          case .Left:
            viewTuckedConstraint = NSLayoutConstraint(v.right => superV.left)
            viewUntuckedConstraint = NSLayoutConstraint(v.left => superV.left)
          case .Right:
            viewTuckedConstraint = NSLayoutConstraint(v.left => superV.right)
            viewUntuckedConstraint = NSLayoutConstraint(v.right => superV.right)
          case .Top:
            viewTuckedConstraint = NSLayoutConstraint(v.bottom => superV.top)
            viewUntuckedConstraint = NSLayoutConstraint(v.top => superV.top)
          case .Bottom:
            viewTuckedConstraint = NSLayoutConstraint(v.top => superV.bottom)
            viewUntuckedConstraint = NSLayoutConstraint(v.bottom => superV.bottom)
        }
        viewTuckedConstraint?.active = true
      } else {
        viewTuckedConstraint?.active = false
        viewTuckedConstraint = nil
        viewUntuckedConstraint?.active = false
        viewUntuckedConstraint = nil
      }
      updateGestures()
    }
  }

  weak var opposingView: ButtonGroupView? {
    didSet {
      if let v = opposingView, superV = v.superview {
        switch opposingLocation {
          case .Left:
            opposingViewTuckedConstraint = NSLayoutConstraint(v.right => superV.left)
            opposingViewUntuckedConstraint = NSLayoutConstraint(v.left => superV.left)
          case .Right:
            opposingViewTuckedConstraint = NSLayoutConstraint(v.left => superV.right)
            opposingViewUntuckedConstraint = NSLayoutConstraint(v.right => superV.right)
          case .Top:
            opposingViewTuckedConstraint = NSLayoutConstraint(v.bottom => superV.top)
            opposingViewUntuckedConstraint = NSLayoutConstraint(v.top => superV.top)
          case .Bottom:
            opposingViewTuckedConstraint = NSLayoutConstraint(v.top => superV.bottom)
            opposingViewUntuckedConstraint = NSLayoutConstraint(v.bottom => superV.bottom)

        }
        opposingViewTuckedConstraint?.active = true
      } else {
        opposingViewTuckedConstraint?.active = false
        opposingViewTuckedConstraint = nil
        opposingViewUntuckedConstraint?.active = false
        opposingViewUntuckedConstraint = nil
      }
      updateGestures()
    }
  }

  enum ViewState: String { case Default = "Default", ShowingView = "ShowingView", ShowingOpposingView = "ShowingOpposingView" }

  var viewState: ViewState = .Default

  /**
  updateViewStateForSwipeLocation:

  :param: loc Location
  */
  func updateViewStateForSwipeLocation(loc: Location) {
    switch viewState {
    case .ShowingView where loc == location:
      viewUntuckedConstraint?.active = false
      viewTuckedConstraint?.active = true
      viewState = .Default
    case .ShowingOpposingView where loc == opposingLocation:
      opposingViewUntuckedConstraint?.active = false
      opposingViewTuckedConstraint?.active = true
      viewState = .Default
    case .Default where loc == location:
      opposingViewTuckedConstraint?.active = false
      opposingViewUntuckedConstraint?.active = true
      viewState = .ShowingOpposingView
    case .Default where loc == opposingLocation:
      viewTuckedConstraint?.active = false
      viewUntuckedConstraint?.active = true
      viewState = .ShowingView
    default:
      break
    }
  }

  var viewTuckedConstraint: NSLayoutConstraint? {
    didSet { viewTuckedConstraint?.identifier = PanelDelegate.ViewTuckedIdentifier }
  }
  var viewUntuckedConstraint: NSLayoutConstraint? {
    didSet { viewUntuckedConstraint?.identifier = PanelDelegate.ViewUntuckedIdentifier }
  }
  var opposingViewTuckedConstraint: NSLayoutConstraint? {
    didSet { opposingViewTuckedConstraint?.identifier = PanelDelegate.OpposingViewTuckedIdentifier }
  }
  var opposingViewUntuckedConstraint: NSLayoutConstraint? {
    didSet { opposingViewUntuckedConstraint?.identifier = PanelDelegate.OpposingViewUntuckedIdentifier }
  }

  /** updateGestures */
  private func updateGestures() { if view == nil && opposingView == nil { disableGestures() } else { enableGestures() } }

  /** enableGestures */
  func enableGestures() { gesture.enabled = true; opposingGesture.enabled = true }

  /** disableGestures */
  func disableGestures() { gesture.enabled = false; opposingGesture.enabled = false }

  /**
  init:trigger:

  :param: a Axis
  :param: t Trigger
  */
  init(axis a: Axis, trigger t: Trigger) {
    axis = a; trigger = t

    switch axis {
    case .Horizontal: location = .Left; opposingLocation = .Right
    case .Vertical:   location = .Top; opposingLocation = .Bottom
    }

    gesture = UISwipeGestureRecognizer()
    gesture.direction = location.UISwipeGestureRecognizerDirectionValue
    gesture.numberOfTouchesRequired = trigger.rawValue
    gesture.enabled = false

    opposingGesture = UISwipeGestureRecognizer()
    opposingGesture.direction = opposingLocation.UISwipeGestureRecognizerDirectionValue
    opposingGesture.numberOfTouchesRequired = trigger.rawValue
    opposingGesture.enabled = false

  }

}

extension PanelDelegate: Printable {
  var description: String {
    var result = "PanelDelegate:\n"
    result += "\taxis = \(axis.rawValue)\n"
    result += "\tlocation = \(location)\n"
    result += "\topposingLocation = \(opposingLocation)\n"
    result += "\ttrigger = \(trigger)\n"
    result += "\tviewState = \(viewState.rawValue)\n"
    result += "\tviewTuckedConstraint = " +
      (viewTuckedConstraint == nil
        ? "nil\n"
        : "\(PseudoConstraint(constraint: viewTuckedConstraint!).description)" + (viewTuckedConstraint!.active
                                                                                   ? " (active)\n"
                                                                                   : "\n"))
    result += "\tviewUntuckedConstraint = " +
      (viewUntuckedConstraint == nil
        ? "nil\n"
        : "\(PseudoConstraint(constraint: viewUntuckedConstraint!).description)" + (viewUntuckedConstraint!.active
                                                                                   ? " (active)\n"
                                                                                   : "\n"))
    result += "\topposingViewTuckedConstraint = " +
      (opposingViewTuckedConstraint == nil
        ? "nil\n"
        : "\(PseudoConstraint(constraint: opposingViewTuckedConstraint!).description)" + (opposingViewTuckedConstraint!.active
                                                                                   ? " (active)\n"
                                                                                   : "\n"))
    result += "\topposingViewUntuckedConstraint = " +
      (opposingViewUntuckedConstraint == nil
        ? "nil\n"
        : "\(PseudoConstraint(constraint: opposingViewUntuckedConstraint!).description)" + (opposingViewUntuckedConstraint!.active
                                                                                   ? " (active)\n"
                                                                                   : "\n"))
    result += "\tview = \(toString(view))\n"
    result += "\topposingView = \(toString(opposingView))\n"
    result += "\tgesture = \(gesture)\n"
    result += "\topposingGesture = \(opposingGesture)"
    return result
  }
}

