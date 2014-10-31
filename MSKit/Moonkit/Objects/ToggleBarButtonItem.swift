//
//  ToggleBarButtonItem.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import UIKit

public class ToggleBarButtonItem: UIBarButtonItem {

  public var toggleAction: ((ToggleBarButtonItem) -> Void)?
  public var updateAppearance: ((ToggleBarButtonItem) -> Void)?

  public var isToggled: Bool = false { didSet { updateAppearance?(self) } }

  public override var action: Selector { get { return super.action } set { } }

  public override var target: AnyObject? { get { return super.target } set {} }

  /** toggle */
  public func toggle(sender: AnyObject?) { isToggled = !isToggled; if sender != nil { toggleAction?(self) } }

  /**
  encodeWithCoder:

  :param: aCoder NSCoder
  */
  public override func encodeWithCoder(aCoder: NSCoder) { super.encodeWithCoder(aCoder) }

  /** init */
  public override init() { super.init(); super.target = self; super.action = "toggle:" }

  /**
  initWithCustomView:

  :param: customView UIView
  */
  public override init(customView: UIView) { super.init(customView: customView) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
