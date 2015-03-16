//
//  BankCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 3/15/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

func typeCast<T,U>(subject: T, target: U.Type) -> U? {
  return subject is U ? unsafeBitCast(subject, target) : nil
}

@objc(BankCategory)
class BankCategory: NamedModelObject, BankItemCategory {

  required init(context: NSManagedObjectContext?) { super.init(context: context) }
  required init?(JSONValue: MSDictionary) { super.init(JSONValue: JSONValue) }
  required init?(data: [String : AnyObject], context: NSManagedObjectContext) { super.init(data: data, context: context) }

  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
  override class func requiresUniqueNaming() -> Bool { return true }
  var parentCategory: BankItemCategory? {
    get {
      willAccessValueForKey("parentCategory")
      let parentCategory = primitiveValueForKey("parentCategory") as? BankCategory
      didAccessValueForKey("parentCategory")
      return parentCategory as? BankItemCategory
    }
    set {
      if let parentCategory = newValue as? BankCategory {
        willChangeValueForKey("parentCategory")
        setPrimitiveValue(parentCategory, forKey: "parentCategory")
        didChangeValueForKey("parentCategory")
      }
    }
  }

  var previewableItems: Bool { return false }
  var editableItems: Bool { return false }
  var editable: Bool { return false }

  var categoryPath: String {
    if let parentPath = parentCategory?.categoryPath { return "\(parentPath)/\(title)" }
    else { return title }
  }

  var subcategories: [BankItemCategory] {
    get {
      willAccessValueForKey("subcategories")
      let subcategories = primitiveValueForKey("subcategories") as? Set<BankCategory>
      didAccessValueForKey("subcategories")
      return Array(subcategories ?? Set<BankCategory>())
    } set {
      if let subcategories = newValue as? [BankCategory] {
        willChangeValueForKey("subcategories")
        setPrimitiveValue(Set(subcategories), forKey: "subcategories")
        didChangeValueForKey("subcategories")
      }
    }
  }


  var items: [BankItemModel] {
    get {
      willAccessValueForKey("items")
      let items = primitiveValueForKey("items") as? Set<BankCategoryItem>
      didAccessValueForKey("items")
      return Array(items ?? Set<BankCategoryItem>())
    } set {
      if let items = newValue as? [BankCategoryItem] {
        willChangeValueForKey("items")
        setPrimitiveValue(Set(items), forKey: "items")
        didChangeValueForKey("items")
      }
    }
  }

  var title: String { return name! }

  /**
  rootCategoryForPath:

  :param: path String

  :returns: Self?
  */
  class func rootCategoryNamed(name: String, context: NSManagedObjectContext) -> BankCategory? {
    return BankCategory.findFirstMatchingPredicate(∀"parentCategory == nil AND name == \"\(name)\"", context: context)
  }

  /**
  subscript:

  :param: name String

  :returns: BankCategory?
  */
  subscript(name: String) -> BankCategory? { return findFirst(subcategories, {$0.title == name}) as? BankCategory }

  /**
  categoryForCategoryPath:

  :param: path String

  :returns: Self?
  */
  class func categoryForCategoryPath(var path: String, context: NSManagedObjectContext) -> Self? {
    MSLogDebug("retrieving category for category path '\(path)'")
    var components = path.pathStack
    if let rootName = components.pop(), rootCategory = rootCategoryNamed(rootName, context: context) {
      MSLogDebug("found root category named '\(rootCategory.title)' of type '\(rootCategory.className)'")
      var category = rootCategory
      while let title = components.pop(), subcategory = category[title] {
        MSLogDebug("found subcategory named '\(subcategory.title)' of type '\(subcategory.className)'")
        category = subcategory
      }
      if components.isEmpty, let result = typeCast(category, self) {
        MSLogDebug("found target category named '\(result.title)' of type '\(result.className)'")
        return result
      } else {
        MSLogDebug("failed to find category matching path '\(path)'")
        return nil
      }
    } else {
      MSLogDebug("failed to find root category for path '\(path)'")
      return nil
    }
  }

  /**
  fetchObjectWithData:context:

  :param: data [String AnyObject]
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  override class func fetchObjectWithData(data: [String:AnyObject], context: NSManagedObjectContext) -> Self? {
    if let path = data["path"] as? String { return categoryForCategoryPath(path, context: context) }
    else if let object = super.fetchObjectWithData(data, context: context) where object.dynamicType === self {
      return unsafeBitCast(object, self)
    } else { return nil }
  }

  /**
  itemForPath:context:

  :param: path String
  :param: context NSManagedObjectContext

  :returns: BankCategoryItem?
  */
  class func itemForPath(path: String, context: NSManagedObjectContext) -> BankCategoryItem? {
    MSLogDebug("retrieving item for path '\(path)'")
    var components = path.pathStack.reversed()
    if let itemName = components.pop(), category = categoryForCategoryPath("/".join(components), context: context) {
      MSLogDebug("found category named '\(category.title)' of type '\(category.className)'")
      if let item = findFirst(category.items, {$0.name == itemName}) as? BankCategoryItem {
        MSLogDebug("found target item named '\(item.name!)' of type '\(item.className)'")
        return item
      } else {
        MSLogDebug("failed to locate item within category for path '\(path)'")
      }
    }
    return nil
  }

}
