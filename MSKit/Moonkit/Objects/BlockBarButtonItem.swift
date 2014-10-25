//
//  BlockBarButtonItem.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/2/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import UIKit

public class BlockBarButtonItem: UIBarButtonItem {

  public var buttonAction: ((Void) -> Void)?

  /** init */
  public override init() {
    super.init()
    super.target = self
    super.action = "handler"
  }

  public init(image: UIImage, toggledImage: UIImage, action: ((Void) -> Void)?) {
    super.init(image: image, style: .Plain, target: nil, action: nil)
    buttonAction = action
  }

  public init(image: UIImage?, style: UIBarButtonItemStyle, action: ((Void) -> Void)?) {
    super.init(image: image, style: style, target: nil, action: nil)
    buttonAction = action
  }

  public init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItemStyle, action: ((Void) -> Void)?) {
    super.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)
    buttonAction = action
  }

  public init(title: String?, style: UIBarButtonItemStyle, action: ((Void) -> Void)?) {
    super.init(title: title, style: style, target: nil, action: nil)
    buttonAction = action
  }

  public init(barButtonSystemItem systemItem: UIBarButtonSystemItem, action: ((Void) -> Void)?) {
    super.init(barButtonSystemItem: systemItem, target: nil, action: nil)
    buttonAction = action
  }

  public init(customView: UIView, action: ((Void) -> Void)?) {
    super.init(customView: customView)
    buttonAction = action
  }


  public override var action: Selector { get { return super.action } set {} }

  public override var target: AnyObject? { get { return super.target } set {} }

  /** toggle */
  public func handler() { buttonAction?() }

  /**
  encodeWithCoder:

  :param: aCoder NSCoder
  */
  public override func encodeWithCoder(aCoder: NSCoder) { super.encodeWithCoder(aCoder) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }



}
