//
//  NSLayoutConstraint+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
//import UIKit

extension NSLayoutConstraint {

  /**
  splitFormat:

  :param: format String

  :returns: [String]
  */
  public class func splitFormat(format: String) -> [String] {
    return "\n".split(format.sub("::", "\n").sub("[⏎;]", "\n").sub("  +", " "))
      .map({$0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())})
      .filter(invert(isEmpty))
  }

  /**
  constraintsByParsingFormat:options:metrics:views:

  :param: format String
  :param: options NSLayoutFormatOptions = nil
  :param: metrics [String AnyObject]? = nil
  :param: views [String AnyObject]? = nil

  :returns: [NSLayoutConstraint]
  */
  public class func constraintsByParsingFormat(format: String,
                                       options: NSLayoutFormatOptions = nil,
                                       metrics: [String:AnyObject] = [:],
                                         views: [String:AnyObject] = [:]) -> [NSLayoutConstraint]
  {
    var constraints: [NSLayoutConstraint] = []

    for string in splitFormat(format) {
      if let c = PseudoConstraint(string)?.expanded.compressedMap({$0.constraintWithItems(views)}) where c.count > 0 {
          constraints.extend(c)
      } else {
        let c = constraintsWithVisualFormat(string, options: options, metrics: metrics, views: views) as! [NSLayoutConstraint]
        constraints.extend(c)
      }
    }

    return constraints
  }

}

extension NSLayoutAttribute {
  public var axis: UILayoutConstraintAxis {
    switch self {
      case .Width,
           .Left, .LeftMargin,
           .Leading, .LeadingMargin,
           .Right, .RightMargin,
           .Trailing, .TrailingMargin,
           .CenterX, .CenterXWithinMargins:
        return .Horizontal
      default: return .Vertical
    }
  }
}