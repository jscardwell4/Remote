//
//  PseudoConstraint.swift
//  MSKit
//
//  Created by Jason Cardwell on 11/25/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

private let UILayoutPriorityRequired: Float = 1000.0 // to avoid linker error

public struct PseudoConstraint {

  public typealias ItemName = String
  public var firstItem: ItemName?
  public var firstObject: AnyObject? {
    didSet {
      if let obj: AnyObject = firstObject where firstItem == nil {
        firstItem = "item1"
      }
    }
  }
  public var firstAttribute: Attribute = .NotAnAttribute
  public var relation: Relation = .Equal
  public var secondObject: AnyObject? {
    didSet {
      if let obj: AnyObject = secondObject where secondItem == nil {
        secondItem = "item2"
      }
    }
  }
  public var secondItem: ItemName?
  public var secondAttribute: Attribute = .NotAnAttribute
  public var constant: Float = 0
  public var multiplier: Float = 1
  public var priority: UILayoutPriority = UILayoutPriorityRequired
  public var identifier: String?

  /**
  itemNameFromString:

  :param: string String

  :returns: ItemName?
  */
  private func itemNameFromString(string: String?) -> ItemName? {
    if string == nil { return nil }
    let whitespaceAndNewline = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    let letters = NSCharacterSet.letterCharacterSet()
    var result = ""
    for u in string!.utf16 {
      switch u {
        case whitespaceAndNewline: result += "_"
        case letters: result += String(u)
        default: break
      }
    }
    return result.isEmpty ? nil : result
  }

  /** Whether the pseudo constraint can actually be turned into an `NSLayoutConstraint` object */
  public var valid: Bool {
    return firstItem != nil
      && firstAttribute != .NotAnAttribute
      && !expandable
      && (secondAttribute == .NotAnAttribute ? secondItem == nil : secondItem != nil)
  }

  /** Returns the array of `PseudoConstraint` objects by expanding a compatible attribute, i.e. 'center' into 'centerX', 'centerY' */
  public var expanded: [PseudoConstraint] {
    switch (firstAttribute, secondAttribute) {
      case (.Center, .Center):
        var x = self; x.firstAttribute = .CenterX; x.secondAttribute = .CenterX
        var y = self; y.firstAttribute = .CenterY; y.secondAttribute = .CenterY
        return [x, y]
    case (.CenterWithinMargins, .CenterWithinMargins):
      var x = self; x.firstAttribute = .CenterXWithinMargins; x.secondAttribute = .CenterXWithinMargins
      var y = self; y.firstAttribute = .CenterYWithinMargins; y.secondAttribute = .CenterYWithinMargins
      return [x, y]
      case (.Size, .Size):
        var w = self; w.firstAttribute = .Width; w.secondAttribute = .Width
        var h = self; h.firstAttribute = .Height; h.secondAttribute = .Height
        return [w, h]
      default:
        return [self]
    }
  }

  /** Whether the `PseudoConstraint` is expansion compatible */
  public var expandable: Bool {
    return firstAttribute == secondAttribute && ([.Center, .Size, .CenterWithinMargins] ∋ firstAttribute)
  }

  /** init */
  public init() {}

  /**
  init:attribute:relatedBy:toItem:attribute:multiplier:constant:priority:identifier:

  :param: item1 Item
  :param: attr1 Attribute
  :param: relation Relation = Relation.Equal
  :param: item2 Item? = nil
  :param: attr2 Attribute = Attribute.NotAnAttribute
  :param: multiplier Float = 1.0
  :param: c Float = 0.0
  :param: priority UILayoutPriority = UILayoutPriorityRequired
  :param: identifier String? = nil
  */
  public init(item item1: ItemName,
              attribute attr1: Attribute,
              relatedBy relation: Relation = Relation.Equal,
              toItem item2: ItemName? = nil,
              attribute attr2: Attribute = Attribute.NotAnAttribute,
              multiplier: Float = 1.0,
              constant c: Float = 0.0,
              priority: UILayoutPriority = UILayoutPriorityRequired,
              identifier: String? = nil)
  {
    firstItem = item1
    firstAttribute = attr1
    self.relation = relation
    secondItem = item2
    secondAttribute = attr2
    self.multiplier = multiplier
    constant = c
    self.priority = priority
    self.identifier = identifier
  }

