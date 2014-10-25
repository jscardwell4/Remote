//
//  MSPanGestureRecognizer.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/23/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public class MSPanGestureRecognizer: UIPanGestureRecognizer {

  public var confineToView: Bool = false

  /**
  validTouches:withEvent:

  :param: touches NSSet
  :param: event UIEvent

  :returns: Bool
  */
  private func validTouches(touches: NSSet, withEvent event: UIEvent) -> Bool {
    if confineToView && view != nil {
      for touch in touches.allObjects as [UITouch] {
        if !view!.pointInside(touch.locationInView(view!), withEvent: event) {
          return false
        }
      }
    }
    return true
  }

  /**
  canPreventGestureRecognizer:

  :param: preventedGestureRecognizer UIGestureRecognizer!

  :returns: Bool
  */
  public override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer!) -> Bool {
    return !(confineToView && preventedGestureRecognizer is UIPanGestureRecognizer)
  }

  /**
  touchesBegan:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    if validTouches(touches, withEvent: event) { super.touchesBegan(touches, withEvent: event) }
    else { state = .Cancelled }
  }

  /**
  touchesMoved:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    if validTouches(touches, withEvent: event) { super.touchesMoved(touches, withEvent: event) }
    else { state = .Cancelled }
  }

}
