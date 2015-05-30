//
//  PseudoConstraint.swift
//  MSKit
//
//  Created by Jason Cardwell on 11/25/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public let 𝗩 = UILayoutConstraintAxis.Vertical
public let 𝗛 = UILayoutConstraintAxis.Horizontal

private let UILayoutPriorityRequired: Float = 1000.0 // to avoid linker error

public struct PseudoConstraint {

  public typealias ItemName = String
  public var firstItem: ItemName?
  public var firstObject: AnyObject? { didSet { updateFirstItem() } }

  private mutating func updateFirstItem() {
    if let f = firstObject as? Named { firstItem = itemNameFromString(f.name) }
    else if let f = firstObject as? UIView, nametag = f.nametag { firstItem = itemNameFromString(nametag) }
    else { firstItem = firstObject != nil ? "item1" : nil }
  }

  private mutating func updateSecondItem() {
    if let f = secondObject as? Named { secondItem = itemNameFromString(f.name) }
    else if let f = secondObject as? UIView, nametag = f.nametag { secondItem = itemNameFromString(nametag) }
    else { secondItem = secondObject != nil ? "item2" : nil }
  }

  public var firstAttribute: Attribute = .NotAnAttribute
  public var relation: Relation = .Equal
  public var secondObject: AnyObject? { didSet { updateSecondItem() } }
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
        case letters: result += String(UnicodeScalar(u))
        default: break
      }
    }
    return result.isEmpty ? nil : result
  }

  /** Whether the pseudo constraint can actually be turned into an `NSLayoutConstraint` object */
  public var valid: Bool {
    return (firstItem ?? firstObject) != nil
         && firstAttribute != .NotAnAttribute
         && !expandable
         && (secondAttribute == .NotAnAttribute ? secondItem == nil : (secondItem ?? secondObject) != nil)
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
  public init(constraint: NSLayoutConstraint) {
    identifier = constraint.identifier
    firstObject = constraint.firstItem
    updateFirstItem()
    firstAttribute = Attribute(constraint.firstAttribute)
    relation = Relation(constraint.relation)
    secondObject = constraint.secondItem
    updateSecondItem()
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

  /**
  constraint

  :returns: NSLayoutConstraint?
  */
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

  /**
  initWithFirst:PseudoConstraint.Attribute):second:PseudoConstraint.Attribute):

  :param: first (V1
  :param: PseudoConstraint.Attribute)
  :param: second (V2
  :param: PseudoConstraint.Attribute)
  */
  public init(first: ViewAttributePair, second: ViewAttributePair, relation r: Relation = .Equal) {
    firstObject = first.0
    updateFirstItem()
    firstAttribute = first.1
    secondObject = second.0
    updateSecondItem()
    secondAttribute = second.1
    relation = r
  }

  /**
  initWithPair:constant:

  :param: pair ViewAttributePair
  :param: c Float
  */
  public init(pair: ViewAttributePair, constant c: Float, relation r: Relation = .Equal) {
    firstObject = pair.0
    updateFirstItem()
    firstAttribute = pair.1
    secondObject = nil
    secondAttribute = .NotAnAttribute
    relation = r
    constant = c
  }

}

// MARK: Equatable

extension PseudoConstraint: Equatable {}
public func ==(lhs: PseudoConstraint, rhs: PseudoConstraint) -> Bool { return lhs.description == rhs.description }

// MARK: Printable

extension PseudoConstraint: Printable {
  public var description: String {
    if !valid { return "pseudo invalid" }

    var result = ""
    if let i = identifier { result += "'\(i)' " }

    let firstItemString: String

    if let f = firstItem { firstItemString = f }
    else if let f = firstObject as? Named { firstItemString = f.name.camelcaseString }
    else { firstItemString = "firstItem" }

    result += "\(firstItemString).\(firstAttribute.rawValue) \(relation.rawValue)"

    if secondAttribute != .NotAnAttribute {
      let secondItemString: String
      if let s = secondItem { secondItemString = s }
      else if let s = secondObject as? Named { secondItemString = s.name.camelcaseString }
      else { secondItemString = "secondItem" }
      result += " \(secondItemString).\(secondAttribute.rawValue)"
    }

    if multiplier != 1.0 { result += " x \(multiplier)" }

    if constant != 0.0 { let sign = constant.isSignMinus ? "-" : "+"; result += " \(sign) \(abs(constant))" }
    if priority != UILayoutPriorityRequired { result += " @\(priority)" }

    return result
  }
}

// MARK: DebugPrintable

extension PseudoConstraint: DebugPrintable {
  public var debugDescription: String {
    return "\n".join(description,
      "firstItem: \(toString(firstItem))",
      "firstObject: \(toString(firstObject))",
      "secondItem: \(toString(secondItem))",
      "secondObject: \(toString(secondObject))",
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

    public var axis: UILayoutConstraintAxis { return NSLayoutAttributeValue.axis }

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

// MARK: - Function-related typealiases

public typealias ViewAttributePair = (UIView, PseudoConstraint.Attribute)

// MARK: - Superview/ancestor helper functions

func discernViewSuperview(obj1: AnyObject?, obj2: AnyObject?) -> (view: UIView, superview: UIView)? {
  if let view = obj1 as? UIView, superview = view.superview where obj2 === superview {
    return (view: view, superview: superview)
  } else if let view = obj2 as? UIView, superview = view.superview where obj1 === superview {
    return (view: view, superview: superview)
  } else {
    return nil
  }
}

func discernNearestAncestor(obj1: AnyObject?, obj2: AnyObject?) -> UIView? {
  switch (obj1, obj2) {
    case let (v1 as UIView, v2 as UIView): return v1.nearestCommonAncestorWithView(v2)
    case let (v as UIView, nil): return v.superview
    case let (nil, v as UIView): return v.superview
    default: return nil
  }
}

// MARK: - Identifier operator
infix operator --> {}

public func -->(var lhs: PseudoConstraint, rhs: String?) -> PseudoConstraint { lhs.identifier = rhs; return lhs }
public func -->(lhs: [PseudoConstraint], rhs: String?) -> [PseudoConstraint] { return lhs.map {$0 --> rhs} }
public func -->(lhs: [[PseudoConstraint]], rhs: String?) -> [PseudoConstraint] { return flatMap(lhs) {$0 --> rhs} }

// MARK: - Priority operator
infix operator -!> {}

public func -!>(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint { lhs.priority = rhs; return lhs }

// MARK: - Equal operator
infix operator => {precedence 160}

public func =>(lhs: ViewAttributePair, rhs: ViewAttributePair) -> PseudoConstraint {
  return PseudoConstraint(first: lhs, second: rhs)
}

public func =>(lhs: ViewAttributePair, rhs: Float) -> PseudoConstraint { return PseudoConstraint(pair: lhs, constant: rhs) }

// MARK: - GreaterThanOrEqual operator
infix operator ≥ {precedence 160}

public func ≥(lhs: ViewAttributePair, rhs: ViewAttributePair) -> PseudoConstraint {
  return PseudoConstraint(first: lhs, second: rhs, relation: .GreaterThanOrEqual)
}

public func ≥(lhs: ViewAttributePair, rhs: Float) -> PseudoConstraint {
  return PseudoConstraint(pair: lhs, constant: rhs, relation: .GreaterThanOrEqual)
}

// MARK: - LessThanOrEqual operator
infix operator ≤ {precedence 160}

public func ≤(lhs: ViewAttributePair, rhs: ViewAttributePair) -> PseudoConstraint {
  return PseudoConstraint(first: lhs, second: rhs, relation: .LessThanOrEqual)
}

public func ≤(lhs: ViewAttributePair, rhs: Float) -> PseudoConstraint {
  return PseudoConstraint(pair: lhs, constant: rhs, relation: .LessThanOrEqual)
}

// MARK: - Multiplication, division, and subtraction operators

public func *(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint { lhs.multiplier =  rhs; return lhs }
public func +(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint { lhs.constant   =  rhs; return lhs }
public func -(var lhs: PseudoConstraint, rhs: Float) -> PseudoConstraint { lhs.constant   = -rhs; return lhs }

// MARK: - Flush to superview left/top operator

public func |(lhs: UILayoutConstraintAxis, rhs: UIView) -> PseudoConstraint {
  assert(rhs.superview != nil, "this operator requires a proper view hierarchy has been established")
  switch lhs {
    case .Horizontal: return rhs.left => rhs.superview!.left
    case .Vertical:   return rhs.top  => rhs.superview!.top
  }
}

// MARK: - Flush to superview right/bottom operator

public func |(lhs: UIView, rhs: UILayoutConstraintAxis) -> PseudoConstraint {
  precondition(lhs.superview != nil, "this operator requires a proper view hierarchy has been established")
  switch rhs {
    case .Horizontal: return lhs.right => lhs.superview!.right
    case .Vertical:   return lhs.bottom => lhs.superview!.bottom
  }
}

public func |(var lhs: PseudoConstraint, rhs: UILayoutConstraintAxis) -> [PseudoConstraint] { return [lhs]|rhs }
public func |(var lhs: [PseudoConstraint], rhs: UILayoutConstraintAxis) -> [PseudoConstraint] {
  precondition(lhs.last?.firstObject as? UIView != nil, "this operator requires a view for the last constraint's firstObject")
  let view = lhs.last!.firstObject as! UIView
  precondition(view.superview != nil, "this operator requires a proper view hierarchy has been established")
  switch rhs {
    case .Horizontal: lhs.append(view.right => view.superview!.right)
    case .Vertical: lhs.append(view.bottom => view.superview!.bottom)
  }
  return lhs
}

// MARK: - Offset from superview left/top operator
infix operator |-- {associativity left precedence 140}

public func |--(lhs: UILayoutConstraintAxis, rhs: Float) -> (UILayoutConstraintAxis, Float, PseudoConstraint.Relation) {
  return (lhs, rhs, .Equal)
}

public func |--(lhs: UILayoutConstraintAxis,
                rhs: (Float, PseudoConstraint.Relation)) -> (UILayoutConstraintAxis, Float, PseudoConstraint.Relation)
{
  return (lhs, rhs.0, rhs.1)
}

// MARK: - Offset from superview right/bottom operator
infix operator --| {associativity left precedence 140}

public func --|(lhs: (PseudoConstraint, Float, PseudoConstraint.Relation), rhs: UILayoutConstraintAxis) -> [PseudoConstraint] {
  if let (view, superview) = discernViewSuperview(lhs.0.firstObject, lhs.0.secondObject) {
    switch lhs.0.firstAttribute.axis {
      case .Horizontal:
        switch lhs.2 {
          case .Equal:              return [lhs.0, view.right => superview.right - lhs.1]
          case .GreaterThanOrEqual: return [lhs.0, view.right ≥  superview.right - lhs.1]
          case .LessThanOrEqual:    return [lhs.0, view.right ≤  superview.right - lhs.1]
        }
      case .Vertical:
        switch lhs.2 {
          case .Equal:              return [lhs.0, view.bottom => superview.bottom - lhs.1]
          case .GreaterThanOrEqual: return [lhs.0, view.bottom ≥  superview.bottom - lhs.1]
          case .LessThanOrEqual:    return [lhs.0, view.bottom ≤  superview.bottom - lhs.1]
        }
    }
  } else { return [] }

}

public func --|(lhs: ([PseudoConstraint], Float, PseudoConstraint.Relation), rhs: UILayoutConstraintAxis) -> [PseudoConstraint] {
  var superview: UIView?
  for constraint in lhs.0 {
    superview = discernNearestAncestor(discernNearestAncestor(constraint.firstObject, constraint.secondObject), superview)
  }
  precondition(superview != nil, "this operator requires a proper view hierarchy has been established")
  if let lastConstraint = lhs.0.last, lastView = lastConstraint.firstObject as? UIView {
    precondition(lastConstraint.firstAttribute.axis == rhs, "axis miss-match")
    switch rhs {
      case .Horizontal:
        switch lhs.2 {
          case .Equal:              return lhs.0 + [lastView.right => superview!.right - lhs.1]
          case .GreaterThanOrEqual: return lhs.0 + [lastView.right ≥  superview!.right - lhs.1]
          case .LessThanOrEqual:    return lhs.0 + [lastView.right ≤  superview!.right - lhs.1]
        }
      case .Vertical:
        switch lhs.2 {
          case .Equal:              return lhs.0 + [lastView.bottom => superview!.bottom - lhs.1]
          case .GreaterThanOrEqual: return lhs.0 + [lastView.bottom ≥  superview!.bottom - lhs.1]
          case .LessThanOrEqual:    return lhs.0 + [lastView.bottom ≤  superview!.bottom - lhs.1]
        }
    }
  } else { return [] }

}

public func --|(lhs: (UIView, Float, PseudoConstraint.Relation), rhs: UILayoutConstraintAxis) -> PseudoConstraint {
  precondition(lhs.0.superview != nil, "this operator requires a proper view hierarchy has been established")
  switch rhs {
    case .Horizontal:
      switch lhs.2 {
        case .Equal:              return lhs.0.right => lhs.0.superview!.right - lhs.1
        case .GreaterThanOrEqual: return lhs.0.right ≥  lhs.0.superview!.right - lhs.1
        case .LessThanOrEqual:    return lhs.0.right ≤  lhs.0.superview!.right - lhs.1
      }
    case .Vertical:
      switch lhs.2 {
        case .Equal:              return lhs.0.bottom => lhs.0.superview!.bottom - lhs.1
        case .GreaterThanOrEqual: return lhs.0.bottom ≥  lhs.0.superview!.bottom - lhs.1
        case .LessThanOrEqual:    return lhs.0.bottom ≤  lhs.0.superview!.bottom - lhs.1
      }
  }
}

// MARK: - Spacing operator
// MARK:   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
infix operator -- {associativity left precedence 140}

// MARK: Prefix

public func --(lhs: [PseudoConstraint], rhs: Float) -> ([PseudoConstraint], Float, PseudoConstraint.Relation) {
  return (lhs, rhs, .Equal)
}

public func --(lhs: PseudoConstraint, rhs: Float) -> (PseudoConstraint, Float, PseudoConstraint.Relation) {
  return (lhs, rhs, .Equal)
}

public func --(lhs: UIView, rhs: Float) -> (UIView, Float, PseudoConstraint.Relation) {
  return (lhs, rhs, .Equal)
}

public func --(lhs: [PseudoConstraint],
               rhs: (Float, PseudoConstraint.Relation)) -> ([PseudoConstraint], Float, PseudoConstraint.Relation)
{
  return (lhs, rhs.0, rhs.1)
}

public func --(lhs: PseudoConstraint,
               rhs: (Float, PseudoConstraint.Relation)) -> (PseudoConstraint, Float, PseudoConstraint.Relation)
{
  return (lhs, rhs.0, rhs.1)
}

public func --(lhs: UIView, rhs: (Float, PseudoConstraint.Relation)) -> (UIView, Float, PseudoConstraint.Relation) {
  return (lhs, rhs.0, rhs.1)
}

// MARK: Resolution

public func --(lhs: ([PseudoConstraint], Float, PseudoConstraint.Relation), rhs: UIView) -> [PseudoConstraint] {
  var pseudoConstraints = lhs.0
  if let lastConstraint = pseudoConstraints.last, lastView = lastConstraint.firstObject as? UIView {
    switch lastConstraint.firstAttribute.axis {
      case .Horizontal:
        switch lhs.2 {
          case .Equal:              pseudoConstraints.append(rhs.left => lastView.right + lhs.1)
          case .GreaterThanOrEqual: pseudoConstraints.append(rhs.left ≥  lastView.right + lhs.1)
          case .LessThanOrEqual:    pseudoConstraints.append(rhs.left ≤  lastView.right + lhs.1)
        }
      case .Vertical:
        switch lhs.2 {
          case .Equal:              pseudoConstraints.append(rhs.top => lastView.bottom + lhs.1)
          case .GreaterThanOrEqual: pseudoConstraints.append(rhs.top ≥  lastView.bottom + lhs.1)
          case .LessThanOrEqual:    pseudoConstraints.append(rhs.top ≤  lastView.bottom + lhs.1)
        }

    }
    return pseudoConstraints
  } else { assert(false, "at least one existing constraint with valid first object") }
}

public func --(lhs: (UILayoutConstraintAxis, Float, PseudoConstraint.Relation), rhs: UIView) -> PseudoConstraint {
  precondition(rhs.superview != nil, "this operator requires a proper view hierarchy has been established")
  switch lhs.0 {
    case .Horizontal:
      switch lhs.2 {
        case .Equal:              return rhs.left => rhs.superview!.left + lhs.1
        case .GreaterThanOrEqual: return rhs.left ≥  rhs.superview!.left + lhs.1
        case .LessThanOrEqual:    return rhs.left ≤  rhs.superview!.left + lhs.1
      }

    case .Vertical:
      switch lhs.2 {
        case .Equal:              return rhs.top => rhs.superview!.top + lhs.1
        case .GreaterThanOrEqual: return rhs.top ≥  rhs.superview!.top + lhs.1
        case .LessThanOrEqual:    return rhs.top ≤  rhs.superview!.top + lhs.1
      }

  }
}

public func --(lhs: (PseudoConstraint, Float, PseudoConstraint.Relation), rhs: UIView) -> [PseudoConstraint]  {
  return ([lhs.0], lhs.1, lhs.2) -- rhs
}

public func --(lhs: (UIView, Float, PseudoConstraint.Relation), rhs: UIView) -> PseudoConstraint {
  switch lhs.2 {
    case .Equal:              return rhs.left => lhs.0.right + lhs.1
    case .GreaterThanOrEqual: return rhs.left ≥  lhs.0.right + lhs.1
    case .LessThanOrEqual:    return rhs.left ≤  lhs.0.right + lhs.1
  }
}

// MARK: - GreaterThanOrEqual spacing prefix operator
prefix operator ≥ {}

public prefix func ≥(value: Float) -> (Float, PseudoConstraint.Relation) { return (value, .GreaterThanOrEqual) }

// MARK: - LessThanOrEqual spacing prefix operator
prefix operator ≤ {}

public prefix func ≤(value: Float) -> (Float, PseudoConstraint.Relation) { return (value, .LessThanOrEqual) }
