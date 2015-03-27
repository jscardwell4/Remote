//
//  TouchTrackingGesture.swift
//  Remote
//
//  Created by Jason Cardwell on 11/20/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

public class TouchTrackingGesture: BlockActionGesture {

  public enum TrackingMode { case Locations, Views }

  public var numberOfTrackingTouches: Int = 1 { didSet { if numberOfTrackingTouches < 1 { numberOfTrackingTouches = 1 } } }
  public var numberOfAnchoringTouches: Int = 0 { didSet { if numberOfAnchoringTouches < 0 { numberOfAnchoringTouches = 0 } } }
  public var trackingMode: TrackingMode = .Locations

  private var trackingTouches:  OrderedSet<UITouch> = []
  private var anchoringTouches: OrderedSet<UITouch> = []
  private var touchLocations:   OrderedSet<CGPoint> = []
  private var trackingViews:    OrderedSet<UIView>  = []

  private var anchored: Bool { return anchoringTouches.count == numberOfAnchoringTouches }
  private var tracking: Bool { return trackingTouches.count == numberOfTrackingTouches }

  /**
  addLocations:

  :param: locations [CGPoint]

  :returns: Bool Whether new locations (TrackingMode.Locations) or views (TrackingMode.Views) were actually added
  */
  private func addLocations(locations: [CGPoint]) -> Bool {
    let locationCount = touchLocations.count
    touchLocations ∪= locations
    let viewCount = trackingViews.count
    trackingViews ∪= touchedViewsForLocations(locations)
    switch trackingMode {
      case .Locations: return touchLocations.count > locationCount
      case .Views:     return trackingViews.count > viewCount
    }
  }

  /**
  touchedViewsForLocations:

  :param: locations OrderedSet<CGPoint>

  :returns: OrderedSet<UIView>
  */
  private func touchedViewsForLocations(locations: [CGPoint]) -> OrderedSet<UIView> {
    return OrderedSet(compressed(locations.map{self.view!.window!.hitTest($0, withEvent: nil)}))
  }

  /**
  touchedViews

  :returns: OrderedSet<UIView>
  */
  public func touchedViews() -> OrderedSet<UIView> {
    return view == nil ? [] : OrderedSet(compressed(touchLocations.array.map{self.view!.window!.hitTest($0, withEvent: nil)}))
  }

  /**
  touchedSubviewsInView:includeView:

  :param: view UIView
  :param: includeView (UIView) -> Bool

  :returns: OrderedSet<UIView>
  */
  public func touchedSubviewsInView(view: UIView, includeView: (UIView) -> Bool) -> OrderedSet<UIView> {
    return touchedSubviewsInView(view).filter(includeView)
  }

  /**
  touchedSubviewsInView:

  :param: view UIView

  :returns: OrderedSet<UIView>
  */
  public func touchedSubviewsInView(view: UIView) -> OrderedSet<UIView> {
    return touchedViews().filter({$0.isDescendantOfView(view)})
  }

  /**
  touchLocationsInView:

  :param: view UIView

  :returns: [CGPoint]
  */
  public func touchLocationsInView(view: UIView) -> OrderedSet<CGPoint> {
    return touchLocations.map{view.convertPoint($0, fromView: nil)}
  }

  /** reset */
  public override func reset() {
    touchLocations.removeAll()
    anchoringTouches.removeAll()
    trackingTouches.removeAll()
    trackingViews.removeAll()
    state = .Possible
  }

  /**
  touchesBegan:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  override public func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    let beginningTouches = (touches as NSSet).allObjects as! [UITouch]
    if !anchored {
      if beginningTouches.count == numberOfAnchoringTouches { anchoringTouches ∪= beginningTouches }
      else { state = .Failed}
    } else if !tracking {
      if beginningTouches.count == numberOfTrackingTouches {
        trackingTouches ∪= beginningTouches
        state = .Began
        addLocations(beginningTouches.map{$0.locationInView(nil)})
      } else { state = .Failed }
    }
  }

  /**
  touchesMoved:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    let movedTouches = (touches as NSSet).allObjects as! [UITouch]
    if (anchoringTouches ∩ movedTouches).count != 0 {
      state = tracking ? .Ended : .Failed
    } else if trackingTouches ⊃ movedTouches {
      if addLocations(movedTouches.map{$0.locationInView(nil)}) { state = .Changed }
    }
  }

  /**
  touchesCancelled:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    if (anchoringTouches ∪ trackingTouches) ⊃ (touches as NSSet).allObjects as! [UITouch] { state = .Cancelled }
  }

  /**
  touchesEnded:withEvent:

  :param: touches NSSet
  :param: event UIEvent
  */
  public override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    if (anchoringTouches ∪ trackingTouches) ⊃ (touches as NSSet).allObjects as! [UITouch] { state = anchored && tracking ? .Ended : .Failed }
  }

}
