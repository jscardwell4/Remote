//
//  ToggleBarButtonItem.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import UIKit

public class ToggleBarButtonItem: UIBarButtonItem {

  public var toggleImage: UIImage?
  public var toggleAction: ((ToggleBarButtonItem) -> Void)?
  public var isToggled: Bool = false

  /** init */
  public override init() {
    super.init()
    super.target = self
    super.action = "toggle"
  }

  /**
  initWithImage:toggledImage:action:

  :param: image UIImage
  :param: toggledImage UIImage
  :param: action (ToggleBarButtonItem) -> Void
  */
  public init(image: UIImage, toggledImage: UIImage, action: (ToggleBarButtonItem) -> Void) {
    super.init(image: image, style: .Plain, target: nil, action: nil)
    toggleAction = action
    toggleImage = toggledImage
  }

  public override var action: Selector { get { return super.action } set { } }

  public override var target: AnyObject? { get { return super.target } set {} }

  /** toggle */
  public func toggle() {
    if let i = image {
      if let t = toggleImage {
        let current = image
        image = toggleImage
        toggleImage = current
      }
    }
    isToggled = !isToggled
    toggleAction?(self)
  }

  /**
  encodeWithCoder:

  :param: aCoder NSCoder
  */
  public override func encodeWithCoder(aCoder: NSCoder) {
    super.encodeWithCoder(aCoder)
    if let t = toggleImage { aCoder.encodeObject(t, forKey: "toggleImage") }
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) {
    toggleImage = aDecoder.decodeObjectForKey("toggleImage") as? UIImage
    super.init(coder: aDecoder)
  }

}
