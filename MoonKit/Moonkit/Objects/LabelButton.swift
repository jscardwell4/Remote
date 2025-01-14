//
//  LabelButton.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/23/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import UIKit

public class LabelButton: UILabel {

  private var visualEffect = false

  public override func didMoveToSuperview() { visualEffect = superview?.superview is UIVisualEffectView }

  private var trackingTouch: UITouch? { didSet { _highlighted = trackingTouch != nil } }

  private var _highlighted = false { didSet { super.highlighted = _highlighted; setNeedsDisplay() } }

  public override var highlighted: Bool { get { return super.highlighted } set {} }

  public typealias Action = (LabelButton) -> Void

  private func initializeIVARs() {
    userInteractionEnabled = true
    MSLogDebug("tintColor = \(toString(tintColor))")
    highlightedTextColor = tintColor // Store initial tintColor into highlightedTextColor
    opaque = false
  }

  public override init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  public var actions: [Action] = []

  public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    if let touches = touches as? Set<UITouch> where trackingTouch == nil { trackingTouch = touches.first }
  }

  public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    if let touches = touches as? Set<UITouch>, trackingTouch = trackingTouch
      where touches.contains(trackingTouch) && !pointInside(trackingTouch.locationInView(self), withEvent: event)
    {
      self.trackingTouch = nil
    }
  }

  public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    if let touches = touches as? Set<UITouch>, trackingTouch = trackingTouch where touches.contains(trackingTouch) {
      if pointInside(trackingTouch.locationInView(self), withEvent: event) { apply(actions) {[unowned self] in $0(self)} }
      self.trackingTouch = nil
    }
  }

  public override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    if let touches = touches as? Set<UITouch>, trackingTouch = trackingTouch where touches.contains(trackingTouch) {
      self.trackingTouch = nil
    }
  }
}
