//
//  PanGesture.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/23/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public class PanGesture: ConfiningBlockActionGesture {

  public enum Axis { case Default, Vertical, Horizontal }

  public var axis = Axis.Default

  private struct TrackingData: CustomStringConvertible {
    var timestamp: NSTimeInterval = 0
    var centroid: CGPoint = nil
    var velocity: CGVector = nil
    var isValid: Bool { return centroid.isNull == false }
    mutating func reset() { timestamp = 0; centroid = nil; velocity = nil }
    init(timestamp: NSTimeInterval? = nil, centroid: CGPoint? = nil, velocity: CGVector? = nil) {
      if let timestamp = timestamp { self.timestamp = timestamp }
      if let centroid = centroid { self.centroid = centroid }
      if let velocity = velocity { self.velocity = velocity }
    }
    var description: String { return "{timestamp: \(timestamp); centroid: \(centroid); velocity: \(velocity)}" }
  }

  /**
  Returns `p`, {p.x, 0}, or {0, p.y} depending on the value of `axis`

  - parameter p: CGPoint

  - returns: CGPoint
  */
  private func filteredPoint(p: CGPoint) -> CGPoint {
    switch axis {
      case .Vertical:   return CGPoint(x: 0, y: p.y)
      case .Horizontal: return CGPoint(x: p.x, y: 0)
      case .Default:    return p
    }
  }

  /**
  Returns `v`, {v.dx, 0}, or {0, v.dy} depending on the value of `axis`

  - parameter v: CGVector

  - returns: CGVector
  */
  private func filteredVector(v: CGVector) -> CGVector {
    switch axis {
    case .Vertical:   return CGVector(dx: 0, dy: v.dy)
    case .Horizontal: return CGVector(dx: v.dx, dy: 0)
    case .Default:    return v
    }
  }

  /// MARK: - Mimicking UIPanGestureRecognizer
  ////////////////////////////////////////////////////////////////////////////////

  /**
  The minimum number of fingers that can be touching the view for this gesture to be recognized.

  The default value is `1`
  */
  public var minimumNumberOfTouches: Int = 1 { didSet { minimumNumberOfTouches  = max(1, min(10, minimumNumberOfTouches)) } }

  /**
  The maximum number of fingers that can be touching the view for this gesture to be recognized.

  The default value is `10`.
  */
  public var maximumNumberOfTouches: Int = 10 { didSet { maximumNumberOfTouches = max(1, min(10, maximumNumberOfTouches)) } }

  /**
  The translation of the pan gesture in the coordinate system of the specified view.

  The x and y values report the total translation over time. They are not delta values from the last time that the translation
  was reported. Apply the translation value to the state of the view when the gesture is first recognized—do not concatenate the
  value each time the handler is called.

  - parameter v: UIView? = nil The view in whose coordinate system the translation of the pan gesture should be computed. If you want to
  adjust a view's location to keep it under the user's finger, request the translation in that view's superview's coordinate
  system.

  - returns: CGPoint A point identifying the new location of a view in the coordinate system of its designated superview.
  */
  public func translationInView(var v: UIView? = nil) -> CGPoint {
    if v == nil { v = view }
    let initial = v == view
                    ? initialData.centroid
                    : v!.convertPoint(initialData.centroid, fromView: view)
    let centroid = v == view
                     ? currentData.centroid
                     : v!.convertPoint(currentData.centroid, fromView: view)
    MSLogDebug("translation = \(centroid - initial); filtered = \(filteredPoint(centroid - initial))")
    return filteredPoint(centroid - initial)
  }

  /**
  Sets the translation value in the coordinate system of the specified view.

  Changing the translation value resets the velocity of the pan.

  - parameter translation: CGPoint A point that identifies the new translation value.
  - parameter v: UIView A view in whose coordinate system the translation is to occur.
  */
