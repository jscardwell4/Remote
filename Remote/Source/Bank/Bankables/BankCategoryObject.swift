//
//  BankCategoryObject.swift
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

@objc(BankCategoryObject)
class BankCategoryObject: NamedModelObject, BankCategory {

  required init(context: NSManagedObjectContext?) { super.init(context: context) }
  required init?(data: [String : AnyObject], context: NSManagedObjectContext) { super.init(data: data, context: context) }

  override class func requiresUniqueNaming() -> Bool { return true }

  class var parentCategoryKey: String? { return nil }
  class var subcategoriesKey: String? { return nil }
  class var itemsKey: String? { return nil }

  @NSManaged var user: Bool

  var category: BankCategory? {
    get {
      if let key = self.dynamicType.parentCategoryKey {
        return valueForKey(key) as? BankCategory
      } else { return nil }
    }
    set {}
  }

  var path: String {
    if let parentPath = category?.path { return "\(parentPath)/\(name)" }
    else { return name }
  }

  var subcategories: [BankCategory] {
    get {
      if let key = self.dynamicType.subcategoriesKey, subcategories = valueForKey(key) as? Set<BankCategoryObject> {
        return Array(subcategories)
      } else { return [] }
    }
    set {}
  }

  var items: [BankCategoryItem] {
    get {
      if let key = self.dynamicType.itemsKey {
        return Array(valueForKey(key) as? Set<BankCategoryItemObject> ?? Set<BankCategoryItemObject>())
      } else { return [] }
    }
    set {

    }
  }

  /**
  rootCategoryForPath:

  :param: path String

  :returns: Self?
  */
  class func rootCategoryNamed(name: String, context: NSManagedObjectContext) -> BankCategoryObject? {
    return findFirstMatchingPredicate(∀"parentCategory == nil AND name == \"\(name)\"", context: context)
  }

  /**
  subscript:

  :param: name String

  :returns: BankCategory?
  */
  subscript(name: String) -> BankCategoryObject? {
    if let subcategories = self.subcategories as? [BankCategoryObject] {
      return findFirst(subcategories, {$0.name == name})
    } else { return nil }
  }

  /**
  categoryForCategoryPath:

  :param: path String

  :returns: Self?
  */
  class func categoryForCategoryPath(var path: String, context: NSManagedObjectContext) -> Self? {
    MSLogDebug("retrieving category for category path '\(path)'")
    var components = path.pathStack
    if let rootName = components.pop(), rootCategory = rootCategoryNamed(rootName, context: context) {
      MSLogDebug("found root category named '\(rootCategory.name)' of type '\(rootCategory.className)'")
      var category = rootCategory
      while let title = components.pop(), subcategory = category[title] {
        MSLogDebug("found subcategory named '\(subcategory.name)' of type '\(subcategory.className)'")
        category = subcategory
      }
      if components.isEmpty, let result = typeCast(category, self) {
        MSLogDebug("found target category named '\(result.name)' of type '\(result.className)'")
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
      MSLogDebug("found category named '\(category.name)' of type '\(category.className)'")
      if let item = findFirst(category.items as! [BankCategoryItemObject], {$0.name == itemName}) {
        MSLogDebug("found target item named '\(item.name)' of type '\(item.className)'")
        return item
      } else {
        MSLogDebug("failed to locate item within category for path '\(path)'")
      }
    }
    return nil
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
//  override func updateWithData(data: [String:AnyObject]) {
//    super.updateWithData(data) // sets uuid, name
//
//    if let key = self.dynamicType.parentCategoryKey { updateRelationshipFromData(data, forKey: key) }
//    if let key = self.dynamicType.itemsKey { updateRelationshipFromData(data, forKey: key) }
//    if let key = self.dynamicType.subcategoriesKey { updateRelationshipFromData(data, forKey: key) }
//  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    if let parentCategory = self.category as? BankCategoryObject {
      dictionary[self.dynamicType.parentCategoryKey!.dashcaseString] = parentCategory.path
    }

    if let items = self.items as? [BankCategoryItemObject] where items.count > 0 {
      dictionary[self.dynamicType.itemsKey!.dashcaseString] = items.map{$0.JSONDictionary()}
    }

    if let subcategories = self.subcategories as? [BankCategoryObject] where items.count > 0 {
      dictionary[self.dynamicType.subcategoriesKey!.dashcaseString] = subcategories.map{$0.JSONDictionary()}
    }

    return dictionary
  }

}
