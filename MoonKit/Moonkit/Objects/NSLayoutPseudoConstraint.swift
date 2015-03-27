//
//  NSLayoutPseudoConstraint.swift
//  MSKit
//
//  Created by Jason Cardwell on 11/25/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public struct NSLayoutPseudoConstraint: Equatable, Printable, DebugPrintable {
  public var firstItem: String = ""
  public var firstAttribute: String = ""
  public var relation: String = "="
  public var secondItem: String?
  public var secondAttribute: String = ""
  public var constant: String?
  public var multiplier: String?
  public var priority: String?
  public var identifier: String?

  public var constantValue: CGFloat? { return constant == nil ? nil : CGFloat((constant! as NSString).floatValue) }
  public var multiplierValue: CGFloat? { return multiplier == nil ? nil : CGFloat((multiplier! as NSString).floatValue) }
  public var priorityValue: Float? { return priority == nil ? nil : (priority! as NSString).floatValue }

  public var expanded: [NSLayoutPseudoConstraint] {
    switch (firstAttribute, secondAttribute) {
      case let (first, second) where first == second && first == "center":
        var centerX = self; centerX.firstAttribute = "centerX"; centerX.secondAttribute = "centerX"
        var centerY = self; centerY.firstAttribute = "centerY"; centerY.secondAttribute = "centerY"
        return [centerX, centerY]
      case let (first, second) where first == second && first == "size":
        var width = self; width.firstAttribute = "width"; width.secondAttribute = "width"
        var height = self; height.firstAttribute = "height"; height.secondAttribute = "height"
        return [width, height]
      default:
        return [self]
    }
  }

  public var expandable: Bool { return firstAttribute == secondAttribute && (["center", "size"] ∋ firstAttribute) }

  public var description: String {
    var s = ""
    if identifier != nil { s += "'\(identifier!)' " }
    s += "\(firstItem).\(firstAttribute) \(relation)"
    if secondItem != nil && !secondAttribute.isEmpty {
      s += " \(secondItem!).\(secondAttribute)"
      if multiplier != nil && multiplierValue! != 1.0 { s += " * \(multiplier!)" }
    }
    if constant != nil && constantValue! != 0.0 { s += " \(constant![0]) \(constant![1..<constant!.characterCount])" }
    if priority != nil && priorityValue! != 1000.0 { s += " @\(priority!)" }
    return s
  }

  public var debugDescription: String {
    return "\n".join(description,
      "firstItem: \(firstItem)",
      "secondItem: \(secondItem)",
      "firstAttribute: \(firstAttribute)",
      "secondAttribute: \(secondAttribute)",
      "multiplier: \(multiplier)",
      "constant: \(constant)",
      "identifier: \(identifier)",
      "priority: \(priority)")
  }

  /** init */
  public init() {}

  /**
  initWithFormat:

  :param: format String
  */
  public init?(format: String) {
    firstItem = ""
    firstAttribute = ""
    relation = ""
    secondAttribute = ""

    let name = "([\\p{L}$_][\\w]*)"
    let attributes = "|".join(
      "(?:left|right|leading|trailing)(?:Margin)?",
      "(?:top|bottom)(?:Margin)?",
      "width",
      "height",
      "size",
      "(?:center[XY]?)(?:WithinMargins)?",
      "(?:firstB|b)aseline"
    )
    let attribute = "(\(attributes))"
    let item = "\(name)\\.\(attribute)"
    let number = "((?:[-+] *)?\\p{N}+(?:\\.\\p{N}+)?)"
    let multiplier = "(?: *[x*] *\(number))"
    let relatedBy = " *([=≥≤]) *"
    let priority = "(?:@ *\(number))"
    let identifier = "(?:'([\\w ]+)' *)"
    let pattern = "^ *\(identifier)?\(item)\(relatedBy)(?:\(item)\(multiplier)?)? *\(number)? *\(priority)? *$"

    let captures = format.matchFirst(pattern)
    assert(captures.count == 9, "number of capture groups not as expected")

    if let identifier       = captures[0] { self.identifier       = identifier                          }
    if let firstItem        = captures[1] { self.firstItem        = firstItem                           }
    if let firstAttribute   = captures[2] { self.firstAttribute   = firstAttribute                      }
    if let relation         = captures[3] { self.relation         = relation                            }
    if let secondItem       = captures[4] { self.secondItem       = secondItem                          }
    if let secondAttribute  = captures[5] { self.secondAttribute  = secondAttribute                     }
    if let multiplier       = captures[6] { self.multiplier       = multiplier                          }
    if let constant         = captures[7] { self.constant         = String(filter(constant){$0 != " "}) }
    if let priority         = captures[8] { self.priority         = priority                            }

    if firstItem.isEmpty || firstAttribute.isEmpty || relation.isEmpty || (secondItem == nil && constant == nil) { return nil }

  }

  /**
  initWithConstraint:replacements:

  :param: constraint NSLayoutConstraint
  :param: replacements [String String]
  */
  public init(constraint: NSLayoutConstraint, replacements: [String:String]) {
    identifier = constraint.identifier
    if let firstItemReplacement = replacements["firstItem"] { firstItem = firstItemReplacement } else { firstItem = "item1" }
    firstAttribute = constraint.firstAttribute.pseudoName
    relation = constraint.relation.pseudoName
    if constraint.secondItem != nil {
      if let secondItemReplacement = replacements["secondItem"] { secondItem = secondItemReplacement }
      else { secondItem = "item2" }
    }
    secondAttribute = constraint.secondAttribute.pseudoName
    multiplier = "\(constraint.multiplier)"
    let c = constraint.constant
    constant = (c < 0.0 ? "-" : "+") + "\(abs(c))"
    priority = "\(constraint.priority)"
  }

  /**
  pseudoConstraintsByParsingFormat:

  :param: format String

  :returns: [NSLayoutPseudoConstraint]
  */
  public static func pseudoConstraintsByParsingFormat(format: String) -> [NSLayoutPseudoConstraint] {
    return flattened(
      ‽NSLayoutConstraint.splitFormat(format)
        .filter{!$0.isEmpty}
        .map{NSLayoutPseudoConstraint(format: $0)?.expanded}
    )
  }

}

extension NSLayoutPseudoConstraint: StringLiteralConvertible {

  /**
  init:

  :param: value StringLiteralType
  */
  public init(unicodeScalarLiteral value: StringLiteralType) {
    self = NSLayoutPseudoConstraint(format: "\(value)") ?? NSLayoutPseudoConstraint()
  }

  /**
  init:

  :param: value StringLiteralType
  */
  public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    self = NSLayoutPseudoConstraint(format: value) ?? NSLayoutPseudoConstraint()
  }

  /**
  init:

  :param: value StringLiteralType
  */
  public init(stringLiteral value: StringLiteralType) {
    self = NSLayoutPseudoConstraint(format: value) ?? NSLayoutPseudoConstraint()
  }

}