  /**
  initWithFormat:

  :param: format String
  */
  public init?(_ format: String) {

    let name = "([\\p{L}$_][\\w]*)"
    let attributes = "|".join("(?:left|right|leading|trailing)(?:Margin)?",
                              "(?:top|bottom)(?:Margin)?",
                              "width",
                              "height",
                              "size",
                              "(?:center[XY]?)(?:WithinMargins)?",
                              "(?:firstB|b)aseline")
    let attribute = "(\(attributes))"
    let item = "\(name)\\.\(attribute)"
    let number = "((?:[-+] *)?\\p{N}+(?:\\.\\p{N}+)?)"
    let m = "(?: *[x*] *\(number))"
    let relatedBy = " *([=≥≤]) *"
    let p = "(?:@ *\(number))"
    let id = "(?:'([\\w ]+)' *)"
    let pattern = "^ *\(id)?\(item)\(relatedBy)(?:\(item)\(m)?)? *\(number)? *\(p)? *$"

    for capture in filter(enumerate(format.matchFirst(pattern)), {$1 != nil}).map({($0, $1!)}) {
      switch capture {
        case (0, let s): identifier = s
        case (1, let s): firstItem = s
        case (2, let s): if let a = Attribute(rawValue: s) { firstAttribute = a } else { return nil }
        case (3, let s): if let r = Relation(rawValue: s) { relation = r } else { return nil }
        case (4, let s): secondItem = s
        case (5, let s): if let a = Attribute(rawValue: s) { secondAttribute = a } else { return nil }
        case (6, let s): let sc = NSScanner(string: s); if !sc.scanFloat(&multiplier) { return nil }
        case (7, let s): let sc = NSScanner(string: String(filter(s, {$0 != " "}))); if !sc.scanFloat(&constant) { return nil }
        case (8, let s): let sc = NSScanner(string: s); if !sc.scanFloat(&priority) { return nil }
        default: assert(false, "should be unreachable")
      }
    }

  }

  /**
  initWithConstraint:replacements:

  :param: constraint NSLayoutConstraint
  :param: replacements [String String]
  */
  public init(constraint: NSLayoutConstraint, item1: ItemName = "item1", item2: ItemName?) {
    identifier = constraint.identifier
    firstObject = constraint.firstItem
    if let nametag = firstObject?.nametag, name = itemNameFromString(nametag) { firstItem = name }
    if firstItem == nil { firstItem = item1 }
    firstAttribute = Attribute(constraint.firstAttribute)
    relation = Relation(constraint.relation)
    secondObject = constraint.secondItem
    if let nametag = secondObject?.nametag, name = itemNameFromString(nametag) { secondItem = name }
    if secondItem == nil && secondObject != nil { secondItem == item2 ?? "item2" }
    secondAttribute = Attribute(constraint.secondAttribute)
    multiplier = Float(constraint.multiplier)
    constant = Float(constraint.constant)
    priority = constraint.priority
  }

  /**
  pseudoConstraintsByParsingFormat:

  :param: format String

  :returns: [PseudoConstraint]
  */
  public static func pseudoConstraintsByParsingFormat(format: String) -> [PseudoConstraint] {
    return flattenedCompressedMap(NSLayoutConstraint.splitFormat(format), {PseudoConstraint($0)?.expanded})
  }

  /**
  constraintWithItems:item2:

  :param: item1 AnyObject
  :param: item2 AnyObject?

  :returns: NSLayoutConstraint?
  */
  public func constraintWithItems(item1: AnyObject, _ item2: AnyObject?) -> NSLayoutConstraint? {
    if !valid || ((item2 == nil) != (secondItem == nil)) { return nil }
    else {
      let constraint = NSLayoutConstraint(item: item1,
                                          attribute: firstAttribute.NSLayoutAttributeValue,
                                          relatedBy: relation.NSLayoutRelationValue,
                                          toItem: item2,
                                          attribute: secondAttribute.NSLayoutAttributeValue,
                                          multiplier: CGFloat(multiplier),
                                          constant: CGFloat(constant))
      constraint.priority = priority
      constraint.identifier = identifier
      return constraint
    }
  }

