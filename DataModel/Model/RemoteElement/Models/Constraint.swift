//
//  Constraint.swift
//  Remote
//
//  Created by Jason Cardwell on 11/14/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

@objc(Constraint)
public final class Constraint: ModelObject, Printable, DebugPrintable {

  public var pseudoConstraint: NSLayoutPseudoConstraint {
    var pseudo = NSLayoutPseudoConstraint()
    pseudo.firstItem = firstItem.identifier
    pseudo.firstAttribute = firstAttribute.pseudoName
    pseudo.relation = relation.pseudoName
    pseudo.secondItem = secondItem?.identifier
    pseudo.secondAttribute = secondAttribute.pseudoName
    pseudo.multiplier = "\(multiplier)"
    pseudo.constant = (constant < 0.0 ? "-" : "+") + "\(abs(constant))"
    pseudo.priority = "\(priority)"
    pseudo.identifier = identifier
    return pseudo
  }

  @NSManaged public var identifier: String?

  @NSManaged var primitiveTag: NSNumber
  public var tag: Int {
    get { willAccessValueForKey("tag"); let tag = primitiveTag.integerValue; didAccessValueForKey("tag"); return tag }
    set { willChangeValueForKey("tag"); primitiveTag = newValue; didChangeValueForKey("tag") }
  }

  @NSManaged var primitiveFirstAttribute: NSNumber
  public var firstAttribute: NSLayoutAttribute {
    get {
      willAccessValueForKey("firstAttribute")
      let attribute = NSLayoutAttribute(rawValue: primitiveFirstAttribute.integerValue)
      didAccessValueForKey("firstAttribute")
      return attribute ?? .NotAnAttribute
    }
    set {
      willChangeValueForKey("firstAttribute")
      primitiveFirstAttribute = newValue.rawValue
      didChangeValueForKey("firstAttribute")
    }
  }

  @NSManaged var primitiveSecondAttribute: NSNumber
  public var secondAttribute: NSLayoutAttribute {
    get {
      willAccessValueForKey("secondAttribute")
      let attribute = NSLayoutAttribute(rawValue: primitiveSecondAttribute.integerValue)
      didAccessValueForKey("secondAttribute")
      return attribute ?? .NotAnAttribute
    }
    set {
      willChangeValueForKey("secondAttribute")
      primitiveSecondAttribute = newValue.rawValue
      didChangeValueForKey("secondAttribute")
    }
  }

  @NSManaged var primitiveRelation: NSNumber
  public var relation: NSLayoutRelation {
    get {
      willAccessValueForKey("relation")
      let relation = NSLayoutRelation(rawValue: primitiveRelation.integerValue)
      didAccessValueForKey("relation")
      return relation ?? .Equal
    }
    set {
      willChangeValueForKey("relation")
      primitiveRelation = newValue.rawValue
      didChangeValueForKey("relation")
    }
  }

  @NSManaged var primitiveMultiplier: NSNumber
  public var multiplier: CGFloat {
    get {
      willAccessValueForKey("multiplier")
      let multiplier = CGFloat(primitiveMultiplier.doubleValue)
      didAccessValueForKey("multiplier")
      return multiplier
    }
    set {
      willChangeValueForKey("multiplier")
      primitiveMultiplier = Double(newValue)
      didChangeValueForKey("multiplier")
    }
  }

  @NSManaged var primitiveConstant: NSNumber
  public var constant: CGFloat {
    get {
      willAccessValueForKey("constant")
      let constant = CGFloat(primitiveConstant.doubleValue)
      didAccessValueForKey("constant")
      return constant
    }
    set {
      willChangeValueForKey("constant")
      primitiveConstant = Double(newValue)
      didChangeValueForKey("constant")
    }
  }

  @NSManaged public var firstItem: RemoteElement!
  @NSManaged public var secondItem: RemoteElement?
  @NSManaged public var owner: RemoteElement?

  @NSManaged var primitivePriority: NSNumber!
  public var priority: UILayoutPriority {
    get {
      willAccessValueForKey("priority")
      let priority = primitivePriority.floatValue
      didAccessValueForKey("priority")
      return priority
    }
    set {
      willChangeValueForKey("priority")
      primitivePriority = newValue
      didChangeValueForKey("priority")
    }
  }

  /**
  init:attribute:relatedBy:toItem:attribute:multiplier:constant:

  :param: firstItem RemoteElement
  :param: firstAttribute NSLayoutAttribute
  :param: relation NSLayoutRelation
  :param: seconditem RemoteElement?
  :param: secondAttribute NSLayoutAttribute
  :param: multiplier CGFloat
  :param: constant CGFloat
  */
  public convenience init(item firstItem: RemoteElement,
                   attribute firstAttribute: NSLayoutAttribute,
                   relatedBy relation: NSLayoutRelation,
                   toItem seconditem: RemoteElement?,
                   attribute secondAttribute: NSLayoutAttribute,
                   multiplier: CGFloat,
                   constant: CGFloat)
  {
    assert(firstItem.managedObjectContext != nil)
    self.init(context: firstItem.managedObjectContext!)
    self.firstItem = firstItem
    self.firstAttribute = firstAttribute
    self.relation = relation
    self.secondItem = seconditem
    self.secondAttribute = secondAttribute
    self.multiplier = multiplier
    self.constant = constant
  }

