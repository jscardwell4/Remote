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
final class ImageCategory: IndexedEditableModelObject, NestingModelCategory, ModelCategoryItem, RootedEditableModel {

  @NSManaged var images: Set<Image>
  @NSManaged var childCategories: Set<ImageCategory>
  @NSManaged var parentCategory: ImageCategory?

  let previewableItems = true
  let editableItems = true

  typealias ItemType = Image
  var items: [ItemType] { get { return Array(images) } set { images = Set(newValue) } }
  func itemWithIndex(index: ModelIndex) -> ItemType? { return findByIndex(images, index) }

  typealias NestedType = ImageCategory
  var subcategories: [NestedType] { get { return Array(childCategories) } set { childCategories = Set(newValue) } }
  func subcategoryWithIndex(index: ModelIndex) -> NestedType? { return findByIndex(childCategories, index) }

  typealias CategoryType = NestedType
  var category: CategoryType? { get { return parentCategory } set { parentCategory = newValue } }

  override var index: ModelIndex { return parentCategory != nil ? parentCategory!.index + "\(name)" : "\(name)" }

  /**
  itemWithIndex:context:

  :param: index String
  :param: context NSManagedObjectContext

  :returns: T?
  */
  class func itemWithIndex<T:IndexedEditableModel>(index: ModelIndex, context: NSManagedObjectContext) -> T? {
    if index.isEmpty { return nil }
    var i = 1
    if let rootCategory = rootItemWithIndex(index[0..<i], context: context) {
      return itemWithIndexFromRoot(index, rootCategory)
    } else { return nil }
  }

  /**
  modelWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: ImageCategory?
  */
  override class func modelWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> ImageCategory? {
    return itemWithIndex(index, context: context)
  }

  /**
  rootItemWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  class func rootItemWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Self? {
    if let name = index.first {
      return objectMatchingPredicate(∀"parentCategory = NULL AND name = '\(name)'", context: context)
    } else { return nil }
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

    appendValueForKeyPath("parentCategory.index", forKey: "category.index", toDictionary: dictionary)
    appendValueForKeyPath("images.JSONDictionary", forKey: "images", toDictionary: dictionary)
    appendValueForKeyPath("childCategories.JSONDictionary", forKey: "subcategories", toDictionary: dictionary)
    
    dictionary.compact()
    dictionary.compress()

    return dictionary
  }
  

}
