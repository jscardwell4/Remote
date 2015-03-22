//
//  ImageCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ImageCategory)
class ImageCategory: IndexedBankCategoryObject, PreviewableCategory {

  @NSManaged var images: Set<Image>
  @NSManaged var childCategories: Set<ImageCategory>
  @NSManaged var parentCategory: ImageCategory?

  let previewableItems = true
  let editableItems = true

  var indexedItems: [IndexedBankCategoryItem] { return Array(images) }
  func setIndexedItems(items: [IndexedBankCategoryItem]) {
    if let images = items as? [Image] { self.images = Set(images) }
  }

  var indexedSubcategories: [IndexedBankCategory] { return Array(childCategories) }
  func setIndexedSubcategories(subcategories: [IndexedBankCategory]) {
    if let childCategories = subcategories as? [ImageCategory] { self.childCategories = Set(childCategories) }
  }

  var indexedCategory: IndexedBankCategory? { return parentCategory }
  func setIndexedCategory(category: IndexedBankCategory?) {
    if let parentCategory = category as? ImageCategory { self.parentCategory = parentCategory }
    else if category == nil { parentCategory = nil }
  }

  override var index: String { return indexedCategory == nil ? name : "\(indexedCategory!.index)/\(name)" }

  /**
  rootCategoryNamed:context:

  :param: name String
  :param: context NSManagedObjectContext

  :returns: IndexedBankCategory?
  */
  override class func rootCategoryNamed(name: String, context: NSManagedObjectContext) -> IndexedBankCategory? {
    return findFirstMatchingPredicate(∀"parentCategory = NULL AND name = '\(name)'", context: context)
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "parentCategory", lookupKey: "category")
    updateRelationshipFromData(data, forKey: "images")
    updateRelationshipFromData(data, forKey: "childCategories", lookupKey: "subcategories")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    safeSetValueForKeyPath("parentCategory.index", forKey: "category.index", inDictionary: dictionary)
    safeSetValueForKeyPath("images.JSONDictionary", forKey: "images", inDictionary: dictionary)
    safeSetValueForKeyPath("childCategories.JSONDictionary", forKey: "subcategories", inDictionary: dictionary)
    
    dictionary.compact()
    dictionary.compress()

    return dictionary
  }
  

}
