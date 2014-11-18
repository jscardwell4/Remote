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
class Constraint: ModelObject {

  @NSManaged var primitiveTag: NSNumber
  var tag: Int {
    get {
      willAccessValueForKey("tag")
      let tag = primitiveTag.integerValue
      didAccessValueForKey("tag")
      return tag
    }
    set {
      willChangeValueForKey("tag")
      primitiveTag = newValue
      didChangeValueForKey("tag")
    }
  }

  @NSManaged var key: String?

  @NSManaged var primitiveFirstAttribute: NSNumber
  var firstAttribute: NSLayoutAttribute {
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
  var secondAttribute: NSLayoutAttribute {
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
  var relation: NSLayoutRelation {
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
  var multiplier: CGFloat {
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
  var constant: CGFloat {
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

  @NSManaged var firstItem: RemoteElement!
  @NSManaged var secondItem: RemoteElement?
  @NSManaged var owner: RemoteElement?

  @NSManaged var primitivePriority: NSNumber!
  var priority: UILayoutPriority {
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
  convenience init(item firstItem: RemoteElement,
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
  class func constraintWithValues(values: [String:AnyObject]) -> Constraint? {
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

  var manager: ConstraintManager { return firstItem.constraintManager }

  var staticConstraint: Bool { return secondItem == nil }

  /**
  hasAttributeValues:

  :param: values [String AnyObject]

  :returns: Bool
  */
  func hasAttributeValues(values: [String:AnyObject]) -> Bool {
    if let item: AnyObject = values["firstItem"] {
      if item is RemoteElement && (item as RemoteElement) != firstItem { return false }
      else if item is String && (item as String) != firstItem.uuid { return false }
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
      else if item is RemoteElement && (item as RemoteElement) != secondItem! { return false }
      else if item is String && (item as String) != secondItem!.uuid { return false }
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
      else if o is RemoteElement && (o as RemoteElement) != owner! { return false }
      else if o is String && (o as String) != owner!.uuid { return false }
    }
    return true
  }

  /**
  constraintFromFormat:index:

  :param: format String
  :param: index [String String]

  :returns: Constraint?
  */
  class func constraintFromFormat(format: String, index: [String:String], context: NSManagedObjectContext) -> Constraint? {
    var constraint: Constraint?

    let regex: String = {
      let name = "[a-zA-Z_][-_a-zA-Z0-9]*"
      let attribute = "[a-z]+[A-Z]?"
      let priority = "[0-9]{1,4}"
      let metric = "(?:\(name))|(?:[-0-9]+\\.?[0-9]*)"
      return ("(?:'([^']+)'[ ]+)?" +                   // identifier
              "(\(name))\\.(\(attribute))" +           // first item and attribute
              "[ ]+([=≤≥]+)" +                         // relation
              "(?:[ ]+(\(name))\\.(\(attribute)))?" +  // second item and attribute
              "(?:[ ]+[x*][ ]+(\(metric)))?" +         // multiplier if present
              "(?:[ ]+([+-])?[ ]*(\(metric)))?" +      // constant if present
              "(?:[ ]+@(\(priority)))?")               // priority if present
    }()
    let keys = ["identifier",
                "firstItem",
                "firstAttribute",
                "relation",
                "secondItem",
                "secondAttribute",
                "multiplier",
                "constantOperator",
                "constant",
                "priority"]
    let result = format.dictionaryOfCapturedStringsByMatchingFirstOccurrenceOfRegex(regex, keys: keys)
    var captures: [String:NSString] = [:]
    for (key, value) in result {
      if let k = key as? String {
        if let v = value as? NSString {
          captures[k] = v
        }
      }
    }

    let multiplier = CGFloat(captures["multiplier"]?.doubleValue ?? 1.0)
    var constant = CGFloat(captures["constant"]?.doubleValue ?? 0.0)
    if let op = captures["constantOperator"] { if op == "-" { constant = -constant } }
    let priority = UILayoutPriority(captures["priority"]?.floatValue ?? 1000.0)
    let firstAttribute = NSLayoutAttribute(pseudoname: captures["firstAttribute"])
    let secondAttribute = NSLayoutAttribute(pseudoname: captures["secondAttribute"])
    let relation = NSLayoutRelation(pseudoname: captures["relation"])

    if let firstItemIndex = captures["firstItem"] {
      if let firstItemUUID = index[firstItemIndex] {
        if let firstItem = RemoteElement.findFirstByAttribute("uuid", withValue: firstItemUUID, context: context) {
          var secondItem: RemoteElement?
          if let secondItemIndex = captures["secondItem"] {
            if let secondItemUUID = index[secondItemIndex] {
              secondItem = RemoteElement.findFirstByAttribute("uuid", withValue: secondItemUUID, context: context)
            }
          }
          constraint = Constraint(item: firstItem,
                                  attribute: firstAttribute,
                                  relatedBy: relation,
                                  toItem: secondItem,
                                  attribute: secondAttribute,
                                  multiplier: multiplier,
                                  constant: constant)
          constraint?.priority = priority
        }
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
  override class func importObjectsFromData(data: AnyObject!, context: NSManagedObjectContext) -> [AnyObject]! {
    var constraints: [Constraint] = []
    if let rootDictionary = data as? [String:AnyObject] {
      if let index = rootDictionary["index"] as? [String:String] {
        if let formatData: AnyObject = rootDictionary["format"] {
          if formatData is String || formatData is [String] {
            let formatStrings: [String] = formatData is String ? [(formatData as String)] : (formatData as [String])
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
  override func JSONDictionary() -> MSDictionary {
    var dictionary = super.JSONDictionary()
    dictionary["tag"] = primitiveTag
    if key != nil { dictionary["key"] = key }
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
