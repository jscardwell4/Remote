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
class BankCategoryObject: BankModelObject, BankCategory {

}

@objc(IndexedBankCategoryObject)
class IndexedBankCategoryObject: BankModelObject, IndexedBankCategory {

  override class func requiresUniqueNaming() -> Bool { return true }

  var index: String { return name }


  /**
  rootCategoryForPath:

  :param: path String

  :returns: Self?
  */
  class func rootCategoryNamed(name: String, context: NSManagedObjectContext) -> IndexedBankCategory? {
    fatalError("rootCategoryNamed:context: must be overidden by subclass to return appropriate value")
  }

  /**
  subscript:

  :param: name String

  :returns: BankCategory?
  */
  subscript(name: String) -> IndexedBankCategoryObject? {
    if let subcategories = valueForKey("subcategories") as? [IndexedBankCategoryObject] {
      return findFirst(subcategories, {$0.name == name})
    } else { return nil }
  }

  /**
  categoryForCategoryPath:

  :param: path String

  :returns: Self?
  */
  class func categoryForIndex(index: String, context: NSManagedObjectContext) -> Self? {
    MSLogDebug("retrieving category for category path '\(index)'")
    var components = index.pathStack
    if let rootName = components.pop(), rootCategory = rootCategoryNamed(rootName, context: context) {
      MSLogDebug("found root category named '\(rootCategory.name)' of type '\((rootCategory as! NSObject).className)'")
      var category = rootCategory
      while let name = components.pop(),
        subcategories = category.indexedSubcategories,
        subcategory = findFirst(subcategories, {$0.name == name})
      {
        MSLogDebug("found subcategory named '\(subcategory.name)' of type '\((subcategory as! NSObject).className)'")
        category = subcategory
      }
      if components.isEmpty, let result = typeCast(category, self) {
        MSLogDebug("found target category named '\(result.name)' of type '\(result.className)'")
        return result
      } else {
        MSLogDebug("failed to find category matching path '\(index)'")
        return nil
      }
    } else {
      MSLogDebug("failed to find root category for path '\(index)'")
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
    if let path = data["path"] as? String { return categoryForIndex(path, context: context) }
    else if let object = super.fetchObjectWithData(data, context: context) where object.dynamicType === self {
      return unsafeBitCast(object, self)
    } else { return nil }
  }

  /**
  itemForIndex:context:

  :param: index String
  :param: context NSManagedObjectContext

  :returns: BankCategoryItem?
  */
  class func itemForIndex(index: String, context: NSManagedObjectContext) -> IndexedBankCategoryItem? {
    MSLogDebug("retrieving item for path '\(index)'")
    var components = index.pathStack.reversed()
    if let itemName = components.pop(), category = categoryForIndex("/".join(components), context: context) {
      MSLogDebug("found category named '\(category.name)' of type '\(category.className)'")
      if let items = (category as IndexedBankCategory).indexedItems, item = findFirst(items, {$0.name == itemName}) {
        MSLogDebug("found target item named '\(item.name)' of type '\((item as! NSObject).className)'")
        return item
      } else {
        MSLogDebug("failed to locate item within category for path '\(index)'")
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
//  override func JSONDictionary() -> MSDictionary {
//    let dictionary = super.JSONDictionary()
//
//    if respondsToSelector("category"), let parentCategory = valueForKey("category") as? BankCategoryObject {
//      dictionary[self.dynamicType.parentCategoryKey!.dashcaseString] = parentCategory.index
//    }
//
//    if let items = self.items as? [BankCategoryItemObject] where items.count > 0 {
//      dictionary[self.dynamicType.itemsKey!.dashcaseString] = items.map{$0.JSONDictionary()}
//    }
//
//    if let subcategories = self.subcategories as? [BankCategoryObject] where items.count > 0 {
//      dictionary[self.dynamicType.subcategoriesKey!.dashcaseString] = subcategories.map{$0.JSONDictionary()}
//    }
//
//    return dictionary
//  }

}
