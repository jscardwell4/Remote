//
//  BankCategoryItem.swift
//  Remote
//
//  Created by Jason Cardwell on 3/15/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(BankCategoryItem)
class BankCategoryItem: BankableModelObject, CategorizableBankItemModel {

  required init(context: NSManagedObjectContext?) { super.init(context: context) }
  required init?(JSONValue: MSDictionary) { super.init(JSONValue: JSONValue) }
  required init?(data: [String : AnyObject], context: NSManagedObjectContext) { super.init(data: data, context: context) }

  var category: BankItemCategory {
    get {
      willAccessValueForKey("category")
      let category = primitiveValueForKey("category") as? BankCategory
      didAccessValueForKey("category")
      return category!
    }
    set {
      if let category = newValue as? BankCategory {
        willChangeValueForKey("category")
        setPrimitiveValue(category, forKey: "category")
        didChangeValueForKey("category")
      }
    }
  }

  var itemPath: String { return "\(category.categoryPath)/\(name!)" }

  class var categoryClassName: String {
    let relationships = entityDescription.relationshipsByName as! [String:NSRelationshipDescription]
    if let categoryClassName = relationships["category"]?.destinationEntity?.managedObjectClassName {
      return categoryClassName
    } else { preconditionFailure("subclass without proper 'category' relationship in model") }
  }

  class var categoryClass: BankCategory.Type {
//    let className = categoryClassName
//    let categoryClass: AnyClass = NSClassFromString(className)
//
//    var currentClass: AnyClass! = categoryClass
//    while let superClass: AnyClass! = class_getSuperclass(currentClass) {
//      if superClass.self === BankCategory.self {
//        return unsafeBitCast(categoryClass, BankCategory.self.dynamicType)
//      } else { currentClass = superClass }
//    }

    preconditionFailure("subclass without proper 'category' relationship in model")
  }

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
