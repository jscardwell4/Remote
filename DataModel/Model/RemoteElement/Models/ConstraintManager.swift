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

public final class ConstraintManager: NSObject {

  public typealias Metrics = [UUIDIndex:CGRect]

  public private(set) weak var remoteElement: RemoteElement!
  public var proportionLock: Bool = false

  public var receptionist: MSContextChangeReceptionist?

  public var subelementConstraints: Set<Constraint> { return remoteElement.constraints ∖ intrinsicConstraints }
  public var dependentConstraints: Set<Constraint> { return remoteElement.secondItemConstraints ∖ intrinsicConstraints }
  public var dependentChildConstraints: Set<Constraint> {
    return filter(dependentConstraints) {$0.firstItem != nil && self.remoteElement.subelements ∋ $0.firstItem!}
  }
  public var dependentSiblingConstraints: Set<Constraint> { return dependentConstraints ∖ dependentChildConstraints }
  public var intrinsicConstraints: Set<Constraint> {
    return filter(remoteElement.constraints,
               includeElement: {Set(compressed([$0.firstItem, $0.secondItem])).isSubsetOf([self.remoteElement])})
  }

  public var horizontalConstraints: Set<Constraint> {
    return filter(remoteElement.firstItemConstraints, includeElement: {.Horizontal == $0.firstAttribute.axis })
  }

  public var verticalConstraints: Set<Constraint> {
    return filter(remoteElement.firstItemConstraints, includeElement: {.Vertical == $0.firstAttribute.axis })
  }

  public var shrinkwrap: Bool = false

  private var layoutBits = BitArray(storage: 0, count: 8)
  private var relationships = [Relationship](count: 8, repeatedValue: .None)

  /**
  initWithElement:

  - parameter element: RemoteElement
  */
  public init(element: RemoteElement) { super.init(); remoteElement = element; refreshConfig() }


  /**
  replacementFormatForString:

  - parameter format: String

  - returns: String
  */
  public func replacementFormatForString(format: String) -> String {

    var identifiers = [remoteElement.identifier]
    identifiers.extend(remoteElement.subelements.map{$0.identifier})

    let regex = ~/"\\$([0-9]+)"
    let matches = regex.match(format)
    let matchingRanges = matches.flatMap { $0.captures[0]?.range }
    var replacementFormat = format
    var removeCount = 0
    var insertCount = 0
    for r in matchingRanges {
      let matchedSubstring = String(format.utf16[r])!
      let i = Int(String(dropFirst(matchedSubstring.characters)))!
      let replacement = identifiers[i]
      let start = advance(replacementFormat.startIndex, distance(format.utf16.startIndex, r.startIndex) + insertCount - removeCount)
      let end = advance(replacementFormat.startIndex, distance(format.utf16.startIndex, r.endIndex) + insertCount - removeCount)
      let indexRange = Range<String.Index>(start: start, end: end)

      replacementFormat.replaceRange(indexRange, with: identifiers[i])
      removeCount += matchedSubstring.characters.count
      insertCount += replacement.characters.count
    }
    let result = replacementFormat.stringByReplacingOccurrencesOfString("self", withString: remoteElement.identifier)
    return result
  }

