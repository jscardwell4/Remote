//
//  ToggleImageBarButtonItem.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/31/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import UIKit

public class ToggleImageBarButtonItem: ToggleBarButtonItem {

  private weak var imageView: UIImageView!

  /** override `image` property to utilize the item's custom view */
  public override var image: UIImage? { get { return imageView.image } set { imageView.image = newValue } }

  /** computed property for accessing the custom view's highlighted image property */
  public var highlightedImage: UIImage? {
    get { return imageView.highlightedImage }
    set { imageView.highlightedImage = newValue }
  }

  /** override `updateAppearance` to wrap provided value inside closure that toggles highlighted property of `imageView` */
  public override var updateAppearance: ((ToggleBarButtonItem) -> Void)? {
    get { return super.updateAppearance }
    set {
      super.updateAppearance = {
        (item: ToggleBarButtonItem) -> Void in
          (item as ToggleImageBarButtonItem).imageView.highlighted = item.isToggled
          newValue?(item)
      }
    }
  }

  /** init */
  public override init() { super.init() }

  /**
  initWithImage:toggledImage:action:

  :param: image UIImage
  :param: toggledImage UIImage
  :param: action (ToggleBarButtonItem) -> Void
  */
  public init(image: UIImage, toggledImage: UIImage, action: (ToggleBarButtonItem) -> Void) {

    // create a view to hold the image view for padding purposes
    let containingView = UIView(frame: CGRect(size: CGSize(square: 44.0)))

    // create the image view
    let imageView = UIImageView(image: image, highlightedImage: toggledImage)
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.userInteractionEnabled = true
    imageView.contentMode = .ScaleAspectFit

    // add the image view to the containing view
    containingView.addSubview(imageView)

    // add constraints
    containingView.constrainWithFormat("image.center = self.center :: V:|-(>=8)-[image]-(>=8)-|", views: ["image": imageView])

    // call super's initializer with our custom view
    super.init(customView: containingView)

    // add a gesture for triggering our action
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toggle:"))

    // store the image view and the action parameter
    self.imageView = imageView
    toggleAction = action

  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