  /**
  constraintWithItems:

  :param: items [Item AnyObject]

  :returns: NSLayoutConstraint?
  */
  public func constraintWithItems(items: [ItemName:AnyObject]) -> NSLayoutConstraint? {
    if let firstItem = self.firstItem, item1: AnyObject = items[firstItem] {
      return constraintWithItems(item1, secondItem != nil ? items[secondItem!] : nil)
    } else { return nil }
  }

  public func constraint() -> NSLayoutConstraint? {
    if !valid { return nil }
    else {
      let constraint = NSLayoutConstraint(item: firstObject!,
                                          attribute: firstAttribute.NSLayoutAttributeValue,
                                          relatedBy: relation.NSLayoutRelationValue,
                                          toItem: secondObject,
                                          attribute: secondAttribute.NSLayoutAttributeValue,
                                          multiplier: CGFloat(multiplier),
                                          constant: CGFloat(constant))
      constraint.priority = priority
      constraint.identifier = identifier
      return constraint
    }
  }

}

// MARK: Equatable

extension PseudoConstraint: Equatable {}
public func ==(lhs: PseudoConstraint, rhs: PseudoConstraint) -> Bool { return lhs.description == rhs.description }

// MARK: Printable

extension PseudoConstraint: Printable {
  public var description: String {
    var s = ""
    if let i = identifier { s += "'\(i)' " }
    s += "\(firstItem).\(firstAttribute.rawValue) \(relation.rawValue)"
    if let s2 = secondItem {
      s += " \(s2).\(secondAttribute.rawValue)"
      if multiplier != 1.0 { s += " * \(multiplier)" }
    }
    if constant != 0.0 {
      let sign = constant.isSignMinus ? "-" : "+"
      s += " \(sign) \(abs(constant))"
    }
    if priority != UILayoutPriorityRequired { s += " @\(priority)" }
    return s
  }
}

// MARK: DebugPrintable

extension PseudoConstraint: DebugPrintable {
  public var debugDescription: String {
    return "\n".join(description,
      "firstItem: \(toString(firstItem))",
      "secondItem: \(toString(secondItem))",
      "firstAttribute: \(firstAttribute.rawValue)",
      "secondAttribute: \(secondAttribute.rawValue)",
      "relation: \(relation.rawValue)",
      "multiplier: \(multiplier)",
      "constant: \(constant)",
      "identifier: \(identifier)",
      "priority: \(priority)")
  }
}

extension PseudoConstraint {

  // MARK: - PseudoConstraint.Attribute

  public enum Attribute: String {
    case Left                 = "left"
    case Right                = "right"
    case Leading              = "leading"
    case Trailing             = "trailing"
    case Top                  = "top"
    case Bottom               = "bottom"
    case Size                 = "size"
    case Width                = "width"
    case Height               = "height"
    case Center               = "center"
    case CenterX              = "centerX"
    case CenterY              = "centerY"
    case Baseline             = "baseline"
    case FirstBaseline        = "firstBaseline"
    case LeftMargin           = "leftMargin"
    case RightMargin          = "rightMargin"
    case LeadingMargin        = "leadingMargin"
    case TrailingMargin       = "trailingMargin"
    case TopMargin            = "topMargin"
    case BottomMargin         = "bottomMargin"
    case CenterWithinMargins  = "centerWithinMargins"
    case CenterXWithinMargins = "centerXWithinMargins"
    case CenterYWithinMargins = "centerYWithinMargins"
    case NotAnAttribute       = ""

    public var NSLayoutAttributeValue: NSLayoutAttribute {
      switch self {
        case .Left:                  return .Left
        case .Right:                 return .Right
        case .Leading:               return .Leading
        case .Trailing:              return .Trailing
        case .Top:                   return .Top
        case .Bottom:                return .Bottom
        case .Size:                  return .NotAnAttribute
        case .Width:                 return .Width
        case .Height:                return .Height
        case .Center:                return .NotAnAttribute
        case .CenterX:               return .CenterX
        case .CenterY:               return .CenterY
        case .Baseline:              return .Baseline
        case .FirstBaseline:         return .FirstBaseline
        case .LeftMargin:            return .LeftMargin
        case .RightMargin:           return .RightMargin
        case .LeadingMargin:         return .LeadingMargin
        case .TrailingMargin:        return .TrailingMargin
        case .TopMargin:             return .TopMargin
        case .BottomMargin:          return .BottomMargin
        case .CenterWithinMargins:   return .NotAnAttribute
        case .CenterXWithinMargins:  return .CenterXWithinMargins
        case .CenterYWithinMargins:  return .CenterYWithinMargins
        case .NotAnAttribute:        return .NotAnAttribute
      }
    }

