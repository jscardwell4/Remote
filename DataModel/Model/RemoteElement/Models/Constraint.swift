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

  @NSManaged public var identifier: String?
  @NSManaged public var tag: Int
  @NSManaged public var multiplier: Float
  @NSManaged public var constant: Float
  @NSManaged public var firstItem: RemoteElement?
  @NSManaged public var secondItem: RemoteElement?
  @NSManaged public var firstItemIdentifier: String?
  @NSManaged public var secondItemIdentifier: String?
  @NSManaged public var owner: RemoteElement?
  @NSManaged public var priority: UILayoutPriority


  public var valid: Bool { return firstItem != nil || firstItemIdentifier != nil }

  public var firstAttribute: NSLayoutAttribute {
    get {
      willAccessValueForKey("firstAttribute")
      let attribute = primitiveValueForKey("firstAttribute") as! Int
      didAccessValueForKey("firstAttribute")
      return NSLayoutAttribute(rawValue: attribute)!
    }
    set {
      willChangeValueForKey("firstAttribute")
      setPrimitiveValue(newValue.rawValue, forKey: "firstAttribute")
      didChangeValueForKey("firstAttribute")
    }
  }

  public var secondAttribute: NSLayoutAttribute {
    get {
      willAccessValueForKey("secondAttribute")
      let attribute = primitiveValueForKey("secondAttribute") as! Int
      didAccessValueForKey("secondAttribute")
      return NSLayoutAttribute(rawValue: attribute)!
    }
    set {
      willChangeValueForKey("secondAttribute")
      setPrimitiveValue(newValue.rawValue, forKey: "secondAttribute")
      didChangeValueForKey("secondAttribute")
    }
  }

  public var relation: NSLayoutRelation {
    get {
      willAccessValueForKey("relation")
      let relation = primitiveValueForKey("relation") as! Int
      didAccessValueForKey("relation")
      return NSLayoutRelation(rawValue: relation)!
    }
    set {
      willChangeValueForKey("relation")
      setPrimitiveValue(newValue.rawValue, forKey: "relation")
      didChangeValueForKey("relation")
    }
  }

  public var pseudoConstraint: PseudoConstraint {
    return PseudoConstraint(item: firstItem?.identifier ?? firstItemIdentifier ?? "firstElement",
      attribute: PseudoConstraint.Attribute(firstAttribute),
      relatedBy: PseudoConstraint.Relation(relation),
      toItem: secondItem?.identifier ?? secondItemIdentifier,
      attribute: PseudoConstraint.Attribute(secondAttribute),
      multiplier: multiplier,
      constant: constant,
      priority: priority,
      identifier: identifier)
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
                         relatedBy relation: NSLayoutRelation = NSLayoutRelation.Equal,
                         toItem seconditem: RemoteElement? = nil,
                         attribute secondAttribute: NSLayoutAttribute = NSLayoutAttribute.NotAnAttribute,
                         multiplier: Float = 1.0,
                         constant: Float = 0.0)
  {
    self.init(context: firstItem.managedObjectContext)
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
    let firstAttribute = values["firstAttribute"] as? Int
    let relation = values["relation"] as? Int
    let secondItem = values["secondItem"] as? RemoteElement
    let secondAttribute = values["secondAttribute"] as? Int
    let multiplier = values["multiplier"] as? Float
    let constant = values["constant"] as? Float
    if firstItem == nil || firstAttribute == nil || relation == nil || secondAttribute == nil { return nil }
    else { return Constraint(item: firstItem!,
                             attribute: NSLayoutAttribute(rawValue: firstAttribute!)!,
                             relatedBy: NSLayoutRelation(rawValue: relation!)!,
                             toItem: secondItem,
                             attribute: NSLayoutAttribute(rawValue: secondAttribute!)!,
                             multiplier: multiplier ?? 1.0,
                             constant: constant ?? 0.0) }
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

  :param: pseudo PseudoConstraint

  :returns: Constraint?
  */
  public class func constraintFromPseudoConstraint(pseudo: PseudoConstraint,
                              usingDirectory directory: OrderedDictionary<String, RemoteElement>) -> Constraint?
  {
    var constraint: Constraint?
    if pseudo.validPseudo, let firstElement = elementFromDirectory(directory, forString: pseudo.firstItem!) {
      var secondElement: RemoteElement?
      if pseudo.secondItem != nil { secondElement = elementFromDirectory(directory, forString: pseudo.secondItem!) }
      if pseudo.secondAttribute == .NotAnAttribute || secondElement != nil {
        constraint = Constraint(item: firstElement,
                                attribute: pseudo.firstAttribute.NSLayoutAttributeValue,
                                relatedBy: pseudo.relation.NSLayoutRelationValue,
                                toItem: secondElement,
                                attribute: pseudo.secondAttribute.NSLayoutAttributeValue,
                                multiplier: pseudo.multiplier,
                                constant: pseudo.constant)
        constraint?.priority = pseudo.priority
        constraint?.identifier = pseudo.identifier
      }
    }

    return constraint
  }

  public var manager: ConstraintManager? { return firstItem?.constraintManager }

  public var staticConstraint: Bool { return secondItem == nil }

  override public var description: String {
    var pseudo = pseudoConstraint
    pseudo.firstItem = firstItem?.name.camelcaseString ?? firstItemIdentifier ?? "firstElement"
    pseudo.secondItem = secondItem?.name.camelcaseString ?? secondItemIdentifier ?? "secondElement"
    return pseudo.description
  }

  override public var debugDescription: String {
    return "\(super.description)\n\t" + "\n\t".join(
      description,
      "first item = \(toString(firstItem?.index))",
      "second item = \(toString(secondItem?.index))",
      "first item identifier = \(toString(firstItemIdentifier))",
      "second item identifier = \(toString(secondItemIdentifier))",
      "first attribute = \(PseudoConstraint.Attribute(firstAttribute).rawValue)",
      "second attribute = \(PseudoConstraint.Attribute(secondAttribute).rawValue)",
      "relation = \(PseudoConstraint.Relation(relation).rawValue)",
      "multiplier = \(multiplier)",
      "constant = \(constant)",
      "identifier = \(identifier)",
      "priority = \(priority)",
      "owner = \(toString(owner?.index))"
    )
  }

  /**
  hasAttributeValues:

  :param: values [String AnyObject]

  :returns: Bool
  */
  public func hasAttributeValues(values: [String:AnyObject]) -> Bool {
    if let item: AnyObject = values["firstItem"] {
      if item is RemoteElement && (item as! RemoteElement) != firstItem { return false }
      else if item is String && (item as! String) != firstItem?.uuid { return false }
    }
    if let identifier = values["identifier"] as? String {
      if self.identifier == nil || self.identifier! != identifier { return false }
    }
    if let attribute = values["firstAttribute"] as? Int {
      if attribute != firstAttribute.rawValue { return false }
    }
    if let relatedBy = values["relation"] as? Int {
      if relatedBy != relation.rawValue { return false }
    }
    if let attribute = values["secondAttribute"] as? Int {
      if attribute != secondAttribute.rawValue { return false }
    }
    if let item: AnyObject = values["secondItem"] {
      if secondItem == nil { return false }
      else if item is RemoteElement && (item as! RemoteElement) != secondItem! { return false }
      else if item is String && (item as! String) != secondItem!.uuid { return false }
    }
    if let m = values["multiplier"] as? Float {
      if m != multiplier { return false }
    }
    if let c = values["constant"] as? Float {
      if c != constant { return false }
    }
    if let p = values["priority"] as? UILayoutPriority {
      if p != priority { return false }
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
  public class func constraintFromFormat(format: String, withIndex index: [String:String], context: NSManagedObjectContext) -> Constraint? {
    var constraint: Constraint?
    if let pseudo = PseudoConstraint(format),
      firstItemIndex = pseudo.firstItem,
      firstItemUUID = index[firstItemIndex],
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
    return constraint
  }

  /**
  constraintFromFormat:context:

  :param: format String
  :param: context NSManagedObjectContext

  :returns: Constraint?
  */
  public class func constraintFromFormat(format: String, context: NSManagedObjectContext) -> Constraint? {
    var constraint: Constraint?
    if let pseudo = PseudoConstraint(format) {
      constraint = Constraint(context: context)
      constraint?.firstItemIdentifier = pseudo.firstItem
      constraint?.firstAttribute = pseudo.firstAttribute.NSLayoutAttributeValue
      constraint?.relation = pseudo.relation.NSLayoutRelationValue
      constraint?.secondItemIdentifier = pseudo.secondItem
      constraint?.secondAttribute = pseudo.secondAttribute.NSLayoutAttributeValue
      constraint?.multiplier = pseudo.multiplier
      constraint?.constant = pseudo.constant
      constraint?.priority = pseudo.priority
      constraint?.identifier = pseudo.identifier
    }
    return constraint
  }


  /**
  importObjectsWithData:context:

  :param: data AnyObject?
  :param: context NSManagedObjectContext

  :returns: [Constraint]
  */
  public class func importObjectsWithData(data: ObjectJSONValue, context: NSManagedObjectContext) -> [ModelObject] {
    // TODO: Pre-parse constraint format for $[0-9] and self
    if let index = ObjectJSONValue(data["index"]) {
      let convertedIndex = index.value.compressedMap({String($2)}).dictionary
      let formatStrings: [String]
      if let formatData = ArrayJSONValue(data["format"]) { formatStrings = compressedMap(formatData.value, {String($0)}) }
      else if let formatString = String(data["format"]) { formatStrings = [formatString] }
      else { formatStrings = [] }
      return compressedMap(formatStrings, {self.constraintFromFormat($0, withIndex: convertedIndex, context: context)})
    }
    return []
  }

  /**
  importObjectsWithData:context:

  :param: data ArrayJSONValue
  :param: context NSManagedObjectContext

  :returns: [Constraint]
  */
  override public class func importObjectsWithData(data: ArrayJSONValue, context: NSManagedObjectContext) -> [ModelObject] {
    return compressedMap(flatMap(data.compressedMap({String($0)}), {NSLayoutConstraint.splitFormat($0)}),
                         {self.constraintFromFormat($0, context: context)})
  }

  override public var jsonValue: JSONValue {
    var obj = ObjectJSONValue(super.jsonValue)!
    obj["tag"] = tag.jsonValue
    obj["identifier"] = identifier?.jsonValue
    obj["firstAttribute"] = PseudoConstraint.Attribute(firstAttribute).rawValue.jsonValue
    obj["secondAttribute"] = PseudoConstraint.Attribute(secondAttribute).rawValue.jsonValue
    obj["relation"] = PseudoConstraint.Relation(relation).rawValue.jsonValue
    obj["multiplier"] = multiplier.jsonValue
    obj["constant"] = constant.jsonValue
    obj["priority"] = priority.jsonValue
    obj["first-item.uuid"] = firstItem?.uuid.jsonValue
    obj["second-item.uuid"] = secondItem?.uuid.jsonValue
    obj["owner.uuid"] = owner?.uuid.jsonValue
    return obj.jsonValue
  }

}