  /**
  initWithValues:

  :param: values [String AnyObject]
  */
  public class func constraintWithValues(values: [String:AnyObject]) -> Constraint? {
    let firstItem = values["firstItem"] as? RemoteElement
    let firstAttribute = values["firstAttribute"] as? NSNumber
    let relation = values["relation"] as? NSNumber
    let secondItem = values["secondItem"] as? RemoteElement
    let secondAttribute = values["secondAttribute"] as? NSNumber
    let multiplier = values["multiplier"] as? NSNumber
    let constant = values["constant"] as? NSNumber
    if firstItem == nil || firstAttribute == nil || relation == nil || secondAttribute == nil { return nil }
    else { return Constraint(item: firstItem!,
                             attribute: NSLayoutAttribute(rawValue: firstAttribute!.integerValue)!,
                             relatedBy: NSLayoutRelation(rawValue: relation!.integerValue)!,
                             toItem: secondItem,
                             attribute: NSLayoutAttribute(rawValue: secondAttribute!.integerValue)!,
                             multiplier: CGFloat(multiplier?.doubleValue ?? 1.0),
                             constant: CGFloat(constant?.doubleValue ?? 0.0)) }
  }

  /**
  elementFromDirectory:RemoteElement>:forString:

  :param: directory OrderedDictionary<String
  :param: RemoteElement>
  :param: string String

  :returns: RemoteElement?
  */
  public class func elementFromDirectory(directory: OrderedDictionary<String, RemoteElement>,
                        forString string: String) -> RemoteElement?
  {
    var element: RemoteElement?
    if string.hasPrefix("$") {
      let i = dropFirst(string).toInt()!
      if contains(0..<directory.count, i) { element = directory.values[i] }
    }
    else { element = directory[string] }
    return element
  }

  /**
  constraintFromPseudoConstraint:

  :param: pseudo NSLayoutPseudoConstraint

  :returns: Constraint?
  */
  public class func constraintFromPseudoConstraint(pseudo: NSLayoutPseudoConstraint,
                              usingDirectory directory: OrderedDictionary<String, RemoteElement>) -> Constraint?
  {
    var constraint: Constraint?
    if let firstElement = elementFromDirectory(directory, forString: pseudo.firstItem) {
      var secondElement: RemoteElement?
      if pseudo.secondItem != nil { secondElement = elementFromDirectory(directory, forString: pseudo.secondItem!) }
      let secondAttribute = NSLayoutAttribute(pseudoName: pseudo.secondAttribute)
      if secondAttribute == .NotAnAttribute || secondElement != nil {
        let firstAttribute = NSLayoutAttribute(pseudoName: pseudo.firstAttribute)
        let relation = NSLayoutRelation(pseudoName: pseudo.relation)
        var multiplier: CGFloat = 1.0
        if let m = pseudo.multiplier { multiplier = CGFloat((m as NSString).floatValue) }
        var constant: CGFloat = 0.0
        if let c = pseudo.constant { constant = CGFloat((c as NSString).floatValue) }
        constraint = Constraint(item: firstElement,
                                attribute: firstAttribute,
                                relatedBy: relation,
                                toItem: secondElement,
                                attribute: secondAttribute,
                                multiplier: multiplier,
                                constant: constant)
        var priority: Float = 1000.0
        if let p = pseudo.priority { priority = (p as NSString).floatValue }
        constraint?.priority = priority
        constraint?.identifier = pseudo.identifier
      }
    }

    return constraint
  }

  public var manager: ConstraintManager { return firstItem.constraintManager }

  public var staticConstraint: Bool { return secondItem == nil }

  override public var description: String {
    var pseudo = pseudoConstraint
    pseudo.firstItem = firstItem.name.camelCase()
    pseudo.secondItem = secondItem?.name.camelCase()
    return pseudo.description
  }

  override public var debugDescription: String {
    return "\n".join(description,
      "firstItem: \(firstItem)",
      "secondItem: \(secondItem)",
      "firstAttribute: \(firstAttribute)",
      "secondAttribute: \(secondAttribute)",
      "multiplier: \(multiplier)",
      "constant: \(constant)",
      "identifier: \(identifier)",
      "priority: \(priority)",
      "owner: \(owner)")
  }