    public init(_ NSLayoutAttributeValue: NSLayoutAttribute) {
      switch NSLayoutAttributeValue {
        case .Left:                  self = .Left
        case .Right:                 self = .Right
        case .Leading:               self = .Leading
        case .Trailing:              self = .Trailing
        case .Top:                   self = .Top
        case .Bottom:                self = .Bottom
        case .Width:                 self = .Width
        case .Height:                self = .Height
        case .CenterX:               self = .CenterX
        case .CenterY:               self = .CenterY
        case .Baseline:              self = .Baseline
        case .FirstBaseline:         self = .FirstBaseline
        case .LeftMargin:            self = .LeftMargin
        case .RightMargin:           self = .RightMargin
        case .LeadingMargin:         self = .LeadingMargin
        case .TrailingMargin:        self = .TrailingMargin
        case .TopMargin:             self = .TopMargin
        case .BottomMargin:          self = .BottomMargin
        case .CenterXWithinMargins:  self = .CenterXWithinMargins
        case .CenterYWithinMargins:  self = .CenterYWithinMargins
        default:                     self = .NotAnAttribute
      }
    }
  }

  // MARK: - PseudoConstraint.Relation

  public enum Relation: String {
    case Equal              = "="
    case GreaterThanOrEqual = "≥"
    case LessThanOrEqual    = "≤"

    public var NSLayoutRelationValue: NSLayoutRelation {
      switch self {
        case .Equal:              return .Equal
        case .GreaterThanOrEqual: return .GreaterThanOrEqual
        case .LessThanOrEqual:    return .LessThanOrEqual
      }
    }

    public init(_ NSLayoutRelationValue: NSLayoutRelation) {
      switch NSLayoutRelationValue {
        case .GreaterThanOrEqual: self = .GreaterThanOrEqual
        case .LessThanOrEqual:    self = .LessThanOrEqual
        default:                  self = .Equal
      }
    }
  }
}

infix operator ⚌ {precedence 160}
infix operator --> {}
public func -->(var lhs: PseudoConstraint, rhs: String) -> PseudoConstraint {
  lhs.identifier = rhs
  return lhs
}

infix operator -!> {}

public func -!>(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
  lhs.priority = rhs
  return lhs
}

public func ⚌<V1: UIView, V2: UIView>(lhs: (V1, PseudoConstraint.Attribute), rhs: (V2, PseudoConstraint.Attribute)) -> PseudoConstraint {
  var pseudo = PseudoConstraint()
  pseudo.firstObject = lhs.0
  pseudo.firstAttribute = lhs.1
  pseudo.secondObject = rhs.0
  pseudo.secondAttribute = rhs.1
  pseudo.relation = .Equal
  return pseudo
}

infix operator ≥ {precedence 160}
public func ≥<V1: UIView, V2: UIView>(lhs: (V1, PseudoConstraint.Attribute), rhs: (V2, PseudoConstraint.Attribute)) -> PseudoConstraint {
  var pseudo = PseudoConstraint()
  pseudo.firstObject = lhs.0
  pseudo.firstAttribute = lhs.1
  pseudo.secondObject = rhs.0
  pseudo.secondAttribute = rhs.1
  pseudo.relation = .GreaterThanOrEqual
  return pseudo
}

infix operator ≤ {precedence 160}
public func ≤<V1: UIView, V2: UIView>(lhs: (V1, PseudoConstraint.Attribute), rhs: (V2, PseudoConstraint.Attribute)) -> PseudoConstraint {
  var pseudo = PseudoConstraint()
  pseudo.firstObject = lhs.0
  pseudo.firstAttribute = lhs.1
  pseudo.secondObject = rhs.0
  pseudo.secondAttribute = rhs.1
  pseudo.relation = .LessThanOrEqual
  return pseudo
}


public func *(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
  lhs.multiplier = rhs
  return lhs
}

public func +(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
  lhs.constant = rhs
  return lhs
}

public func -(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint {
  lhs.constant = -rhs
  return lhs
}

