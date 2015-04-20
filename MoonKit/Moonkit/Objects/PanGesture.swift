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

  /// MARK: - Mimicking UIPanGestureRecognizer
  ////////////////////////////////////////////////////////////////////////////////

  /**
  The minimum number of fingers that can be touching the view for this gesture to be recognized.

  The default value is `1`
  */
  public var minimumNumberOfTouches: Int = 1 { didSet { if minimumNumberOfTouches < 1 { minimumNumberOfTouches = 1 } } }

  /**
  The maximum number of fingers that can be touching the view for this gesture to be recognized.

  The default value is `UINT_MAX`.
  */
  public var maximumNumberOfTouches: Int = 10 {
    didSet {
      if maximumNumberOfTouches < 1 { maximumNumberOfTouches = 1 }
      else if maximumNumberOfTouches > 10 {  maximumNumberOfTouches = 10 }
    }
  }

  /**
  The translation of the pan gesture in the coordinate system of the specified view.

  The x and y values report the total translation over time. They are not delta values from the last time that the translation
  was reported. Apply the translation value to the state of the view when the gesture is first recognized—do not concatenate the
  value each time the handler is called.

  :param: view UIView? The view in whose coordinate system the translation of the pan gesture should be computed. If you want to
  adjust a view's location to keep it under the user's finger, request the translation in that view's superview's coordinate
  system.

  :returns: CGPoint A point identifying the new location of a view in the coordinate system of its designated superview.
  */
  public func translationInView(view: UIView? = nil) -> CGPoint {
    var s = initialPoint
    var c = centroidForTouches(panningTouches.array)
    if view != self.view && view != nil {
      s = view!.convertPoint(s, fromView: self.view)
      c = view!.convertPoint(c, fromView: self.view)
    }
    let translation = c - s
    return translation
  }

  /**
  Sets the translation value in the coordinate system of the specified view.

  Changing the translation value resets the velocity of the pan.

  :param: translation CGPoint A point that identifies the new translation value.
  :param: view UIView! A view in whose coordinate system the translation is to occur.
  */
  public func setTranslation(translation: CGPoint, inView view: UIView) {
    initialPoint = view == self.view ? translation : view.convertPoint(translation, toView: self.view)
  }

  /**
  The velocity of the pan gesture in the coordinate system of the specified view.

  :param: view UIView! The view in whose coordinate system the velocity of the pan gesture is computed.

  :returns: CGPoint The velocity of the pan gesture, which is expressed in points per second. The velocity is broken into
  horizontal and vertical components.
  */
  public func velocityInView(view: UIView) -> CGPoint { return CGPoint(finalVelocity.isNull ? currentVelocity : finalVelocity) }

  /// MARK: -

  private(set) var panRecognized: Bool = false

  public var requiredMovement: CGFloat = 10.0

  private var panningTouches: OrderedSet<UITouch> = [] {
    didSet {
      initialTimestamp = CGFloat(dispatch_time(DISPATCH_TIME_NOW, 0)) / CGFloat(NSEC_PER_SEC)
      initialPoint = centroidForTouches(panningTouches.array)
    }
  }

  private var currentPoint: CGPoint = CGPoint.nullPoint {
    didSet { previousPoint = currentPoint.isNull ? CGPoint.nullPoint : oldValue } }
  private var initialPoint: CGPoint = CGPoint.nullPoint { didSet { currentPoint = initialPoint } }
  private var previousPoint: CGPoint = CGPoint.nullPoint

  private var initialTimestamp: CGFloat = 0.0 { didSet { currentTimestamp = initialTimestamp } }
  private var currentTimestamp: CGFloat = 0.0 { didSet { previousTimestamp = currentTimestamp == 0.0 ? 0.0 : oldValue } }
  private var previousTimestamp: CGFloat = 0.0

  private var finalVelocity: CGVector = CGVector.nullVector
  private var currentVelocity: CGVector = CGVector.nullVector {
    didSet { previousVelocity = currentVelocity.isNull ? CGVector.nullVector : oldValue } }
  private var previousVelocity: CGVector = CGVector.nullVector

  private var time: CGFloat = 0.0 { didSet { previousTime = time == 0.0 ? 0.0 : oldValue } }
  private var previousTime: CGFloat = 0.0

  /** updateVelocity */
  private func updateVelocity() {
    currentTimestamp = CGFloat(dispatch_time(DISPATCH_TIME_NOW, 0)) / CGFloat(NSEC_PER_SEC)
    currentPoint = centroidForTouches(panningTouches.array)
    time = currentTimestamp - previousTimestamp
    currentVelocity = CGVector((currentPoint - previousPoint) / time)
    if !previousVelocity.isNull {
      let deltaTime = time - previousTime
      if deltaTime != 0.0 {
        finalVelocity = ((currentVelocity - previousVelocity) / deltaTime) * time
      }
    }
  }

  /// MARK: - UIGestureRecognizer
  ////////////////////////////////////////////////////////////////////////////////

 /** reset */
  public override func reset() {
    state = .Possible
    panningTouches.removeAll()
    initialPoint = CGPoint.nullPoint
    initialTimestamp = 0.0
    currentVelocity = CGVector.nullVector
    finalVelocity = CGVector.nullVector
    time = 0.0
    panRecognized = false
  }

  /**
  touchesBegan:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    let beginningTouches = (touches as NSSet).allObjects as! [UITouch]
    if panningTouches.count == 0 {
      if contains(minimumNumberOfTouches ... maximumNumberOfTouches, beginningTouches.count) {
        if validateTouchLocations(beginningTouches, withEvent: event) {
          panningTouches = OrderedSet(beginningTouches)
        }
      }
    }

    if panningTouches.count == 0 { state = .Failed }
  }

  /**
  touchesMoved:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    if validateTouchLocations((touches as NSSet).allObjects as! [UITouch], withEvent: event) {
      updateVelocity()
      if panRecognized {
        state = .Changed
      } else if translationInView().absolute.max >= requiredMovement {
        panRecognized = true
        state = .Began
      }
    }
  }

  /**
  touchesCancelled:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    if panningTouches ⊃ ((touches as NSSet).allObjects as! [UITouch]) {
      state = .Cancelled
    }
  }

  /**
  touchesEnded:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    let endedTouches = (touches as NSSet).allObjects as! [UITouch]
    if panningTouches ⊃ endedTouches {
      if !(panRecognized && validateTouchLocations(endedTouches, withEvent: event)) { state = .Failed }
      else {
        updateVelocity()
        state = .Ended
      }
    }
  }
}