  /**
  Creates and adds new `Constraint` objects for the managed element.

  - parameter format: String Extended visual format string from which the constraints should be parsed.
  */
  public func setConstraintsFromString(format: String) {


    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      let pseudoConstraints = PseudoConstraint.pseudoConstraintsByParsingFormat(format)

      if self.remoteElement.constraints.count > 0 {
        self.remoteElement.managedObjectContext?.deleteObjects(self.remoteElement.constraints as Set<NSObject>)
      }

      var directory: OrderedDictionary<String, RemoteElement> = [self.remoteElement.identifier: self.remoteElement]
      apply(self.remoteElement.subelements){directory.setValue($0, forKey: $0.identifier)}

      var constraints: Set<Constraint> = []
      apply(pseudoConstraints){
        if let c = Constraint.constraintFromPseudoConstraint($0, usingDirectory: directory) { constraints.insert(c) }
      }

      self.remoteElement.constraints = constraints

    }

  }

  /**
  freezeSize:forSubelement:attribute:

  - parameter size: CGSize
  - parameter subelement: RemoteElement
  - parameter attribute: NSLayoutAttribute
  */
  public func freezeSize(size: CGSize, forSubelement subelement: RemoteElement, attribute: NSLayoutAttribute) {

    let constant = Float(attribute.axis == .Horizontal ? size.width : size.height)
    let firstAttribute: NSLayoutAttribute = attribute.axis == .Horizontal ? .Width : .Height
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      var constraintsToRemove: [Constraint] = []
      let manager = subelement.constraintManager

      switch attribute {
        case .Baseline, .Bottom:
          if subelement.constraintManager[.Top] {
            constraintsToRemove += manager.constraintsForAttribute(.Top)
          }
        case .Top:
          if subelement.constraintManager[.Bottom] {
            constraintsToRemove += manager.constraintsForAttribute(.Bottom)
          }

        case .Left, .Leading:
          if subelement.constraintManager[.Right] {
            constraintsToRemove += manager.constraintsForAttribute(.Right)
          }

        case .Right, .Trailing:
          if subelement.constraintManager[.Left] {
            constraintsToRemove += manager.constraintsForAttribute(.Left)
          }

        case .CenterX:
          if subelement.constraintManager[.Right] || subelement.constraintManager[.Left] {
            constraintsToRemove += manager.constraintsForAttribute(.Right)
            constraintsToRemove += manager.constraintsForAttribute(.Left)
          }

        case .CenterY:
          if subelement.constraintManager[.Top] || subelement.constraintManager[.Bottom] {
            constraintsToRemove += manager.constraintsForAttribute(.Top)
            constraintsToRemove += manager.constraintsForAttribute(.Bottom)
          }

        default: break
      }

      self.remoteElement.managedObjectContext?.deleteObjects(NSSet(array: constraintsToRemove) as Set<NSObject>)
      let constraint = Constraint(item: subelement, attribute: firstAttribute, constant: constant)
      constraint.owner = subelement

      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

 /**
 Modifies constraints such that any sibling co-dependencies are converted to parent-dependencies.
 To be frozen, the `firstAttribute` of a constraint must be included in the set of `attributes`.

 - parameter constraints: [Constraint] Constraints to freeze
 - parameter attributes: [NSLayoutAttribute] `NSLayoutAttributes` used to filter whether a constraint is frozen
 - parameter metrics: Metrics Dictionary of element frames keyed by their `identifier` property
 */
  public func freezeConstraints(constraints: Set<Constraint>, attributes: [NSLayoutAttribute], metrics: Metrics) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in


      for constraint in constraints {
        if attributes ∌ constraint.firstAttribute || constraint.firstItem == nil { continue }
        var constraintValues = constraint.dictionaryWithValuesForKeys(Constraint.propertyList() as! [String])
        constraint.managedObjectContext?.deleteObject(constraint)
        let bounds = CGRect(origin: CGPoint.zeroPoint, size: metrics[self.remoteElement.uuidIndex]!.size)
        let frame = metrics[constraint.firstItem!.uuidIndex]!
        let attribute = NSLayoutAttribute(rawValue: (constraintValues["firstAttribute"] as! NSNumber).integerValue)!
        switch attribute {
          case .Bottom:
            constraintValues["constant"] = frame.maxY - bounds.height
            constraintValues["secondAttribute"] = NSLayoutAttribute.Bottom.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as! RemoteElement).parentElement!
          case .Top:
            constraintValues["constant"] = frame.minY
            constraintValues["secondAttribute"] = NSLayoutAttribute.Top.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as! RemoteElement).parentElement!
          case .Left, .Leading:
            constraintValues["constant"] = frame.minX
            constraintValues["secondAttribute"] = NSLayoutAttribute.Left.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as! RemoteElement).parentElement!
          case .Right, .Trailing:
            constraintValues["constant"] = frame.maxX - bounds.width
            constraintValues["secondAttribute"] = NSLayoutAttribute.Right.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as! RemoteElement).parentElement!
          case .CenterX:
            constraintValues["constant"] = frame.midX - bounds.midX
            constraintValues["secondAttribute"] = NSLayoutAttribute.CenterX.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as! RemoteElement).parentElement!
          case .CenterY:
            constraintValues["constant"] = frame.midY - bounds.midY
            constraintValues["secondAttribute"] = NSLayoutAttribute.CenterY.rawValue
            constraintValues["secondItem"] = (constraintValues["firstItem"] as! RemoteElement).parentElement!
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
        if let c = Constraint.constraintWithValues(constraintValues) {
          if let owner = constraintValues["owner"] as? RemoteElement { c.owner = owner }
        }
      }
      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

  /**
  resizeSubelements:toSibling:attribute:metrics:

  - parameter subelements: [RemoteElement]
  - parameter sibling: RemoteElement
  - parameter attribute: NSLayoutAttribute
  - parameter metrics: Metrics
  */
  public func resizeSubelements(subelements: [RemoteElement], toSibling sibling: RemoteElement, attribute: NSLayoutAttribute,
                 metrics: Metrics)
  {
    let attributes: [NSLayoutAttribute] = attribute == .Width ? [.Left, .Right, .Width] : [.Top, .Bottom, .Right]
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for element in subelements {
        self.freezeConstraints(element.constraintManager.dependentSiblingConstraints, attributes: attributes, metrics: metrics)
        self.removeProportionLockForElement(element, currentSize: metrics[element.uuidIndex]!.size)
        for constraint in element.constraintManager.constraintsForAttribute(attribute) {
          constraint.managedObjectContext?.deleteObject(constraint)
          let c = Constraint(item: element,
                             attribute: attribute,
                             relatedBy: .Equal,
                             toItem: sibling,
                             attribute: attribute,
                             multiplier: 1.0,
                             constant: 0.0)
          self.resolveConflictsForConstraint(c, metrics: metrics)
          c.owner = self.remoteElement
        }
      }
      self.remoteElement.managedObjectContext?.processPendingChanges()
    }
  }

  /**
  resizeElement:fromSize:toSize:metrics:

  - parameter element: RemoteElement
  - parameter fromSize: CGSize
  - parameter toSize: CGSize
  - parameter metrics: Metrics
  */
  public func resizeElement(element: RemoteElement, fromSize: CGSize, toSize: CGSize, metrics: Metrics) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      if element.constraintManager.proportionLock && fromSize.width / fromSize.height != toSize.width / toSize.height {
        self.removeProportionLockForElement(element, currentSize: fromSize)
      }

      let deltaSize = fromSize - toSize
      for constraint in element.firstItemConstraints {
        switch constraint.firstAttribute {
          case .Left, .Leading, .Right, .Trailing: constraint.constant -= Float(deltaSize.width) / 2.0
          case .Width:
            if fromSize.width != toSize.width {
              if constraint.staticConstraint { constraint.constant = Float(toSize.width) }
              else if constraint.firstItem != constraint.secondItem { constraint.constant -= Float(deltaSize.width) }
            }
          case .Baseline, .Bottom, .Top: constraint.constant -= Float(deltaSize.height) / 2.0
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

  - parameter subelements: [RemoteElement]
  - parameter sibling: RemoteElement
  - parameter attribute: NSLayoutAttribute
  - parameter metrics: Metrics
  */
  public func alignSubelements(subelements: [RemoteElement],
                     toSibling sibling: RemoteElement,
                     attribute: NSLayoutAttribute,
                       metrics: Metrics)
  {
    let attributes: [NSLayoutAttribute] = attribute.axis == .Horizontal ? [.Left, .Right, .CenterX] : [.Top, .Bottom, .CenterY]
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for element in subelements {
        self.freezeConstraints(element.constraintManager.dependentSiblingConstraints, attributes: attributes, metrics: metrics)
        self.freezeSize(metrics[element.uuidIndex]!.size, forSubelement: element, attribute: attribute)
        for constraint in element.constraintManager.constraintsForAttribute(attribute) {
          constraint.managedObjectContext?.deleteObject(constraint)
        }
        let c = Constraint(item: element,
                           attribute: attribute,
                           relatedBy: .Equal,
                           toItem: sibling,
                           attribute: attribute,
                           multiplier: 1.0,
                           constant: 0.0)
        self.resolveConflictsForConstraint(c, metrics: metrics)
        c.owner = self.remoteElement
        self.remoteElement.managedObjectContext?.processPendingChanges()
      }
    }
  }

  /**
  shrinkwrapSubelementsUsingMetrics:

  - parameter metrics: [String CGRect]
  */
  public func shrinkwrapSubelementsUsingMetrics(metrics: Metrics) {

    var filteredMetrics = metrics
    filteredMetrics[remoteElement.uuidIndex] = nil
    if remoteElement.parentElement != nil { filteredMetrics[remoteElement.parentElement!.uuidIndex] = nil }

    let (minX, maxX, minY, maxY) = Array(filteredMetrics.values).reduce((CGFloat.max, CGFloat.min, CGFloat.max, CGFloat.min)) {
      (min($0.0, $1.minX), max($0.1, $1.maxX), min($0.2, $1.minY), max($0.3, $1.maxY))
    }

    let currentSize = metrics[remoteElement.uuidIndex]?.size ?? CGSize.zeroSize
    let contractX = minX > 0 ? -minX : (maxX < currentSize.width ? currentSize.width - maxX : 0.0)
    let contractY = minY > 0 ? -minY : (maxY < currentSize.height ? currentSize.height - maxY : 0.0)
    let expandX = maxX > currentSize.width ? maxX - currentSize.width : (minX < 0 ? minX : 0.0)
    let expandY = maxY > currentSize.height ? maxY - currentSize.height : (minY < 0 ? minY : 0.0)
    let offsetX = contractX < 0 ? contractX : (expandX < 0 ? -expandX : 0.0)
    let offsetY = contractY < 0 ? contractY : (expandY < 0 ? -expandY : 0.0)
    var boundingSize = UIScreen.mainScreen().bounds.size
    if remoteElement.parentElement != nil {
      if let parentFrame = metrics[remoteElement.parentElement!.uuidIndex] { boundingSize = parentFrame.size}
    }

    let newSize = CGSize(width: min(boundingSize.width, maxX - minX), height: min(boundingSize.height, maxY - minY))
    if currentSize == newSize { return }

    resizeElement(remoteElement, fromSize: currentSize, toSize: newSize, metrics: metrics)
    removeMultipliersUsingMetrics(metrics)

    let delta = newSize - currentSize

    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for constraint in self.dependentChildConstraints {
        switch constraint.firstAttribute {
          case .Baseline, .Bottom, .Top, .CenterY:
            if contractY == 0 {
              constraint.constant += Float(offsetY != 0 ? offsetY / 2.0 : -expandY / 2.0)
            } else {
              constraint.constant += Float(offsetY - delta.height / 2.0)
            }

          case .Left, .Leading, .Right, .Trailing, .CenterX:
            if contractX == 0 {
              constraint.constant += Float(offsetX != 0 ? offsetX / 2.0 : -expandX / 2.0)
            } else {
              constraint.constant += Float(offsetX - delta.width / 2.0)
            }

          case .Width:
            constraint.constant -= Float(delta.width)

          case .Height:
            constraint.constant -= Float(delta.height)

          default: break
        }
      }
      self.remoteElement.managedObjectContext?.processPendingChanges()
    }

  }

  /**
  Translates the specified subelements by the specified amount.

  - parameter subelements: [RemoteElement] elements to be translated
  - parameter translation: CGPoint Amount by which s will be translated
  - parameter metrics: Metrics Dictionary of element frames keyed by their `identifier` property
  */
  public func translateSubelements(subelements: [RemoteElement], translation: CGPoint, metrics: Metrics) {
    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      for subelement in subelements {
        self.freezeConstraints(subelement.constraintManager.dependentSiblingConstraints,
                 attributes: [.Left, .Right, .Top, .Bottom, .CenterX, .CenterY],
                       metrics: metrics)
        for constraint in subelement.firstItemConstraints {
          switch constraint.firstAttribute {
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

  - parameter metrics: [String CGRect]
  */
  public func removeMultipliersUsingMetrics(metrics: Metrics) {

    if let remoteElementFrame = metrics[remoteElement.uuidIndex] {

      let boundingWidth = remoteElementFrame.width
      let boundingHeight = remoteElementFrame.height

      remoteElement.managedObjectContext?.performBlockAndWait {
        [unowned self] () -> Void in

        for constraint in self.dependentChildConstraints {
          if constraint.multiplier != 1.0 {
            var constraintValues = constraint.dictionaryWithValuesForKeys(Constraint.propertyList() as! [String])
            constraintValues["multiplier"] = 1.0
            self.remoteElement.managedObjectContext?.deleteObject(constraint)
            precondition(constraintValues["firstItem"] != nil)
            if let frame = metrics[(constraintValues["firstItem"] as! RemoteElement).uuidIndex] {
              switch constraint.firstAttribute {
                case .Baseline, .Bottom: constraintValues["constant"] = frame.maxY - boundingHeight
                case .Top:               constraintValues["constant"] = frame.minY
                case .CenterY:           constraintValues["constant"] = frame.midY - boundingHeight / 2.0
                case .Left, .Leading:    constraintValues["constant"] = frame.minX
                case .CenterX:           constraintValues["constant"] = frame.midX - boundingWidth / 2.0
                case .Right, .Trailing:  constraintValues["constant"] = frame.maxX - boundingWidth
                case .Width:             constraintValues["constant"] = frame.width - boundingWidth
                case .Height:            constraintValues["constant"] = frame.height - boundingHeight
                default: break
              }
              if let c = Constraint.constraintWithValues(constraintValues) { c.owner = self.remoteElement }
            }
          }
        }
        self.remoteElement.managedObjectContext?.processPendingChanges()
      }
    }
  }

  /**
  Modifies the constraints of an element such that width and height are not co-dependent.

  - parameter element: RemoteElement The element whose constraints should be altered
  - parameter currentSize: CGSize The size to use when calculating static width and height
  */
  public func removeProportionLockForElement(element: RemoteElement, currentSize: CGSize) {
    self.remoteElement.managedObjectContext?.performBlockAndWait {
      () -> Void in

      if element.constraintManager.proportionLock {
        if let constraint = element.constraintManager.intrinsicConstraints.filter({$0.secondItem == element}).first {
          let firstAttribute = constraint.firstAttribute
          constraint.managedObjectContext?.deleteObject(constraint)

          let c = Constraint(item: element,
                             attribute: firstAttribute,
                             relatedBy: NSLayoutRelation.Equal,
                             toItem: nil,
                             attribute: NSLayoutAttribute.NotAnAttribute,
                             multiplier: 1.0,
                             constant: Float(firstAttribute == .Height ? currentSize.height : currentSize.width))
          c.owner = element
          element.managedObjectContext?.processPendingChanges()
        }
      }
    }
  }

  /**
  Modifies `remoteElement` constraints to avoid unsatisfiable conditions when adding the specified constraint.

  - parameter constraint: Constraint `Constraint` whose addition may require conflict resolution
  - parameter metrics: Metrics Dictionary of element frames keyed by their `identifier` property
  */
  public func resolveConflictsForConstraint(constraint: Constraint, metrics: Metrics) {

    if constraint.firstItem == nil { return }

    remoteElement.managedObjectContext?.performBlockAndWait {
      [unowned self] () -> Void in

      let (replacements, additions) = constraint.manager!.replacementCandidatesForAddingAttribute(constraint.firstAttribute)
      let constraintsToRemove = constraint.firstItem!.firstItemConstraints.filter {replacements ∋ $0.firstAttribute}
      self.remoteElement.managedObjectContext?.deleteObjects(Set(constraintsToRemove))

      let frame = metrics[constraint.firstItem!.uuidIndex]!
      let bounds = frame.rectWithOrigin(CGPoint.zeroPoint)

      for firstAttribute in additions {

        var constant: CGFloat = 0.0
        var owner = self.remoteElement
        let firstItem = constraint.firstItem!
        var secondItem: RemoteElement?
        var secondAttribute: NSLayoutAttribute = .NotAnAttribute

        switch firstAttribute {

          case .CenterX:
            secondItem = self.remoteElement
            secondAttribute = .CenterX
            constant = frame.midX - bounds.midX

          case .CenterY:
            secondItem = self.remoteElement
            secondAttribute = .CenterY
            constant = frame.midY - bounds.midY

          case .Width:
            owner = firstItem
            constant = frame.width

          case .Height:
            owner = firstItem
            constant = frame.height

          default: continue

        }

        let c = Constraint(item: firstItem,
                           attribute: firstAttribute,
                           relatedBy: .Equal,
                           toItem: secondItem,
                           attribute: secondAttribute,
                           multiplier: 1.0,
                           constant: Float(constant))
        c.owner = owner

      }

      self.remoteElement.managedObjectContext?.processPendingChanges()

    }

  }

  /**
  subscript:

  - parameter attribute: NSLayoutAttribute

  - returns: NSNumber?
  */
  private(set) public subscript(attribute: Attribute) -> Bool {
    get { return layoutBits.isBitSet(attribute.rawValue) }
    set {
      if newValue { layoutBits.setBit(attribute.rawValue) }
      else { layoutBits.unsetBit(attribute.rawValue) }
    }
  }

  public enum Dependency: Int { case None, Parent, Sibling, Intrinsic }
  public enum Relationship { case None, Parent, Child, Sibling, Intrinsic }
  public enum Dimension { case XAxis, YAxis, Width, Height }
  public enum Order { case None, First, Second }
  public typealias Affiliation = (first: Bool, second: Bool, owner: Bool)

  public enum Attribute: Int {

    case Height, Width, CenterY, CenterX, Bottom, Top, Right, Left

    public var NSLayoutAttributeValue: NSLayoutAttribute {
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

    /**
    init:

    - parameter attribute: NSLayoutAttribute
    */
    public init?(_ attribute: NSLayoutAttribute) {
      switch attribute {
        case .Height:   self = .Height
        case .Width:    self = .Width
        case .CenterY:  self = .CenterY
        case .CenterX:  self = .CenterX
        case .Bottom,
             .Baseline: self = .Bottom
        case .Top:      self = .Top
        case .Right,
             .Trailing: self = .Right
        case .Left,
             .Leading:  self = .Left
        default:        return nil
      }
    }
  }

  /**
  dependencyForAttribute:

  - parameter attribute: NSLayoutAttribute

  - returns: Dependency
  */
  public func dependencyForAttribute(attribute: Attribute) -> Dependency {
    if !self[attribute] { return .None }
    else {
      switch relationships[attribute.rawValue] {
        case .Parent:    return .Parent
        case .Sibling:   return .Sibling
        case .Intrinsic: return .Intrinsic
        default:         return .None
      }
    }
  }

  /**
  replacementCandidatesForAddingAttribute:

  - parameter attribute: NSLayoutAttribute

  - returns: ([NSLayoutAttribute], [NSLayoutAttribute])
  */
  public func replacementCandidatesForAddingAttribute(attribute: NSLayoutAttribute) -> ([NSLayoutAttribute], [NSLayoutAttribute]) {
    switch attribute {
      case .Baseline, .Bottom:
        if self[.Height] { return self[.CenterY] ? ([.CenterY], []) : ([.Top], []) }
        else { return ([.CenterY, .Top], [.Height]) }

      case .Top:
        if self[.Height] { return self[.CenterY] ? ([.CenterY], []) : ([.Bottom], []) }
        else { return ([.CenterY, .Bottom], [.Height]) }

      case .Left, .Leading:
        if self[.Width] { return self[.CenterX] ? ([.CenterX], []) : ([.Right], []) }
        else { return ([.CenterX, .Right], [.Width]) }

      case .Right, .Trailing:
        if self[.Width] { return self[.CenterX] ? ([.CenterX], []) : ([.Left], []) }
        else { return ([.CenterX, .Left], [.Width]) }

      case .CenterX:
        if self[.Width] { return self[.Top] ? ([.Left], []) : ([.Right], []) }
        else { return ([.Left, .Right], [.Width]) }

      case .CenterY:
        if self[.Height] { return self[.CenterY] ? ([.Top], []) : ([.Bottom], []) }
        else { return ([.Top, .Bottom], [.Height]) }

      case .Width:
        if self[.CenterX] { return self[.Left] ? ([.Left], []) : ([.Right], []) }
        else { return ([.Left, .Right], [.CenterX]) }

      case .Height:
        if self[.CenterY] { return self[.Top] ? ([.Top], []) : ([.Bottom], []) }
        else { return ([.Top, .Bottom], [.CenterY]) }

      default: return ([],[])
    }
  }

  /** refreshConfig */
  private func refreshConfig() {
    proportionLock = false
    layoutBits.unsetAllBits()
    for constraint in remoteElement.firstItemConstraints {
      if let attribute = Attribute(constraint.firstAttribute) {
        self[attribute] = true
        var firstItem: RemoteElement!
        var secondItem: RemoteElement?
        var owner: RemoteElement?
        if constraint.deleted {
          let deletedValues = constraint.committedValuesForKeys(["firstItem", "secondItem", "owner"])
          if let item = deletedValues["firstItem"] as? RemoteElement { firstItem = item }
          if let item = deletedValues["secondItem"] as? RemoteElement { secondItem = item }
          if let item = deletedValues["owner"] as? RemoteElement { owner = item }
        } else {
          firstItem = constraint.firstItem
          secondItem = constraint.secondItem
          owner = constraint.owner
        }

        let affiliation: Affiliation = (first: firstItem == remoteElement,
                                        second: secondItem != nil && secondItem! == remoteElement,
                                        owner: owner != nil && owner! == remoteElement)
        var relationship: Relationship = .None

        if affiliation.first && (secondItem == nil || affiliation.second) {
          relationship = .Intrinsic
        } else if firstItem.parentElement != nil && secondItem != nil {
          if affiliation.first && firstItem.parentElement! == secondItem! {
            relationship = .Child
          } else if affiliation.second && firstItem.parentElement! == secondItem! {
            relationship = .Parent
          } else if secondItem!.parentElement != nil && firstItem.parentElement! == secondItem!.parentElement! {
            relationship = .Sibling
          }
        }

        relationships[attribute.rawValue] = relationship
        if !proportionLock {
          proportionLock = (secondItem != nil
                            && firstItem == secondItem!
                            && (constraint.firstAttribute == .Width || constraint.firstAttribute == .Height))
        }
      }
    }
    if receptionist == nil {
      receptionist = MSContextChangeReceptionist(
        observer: self,
        forObject: remoteElement,
        notificationName: NSManagedObjectContextObjectsDidChangeNotification,
        updateHandler: {
          (rec: MSContextChangeReceptionist!) -> Void in
            if let obj = rec.object as? RemoteElement {
              if obj.hasChangesForKey("firstItemConstraints") {
                if let m = rec.observer as? ConstraintManager {
                  m.refreshConfig()
                }
              }
            }
          },
          deleteHandler: nil)
    }
  }

  /**
  constraintsForAttribute:ofOrder:

  - parameter attribute: NSLayoutAttribute
  - parameter order: Order = .None

  - returns: [Constraint]
  */
  public func constraintsForAttribute(attribute: NSLayoutAttribute, ofOrder order: Order = .None) -> Set<Constraint> {
    switch order {
      case .None, .First:  return filter(remoteElement.firstItemConstraints, includeElement: { $0.firstAttribute == attribute })
      case .Second:        return filter(remoteElement.secondItemConstraints, includeElement: { $0.secondAttribute == attribute })
    }
  }

  /**
  constraintWithValues:

  - parameter values: [String AnyObject]

  - returns: Constraint?
  */
//  public func constraintWithValues(values: [String:AnyObject]) -> Constraint? {
//    assert(false, "what is using this? why are we checking the first item constraints?")
//    return remoteElement.firstOrderConstraints.filter{$0.hasAttributeValues(values)}.first
//  }

  public var layoutDescription: String {
    var string = ""
    let attributes: [Attribute] = [.Height, .Width, .CenterY, .CenterX, .Bottom, .Top, .Left, .Right]
    for attribute in attributes {
      switch attribute {
        case .Height:  if layoutBits[attribute.rawValue] { string += "H" }
        case .Width:   if layoutBits[attribute.rawValue] { string += "W" }
        case .CenterY: if layoutBits[attribute.rawValue] { string += "Y" }
        case .CenterX: if layoutBits[attribute.rawValue] { string += "X" }
        case .Bottom:  if layoutBits[attribute.rawValue] { string += "B" }
        case .Top:     if layoutBits[attribute.rawValue] { string += "T" }
        case .Left:    if layoutBits[attribute.rawValue] { string += "L" }
        case .Right:   if layoutBits[attribute.rawValue] { string += "R" }
      }
    }
    return string
  }

  public var layoutBinaryDescription: String { return layoutBits.description }


}
