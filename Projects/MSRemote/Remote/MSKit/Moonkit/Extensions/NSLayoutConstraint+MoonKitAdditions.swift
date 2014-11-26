//
//  NSLayoutConstraint+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public func createIdentifier(object: Any, _ suffix: String? = nil) -> String {
  return createIdentifier(object, suffix == nil ? nil : [suffix!])
}

public func createIdentifier(object: Any, _ suffix: [String]? = nil) -> String {
  let identifier = _stdlib_getDemangledTypeName(object)
  return suffix == nil ? identifier : "-".join([identifier] + suffix!)
}

extension NSLayoutConstraint {

  public struct PseudoConstraint: Equatable, Printable {
    var firstItem: String
    var firstAttribute: String
    var relation: String
    var secondItem: String?
    var secondAttribute: String
    var constant: String?
    var constantOperator: String?
    var multiplier: String?
    var priority: String?
    var identifier: String?
    var isExpandable: Bool { return firstAttribute == secondAttribute && (["center", size] ∋ firstAttribute) }

    var description: String {
      var s = ""
      if identifier != nil { s += "'\(identifier!)' " }
      s += "\(firstItem).\(firstAttribute) \(relation)"
      if secondItem != nil && secondAttribute != nil {
        s += " \(secondItem!).\(secondAttribute!)"
        if multiplier != nil { s += " * \(multiplier!)" }
      }
      if constantOperator != nil && constant != nil { s += " \(constantOperator!) \(constant!)"}
      if priority != nil { s += " @\(priority!)" }
      return s
    }

    /**
    initWithFormat:

    :param: format String
    */
    init?(format: String) {
      firstItem = ""
      firstAttribute = ""
      relation = ""

      let name = "([a-zA-Z_][-_a-zA-Z0-9]*)"
      let attribute = "(" + "|".join("(?:left|right|leading|trailing)(?:Margin)?",
                                     "(?:top|bottom)(?:Margin)?",
                                     "width",
                                     "height",
                                     "size",
                                     "(?:center[XY]?)(?:WithinMargins)?",
                                     "(?:firstB|b)aseline") + ")"
      let number = "([0-9]+\\.?[0-9]*)"
      let pattern = " *".join(
        "(?:'([^']+)' )?",
        "\(name)\\.\(attribute) ",
        "([=≥≤])",
        "(?:\(name)\\.\(attribute)(?: +[x*] +\(number))?)?",
        "(?:([+-])? *\(number))?",
        "(?:@\(number))?"
      )
      let captures = format.matchFirst(pattern)
      assert(captures.count == 10, "number of capture groups not as expected")

      if let identifier       = captures[0] { self.identifier       = identifier       }
      if let firstItem        = captures[1] { self.firstItem        = firstItem        }
      if let firstAttribute   = captures[2] { self.firstAttribute   = firstAttribute   }
      if let relation         = captures[3] { self.relation         = relation         }
      if let secondItem       = captures[4] { self.secondItem       = secondItem       }
      if let secondAttribute  = captures[5] { self.secondAttribute  = secondAttribute  }
      if let multiplier       = captures[6] { self.multiplier       = multiplier       }
      if let constantOperator = captures[7] { self.constantOperator = constantOperator }
      if let constant         = captures[8] { self.constant         = constant         }
      if let priority         = captures[9] { self.priority         = priority         }

      if firstItem.isEmpty || firstAttribute.isEmpty || relation.isEmpty || (secondItem == nil && constant == nil) { return nil }

    }
  }

  /**
  splitFormat:

  :param: format String

  :returns: [String]
  */
  public class func splitFormat(format: String) -> [String] {
    return split(format.stringByReplacingMatchesForRegEx(~/"\\s*⏎\\s*|\\s*::\\s*|\\s*;\\s*", withTemplate: "\n")){$0 == "\n"}
  }

