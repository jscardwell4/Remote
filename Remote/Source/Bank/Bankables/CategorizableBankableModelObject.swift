//
//  CategorizableBankableModelObject.swift
//  Remote
//
//  Created by Jason Cardwell on 3/13/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import ObjectiveC
import MoonKit

@objc(CategorizableBankableModelObject)
class CategorizableBankableModelObject: BankableModelObject, CategorizableBankItemModel {
  required init(context: NSManagedObjectContext?) { super.init(context: context) }
  required init?(JSONValue: MSDictionary) { super.init(JSONValue: JSONValue) }
  required init?(data: [String : AnyObject], context: NSManagedObjectContext) { super.init(data: data, context: context) }

  class var categoryRelationshipName: String { return "category" }

  class var categoryClassName: String {
    let relationships = entityDescription.relationshipsByName as! [String:NSRelationshipDescription]
    if let categoryClassName = relationships[categoryRelationshipName]?.destinationEntity?.managedObjectClassName {
      return categoryClassName
    } else { preconditionFailure("subclass without proper 'category' relationship in model") }
  }

  class var categoryClass: BankableModelCategory.Type {
    let className = categoryClassName
    let categoryClass: AnyClass = NSClassFromString(className)

    var currentClass: AnyClass! = categoryClass
    while let superClass: AnyClass! = class_getSuperclass(currentClass) {
      if superClass.self === BankableModelCategory.self {
        return unsafeBitCast(categoryClass, BankableModelCategory.self.dynamicType)
      } else { currentClass = superClass }
    }

    preconditionFailure("subclass without proper 'category' relationship in model")
  }

  var category: BankableModelCategory! {
    get {
      willAccessValueForKey("category")
      willAccessValueForKey(self.dynamicType.categoryRelationshipName)
      let category = primitiveValueForKey(self.dynamicType.categoryRelationshipName) as? BankableModelCategory
      didAccessValueForKey("category")
      didAccessValueForKey(self.dynamicType.categoryRelationshipName)
      return category
    }
    set {
      if newValue.className == self.dynamicType.categoryClassName {
        willChangeValueForKey("category")
        willChangeValueForKey(self.dynamicType.categoryRelationshipName)
        setPrimitiveValue(newValue, forKey: self.dynamicType.categoryRelationshipName)
        didChangeValueForKey("category")
        didChangeValueForKey(self.dynamicType.categoryRelationshipName)
      }
    }
  }

  var itemPath: String { return "\(category.categoryPath)/\(name)" }

  /**
  fetchObjectWithData:context:

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  override class func fetchObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let object = super.fetchObjectWithData(data, context: context) where object.dynamicType === self {
      return unsafeBitCast(object, self)
    } else if let path = data["path"] as? String,
      object = categoryClass.itemForPath(path, context: context) where object.dynamicType === self {
        return unsafeBitCast(object, self)
    } else { return nil }
  }
  
  
}