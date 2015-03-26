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
final public class ImageCategory: IndexedEditableModelObject, NestingModelCollection, ModelCollectionItem, RootedModel {

  @NSManaged public var images: Set<Image>
  @NSManaged public var childCategories: Set<ImageCategory>
  @NSManaged public var parentCategory: ImageCategory?

  public let previewableItems = true
  public let editableItems = true

  public typealias ItemType = Image
  public var items: [ItemType] { get { return Array(images) } set { images = Set(newValue) } }
  public func itemWithIndex(index: PathModelIndex) -> ItemType? { return findByIndex(images, index) }

  public typealias NestedType = ImageCategory
  public var subcategories: [NestedType] { get { return Array(childCategories) } set { childCategories = Set(newValue) } }
  public func subcategoryWithIndex(index: PathModelIndex) -> NestedType? { return findByIndex(childCategories, index) }

  public typealias CollectionType = NestedType
  public var collection: CollectionType? { get { return parentCategory } set { parentCategory = newValue } }

  override public var pathIndex: PathModelIndex { return parentCategory != nil ? parentCategory!.pathIndex + "\(name)" : "\(name)" }

  /**
  itemWithIndex:context:

  :param: index String
  :param: context NSManagedObjectContext

  :returns: T?
  */
  public class func itemWithIndex<T:PathIndexedModel>(index: PathModelIndex, context: NSManagedObjectContext) -> T? {
    if index.isEmpty { return nil }
    var i = 1
    if let rootCategory = rootItemWithIndex(index[0..<i], context: context) {
      return itemWithIndexFromRoot(index, rootCategory)
    } else { return nil }
  }

  /**
  modelWithIndex:context:

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: ImageCategory?
  */
  override public class func modelWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> ImageCategory? {
    return itemWithIndex(index, context: context)
  }

  /**
  rootItemWithIndex:context:

  :param: index PathModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func rootItemWithIndex(index: PathModelIndex, context: NSManagedObjectContext) -> Self? {
    if let name = index.first {
      return objectMatchingPredicate(∀"parentCategory = NULL AND name = '\(name)'", context: context)
    } else { return nil }
  }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override public func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data)
    updateRelationshipFromData(data, forKey: "parentCategory", lookupKey: "category")
    updateRelationshipFromData(data, forKey: "images")
    updateRelationshipFromData(data, forKey: "childCategories", lookupKey: "subcategories")
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValueForKeyPath("parentCategory.index", forKey: "category.index", toDictionary: dictionary)
    appendValueForKeyPath("images.JSONDictionary", forKey: "images", toDictionary: dictionary)
    appendValueForKeyPath("childCategories.JSONDictionary", forKey: "subcategories", toDictionary: dictionary)
    
    dictionary.compact()
    dictionary.compress()

    return dictionary
  }
  

}
