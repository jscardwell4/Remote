//
//  BlockActionGesture.swift
//  MSKit
//
//  Created by Jason Cardwell on 11/18/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public class BlockActionGesture: UIGestureRecognizer {

  public var handler: ((BlockActionGesture) -> Void)?
  private var handlerTimestamp: dispatch_time_t = 0

  /**
  secondsBetween:and:

  :param: stamp1 dispatch_time_t
  :param: stamp2 dispatch_time_t

  :returns: Double
  */
  internal func secondsBetween(stamp1: dispatch_time_t, and stamp2: dispatch_time_t) -> Double {
    return (Double(stamp1) - Double(stamp2)) * Double(NSEC_PER_SEC)
  }

  /**
  secondsSince:

  :param: stamp dispatch_time_t

  :returns: Double
  */
  internal func secondsSince(stamp: dispatch_time_t) -> Double {
    return secondsBetween(dispatch_time(DISPATCH_TIME_NOW, 0), and: stamp)
  }

  /**
  centroidForTouches:

  :param: touches [UITouch]

  :returns: CGPoint
  */
  internal func centroidForTouches(touches: [UITouch]) -> CGPoint {
    let count = CGFloat(touches.count)
    var point = CGPoint.nullPoint
    if count > 0 {
      var x: CGFloat = 0.0, y: CGFloat = 0.0
      for touch in touches {
        let location = touch.locationInView(view)
        x += location.x
        y += location.y
      }
      point.x = x / count
      point.y = y / count
    }
    return point
  }

  /**
  initWithHandler:

  :param: handler (LongPressGesture) -> Void
  */
  public init(handler: (BlockActionGesture) -> Void) {
    super.init()
    addTarget(self, action: "dispatchHandler")
    self.handler = handler
  }

  public override var state: UIGestureRecognizerState { didSet { dispatchHandler() } }

  /** init */
  public override init() { super.init(); addTarget(self, action: "dispatchHandler") }

  /**
  initWithTarget:action:

  :param: target AnyObject
  :param: action Selector
  */
  public override init(target: AnyObject, action: Selector) {
    super.init(target: target, action: action)
    addTarget(self, action: "dispatchHandler")
  }

  /** dispatchHandler */
  func dispatchHandler() {
    if secondsSince(handlerTimestamp) > 0.1 {
      handlerTimestamp = dispatch_time(DISPATCH_TIME_NOW, 0)
      handler?(self)
    }
  }

}