  /**
  expandPseudoConstraint:

  :param: constraint PseudoConstraint

  :returns: [PseudoConstraint]
  */
  public class func expandPseudoConstraint(constraint: PseudoConstraint) -> [PseudoConstraint] {
    switch constraint {
      case let (first = .firstAttribute, second = .secondAttribute) where first == second && first == "center":
        var centerX = constraint; centerX.firstAttribute = "centerX"; centerX.secondAttribute = "centerX"
        var centerY = constraint; centerY.firstAttribute = "centerY"; centerY.secondAttribute = "centerY"
        return [centerX, centerY]
      case let (first = .firstAttribute, second = .secondAttribute) where first == second && first == "size":
        var width = constraint; width.firstAttribute = "width"; width.secondAttribute = "width"
        var height = constraint; height.firstAttribute = "height"; height.secondAttribute = "height"
        return [width, height]
      default:
        return [constraint]
    }
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
                                       metrics: [String:AnyObject]? = nil,
                                         views: [String:AnyObject]? = nil) -> [NSLayoutConstraint]
  {
    let formatStrings = splitFormat(format).filter{!$0.isEmpty}

    var standardFormat: [String] = []
    var extendedFormat: [PseudoConstraint] = []

    for string in formatStrings {
      if let pseudoConstraint = PseudoConstraint(format: string) {
        if pseudoConstraint.isExpandable { extendedFormat.extend(expandedPseudoConstraints(pseudoConstraint)) }
        else { extendedFormat.append(pseudoConstraint) }
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
      if let c = constraintFromPseudoConstraint(p, metrics: metrics, views: views) {
        constraints.append(c)
      }
    }

  }


  /**
  constraintFromPseudoConstraint:options:metrics:views:

  :param: pseudoConstraint PseudoConstraint
  :param: options NSLayoutFormatOptions = nil
  :param: metrics [String AnyObject]? = nil
  :param: views [String AnyObject]? = nil

  :returns: NSLayoutConstraint?
  */
  public class func constraintFromPseudoConstraint(pseudoConstraint: PseudoConstraint,
                                           metrics: [String:AnyObject] = [:],
                                             views: [String:AnyObject]) -> NSLayoutConstraint?
  {
    if let firstItem = views[pseudoConstraint.firstItem] {
      let firstAttribute = NSLayoutAttribute(pseudoName: pseudoConstraint.firstAttribute)
      if firstAttribute != NSLayoutAttribute.NotAnAttribute {
        let relation = NSLayoutRelation(pseudoName: pseudoConstraint.relation)
        var secondItem: AnyObject?
        let secondAttribute = pseudoConstraint.secondAttribute
        var multiplier: CGFloat = 1.0
        var constant: CGFloat = 0.0
        if pseudoConstraint.secondItem != nil { secondItem = views[pseudoConstraint.secondItem!] }
        if let multiplierString = pseudoConstraint.multiplier {
          let m = multiplierString.floatValue
          if m != 0.0 { multiplier = CGFloat(m) }
        }
        if let constantString = pseudoConstraint.constant {
          constant = CGFloat(constantString.floatValue)
          if let constantOperatorString = pseudoConstraint.constantOperator {
            if constantOperatorString == "-" { constant = -constant }
          }
        }
        if secondItem != nil || (secondAttribute == NSLayoutAttribute.NotAnAttribute && constant != 0.0) {
          let constraint = NSLayoutConstraint(item: firstItem,
                                              attribute: firstAttribute,
                                              relatedBy: relation,
                                              toItem: secondItem,
                                              attribute: secondAttribute,
                                              multiplier: multiplier,
                                              constant: constant)
          if let priorityString = pseudoConstraint.priority {
            let p = priorityString.floatValue
            if contains(0.0 ... 1000.0, p) { constraint.priority = p }
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

/*
  enum NSLayoutAttribute : Int {

      case Left
      case Right
      case Top
      case Bottom
      case Leading
      case Trailing
      case Width
      case Height
      case CenterX
      case CenterY
      case Baseline

      case FirstBaseline

      case LeftMargin
      case RightMargin
      case TopMargin
      case BottomMargin
      case LeadingMargin
      case TrailingMargin
      case CenterXWithinMargins
      case CenterYWithinMargins

      case NotAnAttribute
  }
*/
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

/*
  enum NSLayoutRelation : Int {

      case LessThanOrEqual
      case Equal
      case GreaterThanOrEqual
  }
*/
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

:param: lhs NSLayoutConstraint.PseudoConstraint
:param: rhs NSLayoutConstraint.PseudoConstraint

:returns: Bool
*/
public func ==(lhs: NSLayoutConstraint.PseudoConstraint, rhs: NSLayoutConstraint.PseudoConstraint) -> Bool {
  return lhs.description == rhs.description
}
