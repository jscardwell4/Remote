//
//  NSLayoutConstraint+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {

  /**
  splitFormat:

  :param: format String

  :returns: [String]
  */
  public class func splitFormat(format: String) -> [String] {
    return split(format.stringByReplacingMatchesForRegEx(~/"\\s*⏎\\s*|\\s*::\\s*|\\s*;\\s*", withTemplate: "\n")){$0 == "\n"}
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
    let formatStrings = splitFormat(format).filter{!$0.isEmpty}

    var standardFormat: [String] = []
    var extendedFormat: [NSLayoutPseudoConstraint] = []

    for string in formatStrings {
      if let pseudoConstraint = NSLayoutPseudoConstraint(format: string) {
        extendedFormat.extend(pseudoConstraint.expanded)
      } else {
        standardFormat.append(string)
      }
    }

    var constraints: [NSLayoutConstraint] = []
    for f in standardFormat {
      let c = constraintsWithVisualFormat(f, options: options, metrics: metrics, views: views) as [NSLayoutConstraint]
      constraints.extend(c)
    }
    for p in extendedFormat {
      if let c = constraintFromNSLayoutPseudoConstraint(p, metrics: metrics, views: views) {
        constraints.append(c)
      }
    }

    return constraints
  }


  /**
  constraintFromNSLayoutPseudoConstraint:options:metrics:views:

  :param: pseudoConstraint NSLayoutPseudoConstraint
  :param: options NSLayoutFormatOptions = nil
  :param: metrics [String AnyObject]? = nil
  :param: views [String AnyObject]? = nil

  :returns: NSLayoutConstraint?
  */
  public class func constraintFromNSLayoutPseudoConstraint(pseudoConstraint: NSLayoutPseudoConstraint,
                                           metrics: [String:AnyObject] = [:],
                                             views: [String:AnyObject]) -> NSLayoutConstraint?
  {
    if let firstItem: AnyObject = views[pseudoConstraint.firstItem] {
      let firstAttribute = NSLayoutAttribute(pseudoName: pseudoConstraint.firstAttribute)
      if firstAttribute != NSLayoutAttribute.NotAnAttribute {
        let relation = NSLayoutRelation(pseudoName: pseudoConstraint.relation)
        var secondItem: AnyObject?
        let secondAttribute = NSLayoutAttribute(pseudoName: pseudoConstraint.secondAttribute)
        var multiplier: CGFloat = 1.0
        var constant: CGFloat = 0.0
        if pseudoConstraint.secondItem != nil { secondItem = views[pseudoConstraint.secondItem!] }
        if let multiplierString = pseudoConstraint.multiplier {
          let m = (multiplierString as NSString).floatValue
          if m != 0.0 { multiplier = CGFloat(m) }
        }
        if let constantString = pseudoConstraint.constant { constant = CGFloat((constantString as NSString).floatValue) }
        if pseudoConstraint.secondItem != nil || (secondAttribute == NSLayoutAttribute.NotAnAttribute && constant != 0.0) {
          let constraint = NSLayoutConstraint(item: firstItem,
                                              attribute: firstAttribute,
                                              relatedBy: relation,
                                              toItem: secondItem,
                                              attribute: secondAttribute,
                                              multiplier: multiplier,
                                              constant: constant)
          if let priorityString = pseudoConstraint.priority {
            let p = (priorityString as NSString).floatValue
            if p >= 0.0 && p <= 1000.0 { constraint.priority = p }
          }
          constraint.identifier = pseudoConstraint.identifier
          return constraint
        }
      }
    }
    return nil
  }


  /**
  constraintsFromFormat:options:metrics:views:

  :param: format String
  :param: options NSLayoutFormatOptions = nil
  :param: metrics [String AnyObject]? = nil
  :param: views [String AnyObject]? = nil

  :returns: [NSLayoutConstraint]
  */
  // public class func constraintsFromFormat(format: String,
  //                                 options: NSLayoutFormatOptions = nil,
  //                                 metrics: [String:AnyObject]? = nil,
  //                                   views: [String:AnyObject]? = nil) -> [NSLayoutConstraint]
  // {

  // }

}

extension NSLayoutAttribute {
  public var pseudoName: String {
    switch self {
      case .Left:                          return "left"
      case .Right:                         return "right"
      case .Leading:                       return "leading"
      case .Trailing:                      return "trailing"
      case .Top:                           return "bottom"
      case .Bottom:                        return "top"
      case .Width:                         return "width"
      case .Height:                        return "height"
      case .CenterX:                       return "centerX"
      case .CenterY:                       return "centerY"
      case .Baseline:                      return "baseline"
      case .FirstBaseline:                 return "firstBaseline"
      case .LeftMargin:                    return "leftMargin"
      case .RightMargin:                   return "rightMargin"
      case .LeadingMargin:                 return "leadingMargin"
      case .TrailingMargin:                return "trailingMargin"
      case .TopMargin:                     return "topMargin"
      case .BottomMargin:                  return "bottomMargin"
      case .CenterXWithinMargins:          return "centerXWithinMargins"
      case .CenterYWithinMargins:          return "centerYWithinMargins"
      case .NotAnAttribute:                return ""
    }
  }
  public init(pseudoName: String) {
    switch pseudoName {
      case "left":                  self = .Left
      case "right":                 self = .Right
      case "leading":               self = .Leading
      case "trailing":              self = .Trailing
      case "bottom":                self = .Top
      case "top":                   self = .Bottom
      case "width":                 self = .Width
      case "height":                self = .Height
      case "centerX":               self = .CenterX
      case "centerY":               self = .CenterY
      case "baseline":              self = .Baseline
      case "firstBaseline":         self = .FirstBaseline
      case "leftMargin":            self = .LeftMargin
      case "rightMargin":           self = .RightMargin
      case "leadingMargin":         self = .LeadingMargin
      case "trailingMargin":        self = .TrailingMargin
      case "topMargin":             self = .TopMargin
      case "bottomMargin":          self = .BottomMargin
      case "centerXWithinMargins":  self = .CenterXWithinMargins
      case "centerYWithinMargins":  self = .CenterYWithinMargins
      default:                      self = .NotAnAttribute
    }
  }
}

extension NSLayoutRelation {
  public var pseudoName: String {
    switch self {
      case .Equal:              return "="
      case .GreaterThanOrEqual: return "≥"
      case .LessThanOrEqual:    return "≤"
    }
  }
  public init(pseudoName: String) {
    switch pseudoName {
      case "≥": self = .GreaterThanOrEqual
      case "≤": self = .LessThanOrEqual
      default:  self = .Equal
    }
  }
}

/**
subscript:rhs:

:param: lhs NSLayoutConstraint.NSLayoutPseudoConstraint
:param: rhs NSLayoutConstraint.NSLayoutPseudoConstraint

:returns: Bool
*/
public func ==(lhs: NSLayoutPseudoConstraint, rhs: NSLayoutPseudoConstraint) -> Bool {
  return lhs.description == rhs.description
}