//  public func setTranslation(translation: CGPoint, inView v: UIView) {
//    initialData.centroid = v == view ? translation : v.convertPoint(translation, toView: view)
//  }

  /**
  The velocity of the pan gesture in the coordinate system of the specified view.

  - parameter view: UIView! The view in whose coordinate system the velocity of the pan gesture is computed.

  - returns: CGVector The velocity of the pan gesture, which is expressed in points per second. The velocity is broken into
  horizontal and vertical components.
  */
  public func velocityInView(view: UIView) -> CGVector {
    MSLogDebug("velocity = \(currentData.velocity); filtered = \(filteredVector(currentData.velocity))")
    return filteredVector(currentData.velocity)
  }


  /**
  timestampForTouches:

  - parameter touches: C

  - returns: NSTimeInterval
  */
  private func timestampForTouches<C:CollectionType where C.Generator.Element == UITouch, C.Index.Distance == Int>
    (touches: C) -> NSTimeInterval
  {
    assert(touches.count > 0)
    return touches.map {$0.timestamp}.maxElement()!
  }

  /// MARK: -

  private(set) var panRecognized: Bool = false

  public var requiredMovement: CGFloat = 10.0

  private var panningTouches: Set<UITouch> = []

  private var initialData  = TrackingData()
  private var currentData  = TrackingData()
  private var previousData = TrackingData()

  /** updateData */
  private func updateData() {
    assert(panningTouches.count > 0)

    let data = TrackingData(timestamp: timestampForTouches(panningTouches), centroid: centroidForTouches(panningTouches))
    MSLogDebug("data = \(data)")

    switch state {
      case .Possible where initialData.isValid:
        if filteredPoint(initialData.centroid - data.centroid).absolute.max >= requiredMovement {
          previousData = initialData
          currentData = data
          let delta = CGFloat(currentData.timestamp - previousData.timestamp)
          currentData.velocity = CGVector((currentData.centroid - previousData.centroid) / delta)
          panRecognized = true
          MSLogDebug(".Possible where initialData.isValid: previousData = \(previousData), currentData = \(currentData)")
          state = .Began
        }
      case .Possible:
        initialData.timestamp = timestampForTouches(panningTouches)
        initialData.centroid = centroidForTouches(panningTouches)
        MSLogDebug(".Possible: initialData = \(initialData)")
      case .Began, .Changed:
        previousData = currentData
        currentData = data
        let delta = CGFloat(currentData.timestamp - previousData.timestamp)
        currentData.velocity = CGVector((currentData.centroid - previousData.centroid) / delta)
        MSLogDebug(".Began, .Changed: previousData = \(previousData), currentData = \(currentData)")
        if filteredVector(currentData.velocity).absolute.max > 0 {
          state = .Changed
        }
      case .Ended, .Failed, .Cancelled:
        MSLogDebug(".Ended, .Failed, .Cancelled")
        break
    }

  }

  /// MARK: - UIGestureRecognizer
  ////////////////////////////////////////////////////////////////////////////////

 /** reset */
  public override func reset() {
    state = .Possible
    panningTouches.removeAll()
    initialData.reset()
    currentData.reset()
    previousData.reset()
    panRecognized = false
  }

  /**
  touchesBegan:withEvent:

  - parameter touches: Set<UITouch>
  - parameter event: UIEvent
  */
  public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
    guard panningTouches.count == 0
      && (minimumNumberOfTouches ... maximumNumberOfTouches).contains(touches.count)
      && validateTouchLocations(touches, withEvent: event) else { state = .Failed; return }

    panningTouches = touches
    updateData()
  }

  /**
  touchesMoved:withEvent:

  - parameter touches: Set<UITouch>
  - parameter event: UIEvent
  */
  public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
    guard panningTouches.isSubsetOf(touches) else { return }
    guard validateTouchLocations(panningTouches, withEvent: event) else { state = .Failed; return }
    updateData()

    // TODO: move to failed state if movement is in the wrong direction

  }

  /**
  touchesCancelled:withEvent:

  - parameter touches: Set<UITouch>
  - parameter event: UIEvent
  */
  public override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
    guard panningTouches.intersect(touches).count > 0 else { return }
    state = .Cancelled
  }

  /**
  touchesEnded:withEvent:

  - parameter touches: NSSet
  - parameter event: UIEvent
  */
  public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
    guard panRecognized && panningTouches.intersect(touches).count > 0 else { return }
    guard validateTouchLocations(panningTouches, withEvent: event) else { state = .Failed; return }

//    updateData()
    MSLogDebug("final data = \(currentData)")
    state = .Ended
  }
}
