//
//  UIView+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {

  /**
  initWithAutolayout:

  :param: autolayout Bool
  */
  public convenience init(autolayout: Bool) {
    self.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(!autolayout)
  }

  /**
  framesDescription

  :returns: String
  */
  public func framesDescription() -> String {
  	return self.viewTreeDescriptionWithProperties(["frame"])
      .stringByReplacingRegEx("[{]\\s*\n\\s*frame = \"NSRect:\\s*([^\"]+)\";\\s*\n\\s*[}]", withString: " { frame=$1 }")
  }

  /**
  descriptionTree:

  :param: properties String ...

  :returns: String
  */
  public func descriptionTree(properties: String ...) -> String {
  	return self.viewTreeDescriptionWithProperties(properties)
  }

  /**
  subscript:

  :param: nametag String

  :returns: UIView?
  */
  public subscript(nametag: String) -> UIView? { return viewWithNametag(nametag) }

  /**
  constrain:views:identifier:

  :param: format String
  :param: views [String AnyObject]? = nil
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func constrain(format: String, views: [String:AnyObject]? = nil, identifier: String? = nil) -> [NSLayoutConstraint] {
    if format.isEmpty { return [] }

    var dict: [String:AnyObject] = views ?? [:]
    dict["self"] = self

    let constraints = NSLayoutConstraint.constraintsByParsingString(format, views: dict) as [NSLayoutConstraint]
    apply(constraints){$0.identifier = identifier}
    addConstraints(constraints)
    return constraints
  }

  /**
  constrainSize:identifier:

  :param: size CGSize
  :param: identifier String? = nil

  :returns: (w: NSLayoutConstraint, h: NSLayoutConstraint)
  */
  public func constrainSize(size: CGSize, identifier: String? = nil) -> (w: NSLayoutConstraint, h: NSLayoutConstraint) {
    return (w: constrainWidth(size.width, identifier: identifier), h: constrainHeight(size.height, identifier: identifier))
  }

  /**
  stretchSubview:

  :param: subview UIView

  :returns: [NSLayoutConstraint]
  */
  public func stretchSubview(subview: UIView, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("|[subview(>=0)]| :: V:|[subview(>=0)]|", views: ["subview": subview], identifier: identifier)
            : []
  }

  /**
  horizontallyStretchSubview:identifier:

  :param: subview UIView
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func horizontallyStretchSubview(subview: UIView, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("H:|[subview(>=0)]|", views: ["subview": subview], identifier: identifier)
            : []
  }

  /**
  verticallyStretchSubview:identifier:

  :param: subview UIView
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func verticallyStretchSubview(subview: UIView, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("V:|[subview(>=0)]|", views: ["subview": subview], identifier: identifier)
            : []
  }

  /**
  horizontallyCenterSubview:offset:identifier:

  :param: subview UIView
  :param: offset CGFloat = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func horizontallyCenterSubview(subview: UIView,
                                 offset: CGFloat = 0.0,
                             identifier: String? = nil) -> [NSLayoutConstraint]
  {
    return (subviews as [UIView]) ∋ subview
            ? constrain("subview.centerX = self.centerX + \(offset)", views:["subview": subview], identifier: identifier)
            : []
  }

  /**
  verticallyCenterSubview:offset:identifier:

  :param: subview UIView
  :param: offset CGFloat = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func verticallyCenterSubview(subview: UIView,
                               offset: CGFloat = 0.0,
                           identifier: String? = nil) -> [NSLayoutConstraint]
  {
    return (subviews as [UIView]) ∋ subview
            ? constrain("subview.centerY = self.centerY + \(offset)", views:["subview": subview], identifier: identifier)
            : []
  }

  /**
  centerSubview:offset:identifier:

  :param: subview UIView
  :param: offset CGFloat = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func centerSubview(subview: UIView, offset: CGFloat = 0.0, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("subview.center = self.center + \(offset)", views:["subview": subview], identifier: identifier)
            : []
  }

  /**
  leftAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset CGFloat = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func leftAlignSubview(subview: UIView, offset: CGFloat = 0.0, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("subview.left = self.left + \(offset)", views:["subview": subview], identifier: identifier)
            : []
  }

  /**
  rightAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset CGFloat = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func rightAlignSubview(subview: UIView, offset: CGFloat = 0.0, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("subview.right = self.right + \(offset)", views:["subview": subview], identifier: identifier)
            : []
  }

  /**
  topAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset CGFloat = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func topAlignSubview(subview: UIView, offset: CGFloat = 0.0, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("subview.top = self.top + \(offset)", views:["subview": subview], identifier: identifier)
            : []
  }

  /**
  bottomAlignSubview:offset:identifier:

  :param: subview UIView
  :param: offset CGFloat = 0.0
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func bottomAlignSubview(subview: UIView, offset: CGFloat = 0.0, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ∋ subview
            ? constrain("subview.bottom = self.bottom + \(offset)", views:["subview": subview], identifier: identifier)
            : []
  }

  /**
  constrainWidth:identifier:

  :param: width CGFloat
  :param: identifier String? = nil

  :returns: NSLayoutConstraint
  */
  public func constrainWidth(width: CGFloat, identifier: String? = nil) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: .Width,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 1.0,
      constant: abs(width)
    )
    constraint.identifier = identifier
    addConstraint(constraint)
    return constraint
  }

  /**
  constrainHeight:identifier:

  :param: height CGFloat
  :param: identifier String? = nil

  :returns: NSLayoutConstraint
  */
  public func constrainHeight(height: CGFloat, identifier: String? = nil) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: .Height,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 1.0,
      constant: abs(height)
    )
    constraint.identifier = identifier
    addConstraint(constraint)
    return constraint
  }

  /**
  constrainAspect:identifier:

  :param: aspect CGFloat
  :param: identifier String? = nil

  :returns: NSLayoutConstraint
  */
  public func constrainAspect(aspect: CGFloat, identifier: String? = nil) -> NSLayoutConstraint {
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: .Width,
      relatedBy: .Equal,
      toItem: self,
      attribute: .Height,
      multiplier: aspect,
      constant: 0.0)
    constraint.identifier = identifier
    addConstraint(constraint)
    return constraint
  }

  /**
  alignSubview:besideSubview:offset:identifier:

  :param: subview1 UIView
  :param: subview2 UIView
  :param: offset CGFloat
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func alignSubview(subview1: UIView, besideSubview subview2: UIView, offset: CGFloat, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ⊃ [subview1, subview2]
            ? constrain("H:[s1]-\(offset)-[s2]", views: ["s1": subview1, "s2": subview2], identifier: identifier)
            : []
  }

  /**
  alignSubview:aboveSubview:offset:identifier:

  :param: subview1 UIView
  :param: subview2 UIView
  :param: offset CGFloat
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func alignSubview(subview1: UIView, aboveSubview subview2: UIView, offset: CGFloat, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ⊃ [subview1, subview2]
            ? constrain("V:[s1]-\(offset)-[s2]", views: ["s1": subview1, "s2": subview2], identifier: identifier)
            : []
  }

  /**
  stretchSubview:toSubview:identifier:

  :param: subview1 UIView
  :param: subview2 UIView
  :param: identifier String? = nil

  :returns: [NSLayoutConstraint]
  */
  public func stretchSubview(subview1: UIView, toSubview subview2: UIView, identifier: String? = nil) -> [NSLayoutConstraint] {
    return (subviews as [UIView]) ⊃ [subview1, subview2]
        ? constrain("s1.left = s2.left :: s1.right = s2.right :: s1.top = s2.top :: s1.bottom = s2.bottom",
              views: ["s1": subview1, "s2": subview2],
              identifier: identifier)
        : []
  }

}
