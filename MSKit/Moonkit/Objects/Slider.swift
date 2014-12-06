//
//  Slider.swift
//  MSKit
//
//  Created by Jason Cardwell on 12/6/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public class Slider: UISlider {


  /**
  currentThumbFrame

  :returns: CGRect
  */
  private func currentThumbFrame() -> CGRect {
    return thumbRectForBounds(bounds, trackRect: trackRectForBounds(bounds), value: value)
  }

  /** forceThumbUpdate */
  func forceThumbUpdate() { setThumbImage(generateThumbImage?(self), forState: .Normal) }

  public var currentThumbSize: CGSize { return currentThumbFrame().size }
  public var generateThumbImage: ((Slider) -> UIImage)? {
    didSet {
      if generateThumbImage != nil {
        addTarget(self, action: "forceThumbUpdate", forControlEvents: .ValueChanged)
      } else {
        removeTarget(self, action: "forceThumbUpdate", forControlEvents: .ValueChanged)
      }
    }
  }

}
