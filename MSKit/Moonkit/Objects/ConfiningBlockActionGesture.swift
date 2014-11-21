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

  :param: touches [UITouch]
  :param: event UIEvent

  :returns: Bool
  */
  internal func validateTouchLocations(touches: [UITouch], withEvent event: UIEvent) -> Bool {
    return !confineToView
           || (touches.filter{self.view!.pointInside($0.locationInView(self.view!), withEvent: event)}).count == touches.count
  }


}
