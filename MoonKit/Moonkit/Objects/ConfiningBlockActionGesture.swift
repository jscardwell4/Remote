//
//  ConfiningBlockActionGesture.swift
//  Remote
//
//  Created by Jason Cardwell on 11/19/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public class ConfiningBlockActionGesture: BlockActionGesture {

  public var confineToView: Bool = false

  /**
  validateTouchLocations:withEvent:

  - parameter touches: [UITouch]
  - parameter event: UIEvent

  - returns: Bool
  */
  internal func validateTouchLocations(touches: [UITouch], withEvent event: UIEvent) -> Bool {
    if !confineToView { return true }
    else {
      let pointsInside = touches.filter {
        touch in self.view!.pointInside(touch.locationInView(self.view!), withEvent: event)
      }
      return touches.count == pointsInside.count
    }
  }


}