  /**
  hasAttributeValues:

  :param: values [String AnyObject]

  :returns: Bool
  */
  public func hasAttributeValues(values: [String:AnyObject]) -> Bool {
    if let item: AnyObject = values["firstItem"] {
      if item is RemoteElement && (item as! RemoteElement) != firstItem { return false }
      else if item is String && (item as! String) != firstItem.uuid { return false }
    }
    if let identifier = values["identifier"] as? String {
      if self.identifier == nil || self.identifier! != identifier { return false }
    }
    if let attribute = values["firstAttribute"] as? NSNumber {
      if attribute.integerValue != firstAttribute.rawValue { return false }
    }
    if let relatedBy = values["relation"] as? NSNumber {
      if relatedBy.integerValue != relation.rawValue { return false }
    }
    if let attribute = values["secondAttribute"] as? NSNumber {
      if attribute.integerValue != secondAttribute.rawValue { return false }
    }
    if let item: AnyObject = values["secondItem"] {
      if secondItem == nil { return false }
      else if item is RemoteElement && (item as! RemoteElement) != secondItem! { return false }
      else if item is String && (item as! String) != secondItem!.uuid { return false }
    }
    if let m = values["multiplier"] as? NSNumber {
      if m.doubleValue != Double(multiplier) { return false }
    }
    if let c = values["constant"] as? NSNumber {
      if c.doubleValue != Double(constant) { return false }
    }
    if let p = values["priority"] as? NSNumber {
      if p.floatValue != Float(priority) { return false }
    }
    if let o: AnyObject = values["owner"] {
      if owner == nil { return false }
      else if o is RemoteElement && (o as! RemoteElement) != owner! { return false }
      else if o is String && (o as! String) != owner!.uuid { return false }
    }
    return true
  }

  /**
  constraintFromFormat:index:

  :param: format String
  :param: index [String:String] Dictionary with entries in the format ["placeholder":"uuid"]

  :returns: Constraint?
  */
  public class func constraintFromFormat(format: String, index: [String:String], context: NSManagedObjectContext) -> Constraint? {
    var constraint: Constraint?
    if let pseudo = NSLayoutPseudoConstraint(format: format) {
      let firstItemIndex = pseudo.firstItem
      if let firstItemUUID = index[firstItemIndex],
        firstItem = RemoteElement.objectWithValue(firstItemUUID, forAttribute: "uuid", context: context)
      {
        var secondItem: RemoteElement?
        if let secondItemIndex = pseudo.secondItem, secondItemUUID = index[secondItemIndex] {
          secondItem = RemoteElement.objectWithValue(secondItemUUID, forAttribute: "uuid", context: context)
        }

        var directory: OrderedDictionary<String,RemoteElement> = [firstItem.identifier: firstItem]
        if secondItem != nil { directory.setValue(secondItem!, forKey: secondItem!.identifier) }
        var updatedPseudo = pseudo
        updatedPseudo.firstItem = firstItem.identifier
        updatedPseudo.secondItem = secondItem?.identifier
        constraint = Constraint.constraintFromPseudoConstraint(updatedPseudo, usingDirectory: directory)
      }
    }
    return constraint
  }

  /**
  importObjectsFromData:context:

  :param: data AnyObject?
  :param: context NSManagedObjectContext

  :returns: [Constraint]
  */
  override public class func importObjectsFromData(data: AnyObject, context: NSManagedObjectContext) -> [ModelObject] {
    var constraints: [Constraint] = []
    if let rootDictionary = data as? [String:AnyObject] {
      if let index = rootDictionary["index"] as? [String:String] {
        if let formatData: AnyObject = rootDictionary["format"] {
          if formatData is String || formatData is [String] {
            let formatStrings: [String] = formatData is String ? [(formatData as! String)] : (formatData as! [String])
            for format in formatStrings {
              if let constraint = constraintFromFormat(format, index: index, context: context) { constraints.append(constraint) }
            }
          }
        }
      }
    }
    return constraints
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    var dictionary = super.JSONDictionary()
    dictionary["tag"] = primitiveTag
    if identifier != nil { dictionary["identifier"] = identifier! }
    dictionary["first-attribute"] = NSLayoutConstraint.pseudoNameForAttribute(firstAttribute)
    dictionary["second-attribute"] = NSLayoutConstraint.pseudoNameForAttribute(secondAttribute)
    dictionary["relation"] = NSLayoutConstraint.pseudoNameForRelation(relation)
    dictionary["multiplier"] = primitiveMultiplier
    dictionary["constant"] = primitiveConstant
    dictionary["priority"] = primitivePriority
    dictionary["first-item.uuid"] = firstItem.uuid
    if secondItem != nil { dictionary["second-item.uuid"] = secondItem!.uuid }
    if owner != nil { dictionary["owner.uuid"] = owner!.uuid }
    return dictionary
  }

}
