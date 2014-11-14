//
//  ConstraintManager.swift
//  Remote
//
//  Created by Jason Cardwell on 11/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

class ConstraintManager: NSObject {

  weak var remoteElement: RemoteElement!
  var proportionLock: Bool = false
  var subelementConstraints: [Constraint] { return [] }
  var dependentConstraints: [Constraint] { return [] }
  var dependentChildConstraints: [Constraint] { return [] }
  var dependentSiblingConstraints: [Constraint] { return [] }
  var intrinsicConstraints: [Constraint] { return [] }
  var horizontalConstraints: [Constraint] { return constraintsAffectingAxis(.Horizontal, ofOrder: .First) }
  var verticalConstraints: [Constraint] { return constraintsAffectingAxis(.Vertical, ofOrder: .First) }

  var shrinkwrap: Bool = false

  private var layoutBits = BitArray(storage: 0, count: 8)

  /**
  initWithElement:

  :param: element RemoteElement
  */
  init(element: RemoteElement) { super.init(); remoteElement = element }

  /**
  Creates and adds new `REConstraint` objects for the managed element.

  :param: format String Extended visual format string from which the constraints should be parsed.
  */
  func setConstraintsFromString(format: String) {

    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      if self.remoteElement.constraints.count > 0 { self.remoteElement.removeConstraints(self.remoteElement.constraints) }
      var directory = [self.remoteElement.identifier: self.remoteElement]
      for subelement in self.remoteElement.subelements.array as [RemoteElement] { directory[subelement.identifier] = subelement }
      for dictionary in NSLayoutConstraint.constraintDictionariesByParsingString(format) {
        if let element1ID = dictionary[MSExtendedVisualFormatItem1Name] as? String {
          if let element1 = directory[element1ID] {
            let element2ID: String? = dictionary[MSExtendedVisualFormatItem2Name] as? String
            let element2: RemoteElement? = element2ID != nil ? directory[element2ID!] : nil
            var multiplier: CGFloat = 1.0
            if let m = dictionary[MSExtendedVisualFormatMultiplierName] { multiplier = CGFloat(m.floatValue) }
            var constant: CGFloat = 0.0
            if let c = dictionary[MSExtendedVisualFormatConstantName] { constant = CGFloat(c.floatValue) }
            if let sign = dictionary[MSExtendedVisualFormatConstantOperatorName] as? String {
              if sign == "-" { constant = -constant }
            }
            if let attr1Pseudo = dictionary[MSExtendedVisualFormatAttribute1Name] as? String {
              let attr1 = NSLayoutConstraint.attributeForPseudoName(attr1Pseudo)
              if let attr2Pseudo = dictionary[MSExtendedVisualFormatAttribute2Name] as? String {
                let attr2 = NSLayoutConstraint.attributeForPseudoName(attr2Pseudo)
                if let relationPseudo = dictionary[MSExtendedVisualFormatRelationName] as? String {
                  let relation = NSLayoutConstraint.relationForPseudoName(relationPseudo)
                  let constraint = Constraint(item: element1,
                                              attribute: attr1,
                                              relatedBy: relation,
                                              toItem: element2,
                                              attribute: attr2,
                                              multiplier: multiplier,
                                              constant: constant)
                  if let priority = dictionary[MSExtendedVisualFormatPriorityName] {constraint.priority = priority.floatValue }
                  self.remoteElement.addConstraint(constraint)
                }
              }
            }
          }
        }
      }
    }

  }

  /**
  freezeSize:forSubelement:attribute:

  :param: size CGSize
  :param: subelement RemoteElement
  :param: attribute NSLayoutAttribute
  */
  func freezeSize(size: CGSize, forSubelement subelement: RemoteElement, attribute: NSLayoutAttribute) {

    let axis = UILayoutConstraintAxisForAttribute(attribute)
    let  constant = axis == .Horizontal ? size.width : size.height
    var firstAttribute: NSLayoutAttribute = axis == .Horizontal ? .Width : .Height
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      var constraintsToRemove: [Constraint] = []
      let manager = subelement.constraintManager

      switch attribute {
        case .Baseline, .Bottom:
          if subelement.constraintManager[NSLayoutAttribute.Top.rawValue] {
            constraintsToRemove += manager.constraintsForAttribute(.Top, ofOrder: .First)
          }
        case .Top:
          if subelement.constraintManager[NSLayoutAttribute.Bottom.rawValue] {
            constraintsToRemove += manager.constraintsForAttribute(.Bottom, ofOrder: .First)
          }

        case .Left, .Leading:
          if subelement.constraintManager[NSLayoutAttribute.Right.rawValue] {
            constraintsToRemove += manager.constraintsForAttribute(.Right, ofOrder: .First)
          }

        case .Right, .Trailing:
          if subelement.constraintManager[NSLayoutAttribute.Left.rawValue] {
            constraintsToRemove += manager.constraintsForAttribute(.Left, ofOrder: .First)
          }

        case .CenterX:
          if subelement.constraintManager[NSLayoutAttribute.Right.rawValue] || subelement.constraintManager[NSLayoutAttribute.Left.rawValue] {
            constraintsToRemove += manager.constraintsForAttribute(.Right, ofOrder: .First)
            constraintsToRemove += manager.constraintsForAttribute(.Left, ofOrder: .First)
          }

        case .CenterY:
          if subelement.constraintManager[NSLayoutAttribute.Top.rawValue] || subelement.constraintManager[NSLayoutAttribute.Bottom.rawValue] {
            constraintsToRemove += manager.constraintsForAttribute(.Top, ofOrder: .First)
            constraintsToRemove += manager.constraintsForAttribute(.Bottom, ofOrder: .First)
          }

        default: break
      }

      for constraint in constraintsToRemove { constraint.owner.removeConstraint(constraint) }
      subelement.addConstraint(Constraint(item: subelement,
                                          attribute: firstAttribute,
                                          relatedBy: .Equal,
                                          toItem: nil,
                                          attribute: .NotAnAttribute,
                                          multiplier: 1.0,
                                          constant: constant))

      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

 /**
 Modifies constraints such that any sibling co-dependencies are converted to parent-dependencies.
 To be frozen, the `firstAttribute` of a constraint must be included in the set of `attributes`.

 :param: constraints [Constraint] Constraints to freeze
 :param: attributes [NSLayoutAttribute] `NSLayoutAttributes` used to filter whether a constraint is frozen
 :param: metrics [String:CGRect] Dictionary of element frames keyed by their `identifier` property
 */
  func freezeConstraints(constraints: [Constraint], attributes: [NSLayoutAttribute], metrics: [String:CGRect]) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for constraint in constraints {
        if !contains(attributes, NSLayoutAttribute(rawValue: Int(constraint.firstAttribute))!) { continue }
        var constraintValues = constraint.dictionaryWithValuesForKeys(Constraint.propertyList())
        constraint.owner.removeConstraint(constraint)
        let bounds = CGRect(origin: CGPoint.zeroPoint, size: metrics[self.remoteElement.uuid]!.size)
        let frame = metrics[constraint.firstItem.uuid]!
        let attribute = NSLayoutAttribute(rawValue: (constraintValues["firstAttribute"] as NSNumber).integerValue)!
        switch attribute {
          case .Bottom:
            constraintValues["constant"] = frame.maxY - bounds.height
            constraintValues["secondAttribute"] = NSLayoutAttribute.Bottom.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as RemoteElement).parentElement!
          case .Top:
            constraintValues["constant"] = frame.minY
            constraintValues["secondAttribute"] = NSLayoutAttribute.Top.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as RemoteElement).parentElement!
          case .Left, .Leading:
            constraintValues["constant"] = frame.minX
            constraintValues["secondAttribute"] = NSLayoutAttribute.Left.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as RemoteElement).parentElement!
          case .Right, .Trailing:
            constraintValues["constant"] = frame.maxX - bounds.width
            constraintValues["secondAttribute"] = NSLayoutAttribute.Right.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as RemoteElement).parentElement!
          case .CenterX:
            constraintValues["constant"] = frame.midX - bounds.midX
            constraintValues["secondAttribute"] = NSLayoutAttribute.CenterX.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as RemoteElement).parentElement!
          case .CenterY:
            constraintValues["constant"] = frame.midY - bounds.midY
            constraintValues["secondAttribute"] = NSLayoutAttribute.CenterY.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as RemoteElement).parentElement!
          case .Width:
            constraintValues["constant"] = frame.width
            constraintValues["secondAttribute"] = NSLayoutAttribute.NotAnAttribute.rawValue
            constraintValues["owner"] = constraintValues["firstItem"]!
            constraintValues.removeValueForKey("secondItem")
          case .Height:
            constraintValues["constant"] = frame.height
            constraintValues["secondAttribute"] = NSLayoutAttribute.NotAnAttribute.rawValue
            constraintValues["owner"] = constraintValues["firstItem"]!
            constraintValues.removeValueForKey("secondItem")
          default: continue
        }
        let owner = constraintValues["owner"] as RemoteElement
        owner.addConstraint(Constraint(attributeValues: constraintValues))
      }
      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

  /**
  resizeSubelements:toSibling:attribute:metrics:

  :param: subelements [RemoteElement]
  :param: sibling RemoteElement
  :param: attribute NSLayoutAttribute
  :param: metrics [String:CGRect]
  */
  func resizeSubelements(subelements: [RemoteElement],
               toSibling sibling: RemoteElement,
               attribute: NSLayoutAttribute,
                 metrics: [String:CGRect])
  {
    let attributes: [NSLayoutAttribute] = attribute == .Width ? [.Left, .Right, .Width] : [.Top, .Bottom, .Right]
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for element in subelements {
        self.freezeConstraints(element.constraintManager.dependentSiblingConstraints, attributes: attributes, metrics: metrics)
        self.removeProportionLockForElement(element, currentSize: metrics[element.uuid]!.size)
        for constraint in element.constraintManager.constraintsForAttribute(attribute, ofOrder: .First) {
          constraint.owner.removeConstraint(constraint)
          let c = Constraint(item: element,
                             attribute: attribute,
                             relatedBy: .Equal,
                             toItem: sibling,
                             attribute: attribute,
                             multiplier: 1.0,
                             constant: 0.0)
          self.resolveConflictsForConstraint(c, metrics: metrics)
          self.remoteElement.addConstraint(c)
        }
      }
      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

  /**
  resizeElement:fromSize:toSize:metrics:

  :param: element RemoteElement
  :param: fromSize CGSize
  :param: toSize CGSize
  :param: metrics [String:CGRect]
  */
  func resizeElement(element: RemoteElement, fromSize: CGSize, toSize: CGSize, metrics: [String:CGRect]) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      if element.constraintManager.proportionLock && fromSize.width / fromSize.height != toSize.width / toSize.height {
        self.removeProportionLockForElement(element, currentSize: fromSize)
      }

      let deltaSize = fromSize - toSize
      for constraint in element.firstItemConstraints.allObjects as [Constraint] {
        let attribute = NSLayoutAttribute(rawValue: Int(constraint.firstAttribute)) ?? NSLayoutAttribute.NotAnAttribute
        switch attribute {
          case .Left, .Leading, .Right, .Trailing: constraint.constant -= Float(deltaSize.width / CGFloat(2.0))
          case .Width:
            if fromSize.width != toSize.width {
              if constraint.staticConstraint { constraint.constant = Float(toSize.width) }
              else if constraint.firstItem != constraint.secondItem { constraint.constant -= Float(deltaSize.width) }
            }
          case .Baseline, .Bottom, .Top: constraint.constant -= Float(deltaSize.height / CGFloat(2.0))
          case .Height:
            if fromSize.height != toSize.height {
              if constraint.staticConstraint { constraint.constant = Float(toSize.height) }
              else if constraint.firstItem != constraint.secondItem { constraint.constant -= Float(deltaSize.height) }
            }
          default: break
        }
      }
    }
  }

  /**
  alignSubelements:toSibling:attribute:metrics:

  :param: subelements [RemoteElement]
  :param: sibling RemoteElement
  :param: attribute NSLayoutAttribute
  :param: metrics [String:CGRect]
  */
  func alignSubelements(subelements: [RemoteElement],
              toSibling sibling: RemoteElement,
              attribute: NSLayoutAttribute,
                metrics: [String:CGRect])
  {
    let axis = UILayoutConstraintAxisForAttribute(attribute)
    let attributes: [NSLayoutAttribute] = axis == .Horizontal ? [.Left, .Right, .CenterX] : [.Top, .Bottom, .CenterY]
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for element in subelements {
        self.freezeConstraints(element.constraintManager.dependentSiblingConstraints, attributes: attributes, metrics: metrics)
        self.freezeSize(metrics[element.uuid]!.size, forSubelement: element, attribute: attribute)
        for constraint in element.constraintManager.constraintsForAttribute(attribute, ofOrder: .First) {
          constraint.owner.removeConstraint(constraint)
        }
        let c = Constraint(item: element,
                           attribute: attribute,
                           relatedBy: .Equal,
                           toItem: sibling,
                           attribute: attribute,
                           multiplier: 1.0,
                           constant: 0.0)
        self.resolveConflictsForConstraint(c, metrics: metrics)
        self.remoteElement.addConstraint(c)
        self.remoteElement.managedObjectContext?.processPendingChanges()
      }
    }
  }

  /**
  shrinkwrapSubelementsUsingMetrics:

  :param: metrics [String CGRect]
  */
  func shrinkwrapSubelementsUsingMetrics(metrics: [String:CGRect]) {

  }

  /**
  Translates the specified subelements by the specified amount.

  :param: subelements [RemoteElement] elements to be translated
  :param: translation CGPoint Amount by which s will be translated
  :param: metrics [String:CGRect] Dictionary of element frames keyed by their `identifier` property
  */
  func translateSubelements(subelements: [RemoteElement], translation: CGPoint, metrics: [String:CGRect]) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for subelement in subelements {
        self.freezeConstraints(subelement.constraintManager.dependentSiblingConstraints,
                 attributes: [.Left, .Right, .Top, .Bottom, .CenterX, .CenterY],
                       metrics: metrics)
        for constraint in subelement.firstItemConstraints.allObjects as [Constraint] {
          let attribute = NSLayoutAttribute(rawValue: Int(constraint.firstAttribute)) ?? NSLayoutAttribute.NotAnAttribute
          switch attribute {
            case .Baseline, .Bottom, .Top, .CenterY: constraint.constant += Float(translation.y)
            case .Left, .Leading, .Right, .Trailing, .CenterX: constraint.constant += Float(translation.x)
            default: break
          }
        }
      }
      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

  /**
  removeMultipliersUsingMetrics:

  :param: metrics [String CGRect]
  */
  func removeMultipliersUsingMetrics(metrics: [String:CGRect]) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for constraint in self.dependentChildConstraints {
        if constraint.multiplier != 1.0 {
          var constraintValues = constraint.dictionaryWithValuesForKeys(Constraint.propertyList())
          constraintValues["multiplier"] = 1.0
          self.remoteElement.removeConstraint(constraint)
          let frame = metrics[constraint.firstItem.uuid]!
          let bounds = CGRect(origin: CGPoint.zeroPoint, size: metrics[self.remoteElement.uuid]!.size)
          let attribute = NSLayoutAttribute(rawValue: Int(constraint.firstAttribute)) ?? NSLayoutAttribute.NotAnAttribute
          switch attribute {
            case .Baseline, .Bottom: constraintValues["constant"] = frame.maxY - bounds.height
            case .Top:               constraintValues["constant"] = frame.minY
            case .CenterY:           constraintValues["constant"] = frame.midY - bounds.height / 2.0
            case .Left, .Leading:    constraintValues["constant"] = frame.minX
            case .CenterX:           constraintValues["constant"] = frame.midX - bounds.width / 2.0
            case .Right, .Trailing:  constraintValues["constant"] = frame.maxX - bounds.width
            case .Width:             constraintValues["constant"] = frame.width - bounds.width
            case .Height:            constraintValues["constant"] = frame.height - bounds.height
            default: break
          }
          self.remoteElement.addConstraint(Constraint(attributeValues: constraintValues))
        }
      }
      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

  /**
  Modifies the constraints of an element such that width and height are not co-dependent.

  :param: element RemoteElement The element whose constraints should be altered
  :param: currentSize CGSize The size to use when calculating static width and height
  */
  func removeProportionLockForElement(element: RemoteElement, currentSize: CGSize) {
    self.remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      if element.constraintManager.proportionLock {
        if let c = element.constraintManager.intrinsicConstraints.filter({$0.secondItem == element}).first {
          let firstAttribute = NSLayoutAttribute(rawValue: Int(c.firstAttribute))!
          element.removeConstraint(c)
          element.addConstraint(Constraint(item: element,
                                           attribute: firstAttribute,
                                           relatedBy: .Equal,
                                           toItem: nil,
                                           attribute: .NotAnAttribute,
                                           multiplier: 1.0,
                                           constant: firstAttribute == .Height ? currentSize.height : currentSize.width))
          element.managedObjectContext?.processPendingChanges()
        }
      }
    }
  }

  /**
  Modifies `remoteElement` constraints to avoid unsatisfiable conditions when adding the specified constraint.

  :param: constraint Constraint `Constraint` whose addition may require conflict resolution
  :param: metrics [String:CGRect] Dictionary of element frames keyed by their `identifier` property
  */
  func resolveConflictsForConstraint(constraint: Constraint, metrics: [String:CGRect]) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      // let (replacements, additions) = constraint.manager.replacementCandidatesForAddingAttribute(constraint.firstAttribute)
    }
  }

  /**
  subscript:

  :param: attribute NSLayoutAttribute

  :returns: NSNumber?
  */
  private(set) subscript(attribute: NSLayoutAttribute.RawValue) -> Bool {
    get {
      if let attr = Attribute(attribute) { return layoutBits.isBitSet(attr.rawValue) }
      else { return false }
    }
    set {
      if let attr = Attribute(attribute) {
        if newValue { layoutBits.setBit(attr.rawValue) }
        else { layoutBits.unsetBit(attr.rawValue) }
      }
    }
  }

  /**
  subscript:

  :param: pseudo String

  :returns: NSNumber?
  */
  private(set) subscript(pseudo: String) -> Bool {
    get { return self[NSLayoutConstraint.attributeForPseudoName(pseudo).rawValue] }
    set { self[NSLayoutConstraint.attributeForPseudoName(pseudo).rawValue] = newValue }
  }

  enum Dependency: Int { case None, Parent, Sibling, Intrinsic }
  enum Relationship { case None, Parent, Child, Sibling, Intrinsic }
  enum Dimension { case XAxis, YAxis, Width, Height }
  enum Order { case None, First, Second }
  enum Affiliation { case None, FirstItem, SecondItem, Owner }

  enum Attribute: Int {

    case Height, Width, CenterY, CenterX, Bottom, Top, Right, Left

    var NSLayoutAttributeValue: NSLayoutAttribute {
      switch self {
        case .Height:  return .Height
        case .Width:   return .Width
        case .CenterY: return .CenterY
        case .CenterX: return .CenterX
        case .Bottom:  return .Bottom
        case .Top:     return .Top
        case .Right:   return .Right
        case .Left:    return .Left
      }
    }

    init?(_ raw: NSLayoutAttribute.RawValue) {
      if let attribute = NSLayoutAttribute(rawValue: raw) {
        self.init(attribute)
      } else {
        return nil
      }
    }

    /**
    init:

    :param: attribute NSLayoutAttribute
    */
    init?(_ attribute: NSLayoutAttribute) {
      switch attribute {
        case .Height:  self = .Height
        case .Width:   self = .Width
        case .CenterY: self = .CenterY
        case .CenterX: self = .CenterX
        case .Bottom:  self = .Bottom
        case .Top:     self = .Top
        case .Right:   self = .Right
        case .Left:    self = .Left
        default:       return nil
      }
    }
  }

  /**
  dependencyForAttribute:

  :param: attribute NSLayoutAttribute

  :returns: Dependency
  */
  func dependencyForAttribute(attribute: NSLayoutAttribute) -> Dependency {
    return .None
  }

  /**
  replacementCandidatesForAddingAttribute:

  :param: attribute NSLayoutAttribute

  :returns: ([NSLayoutAttribute], [NSLayoutAttribute])
  */
  func replacementCandidatesForAddingAttribute(attribute: NSLayoutAttribute) -> ([NSLayoutAttribute], [NSLayoutAttribute]) {
    return ([],[])
  }

  /**
  constraintsForAttribute:ofOrder:

  :param: attribute NSLayoutAttribute
  :param: order Order = .None

  :returns: [Constraint]
  */
  func constraintsForAttribute(attribute: NSLayoutAttribute, ofOrder order: Order = .None) -> [Constraint] {
    return []
  }

  /**
  constraintWithValues:

  :param: values [String AnyObject]

  :returns: Constraint?
  */
  func constraintWithValues(values: [String:AnyObject]) -> Constraint? {
    return nil
  }

  /**
  constraintsAffectingAxis:ofOrder:

  :param: axis UILayoutConstraintAxis
  :param: order Order = .None

  :returns: [Constraint]
  */
  func constraintsAffectingAxis(axis: UILayoutConstraintAxis, ofOrder order: Order = .None) -> [Constraint] {
    return []
  }

  /**
  UILayoutConstraintAxisForAttribute:

  :param: attribute NSLayoutAttribute

  :returns: UILayoutConstraintAxis
  */
  func UILayoutConstraintAxisForAttribute(attribute: NSLayoutAttribute) -> UILayoutConstraintAxis {
    switch attribute {
      case .Width, .Left, .Leading, .Right, .Trailing, .CenterX: return .Horizontal
      default: return .Vertical
    }
  }

}
