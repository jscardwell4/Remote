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
  public var isToggled: Bool = false { didSet { imageView?.highlighted = isToggled } }
  private weak var imageView: UIImageView?

  /** init */
  public override init() {
    super.init()
    super.target = self
    super.action = "toggle:"
  }

  public override var image: UIImage? { get { return (customView as? UIImageView)?.image } set { (customView as? UIImageView)?.image = newValue } }

  /**
  initWithImage:toggledImage:action:

  :param: image UIImage
  :param: toggledImage UIImage
  :param: action (ToggleBarButtonItem) -> Void
  */
  public init(image: UIImage, toggledImage: UIImage, action: (ToggleBarButtonItem) -> Void) {
    let imageView = UIImageView(image: image, highlightedImage: toggledImage)
    let containingView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 44.0, height: 44.0)))
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    containingView.addSubview(imageView)
    containingView.constrainWithFormat("imageView.center = self.center :: V:|-(>=8)-[imageView]-(>=8)-|", views: ["imageView": imageView])
    imageView.userInteractionEnabled = true
    imageView.contentMode = .ScaleAspectFit
    super.init(customView: containingView)
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toggle:"))
    self.imageView = imageView
    toggleAction = action
  }

  public override var action: Selector { get { return super.action } set { } }

  public override var target: AnyObject? { get { return super.target } set {} }

  /** toggle */
  public func toggle(sender: AnyObject?) { isToggled = !isToggled; if sender != nil { toggleAction?(self) } }

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
