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
    var constraints: [NSLayoutConstraint] = []
    if format.isEmpty { return constraints }

    var dict: [String:AnyObject] = ["self": self]
    if let v = views { for (key, value) in v { dict[key] = value } }
    if let c = NSLayoutConstraint.constraintsByParsingString(format, views: dict) as? [NSLayoutConstraint] { constraints += c }
    apply(constraints){$0.identifier = identifier}

    return constraints
  }

  /**
  constrainSize:identifier:

  :param: size CGSize
  :param: identifier String? = nil

  :returns: (w: NSLayoutConstraint, h: NSLayoutConstraint)
  */
  public func constrainSize(size: CGSize, identifier: String? = nil) -> (w: NSLayoutConstraint, h: NSLayoutConstraint) {
    return (w: constrainWidth(size.width), h: constrainHeight(size.height))
  }

  /**
  constrainWidth:identifier:

  :param: width CGFloat
  :param: identifier String? = nil

  :returns: NSLayoutConstraint
  */
//  public func constrainWidth(width: CGFloat, identifier: String? = nil) -> NSLayoutConstraint {
//    let constraint = NSLayoutConstraint(
//      item: self,
//      attribute: .Width,
//      relatedBy: .Equal,
//      toItem: nil,
//      attribute: .NotAnAttribute,
//      multiplier: 1.0,
//      constant: abs(width)
//    )
//    constraint.identifier = identifier
//    addConstraint(constraint)
//    return constraint
//  }

  /**
  constrainHeight:identifier:

  :param: height CGFloat
  :param: identifier String? = nil

  :returns: NSLayoutConstraint
  */
//  public func constrainHeight(height: CGFloat, identifier: String? = nil) -> NSLayoutConstraint {
//    let constraint = NSLayoutConstraint(
//      item: self,
//      attribute: .Height,
//      relatedBy: .Equal,
//      toItem: nil,
//      attribute: .NotAnAttribute,
//      multiplier: 1.0,
//      constant: abs(height)
//    )
//    constraint.identifier = identifier
//    addConstraint(constraint)
//    return constraint
//  }

}
