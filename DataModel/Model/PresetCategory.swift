//
//  PresetCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(PresetCategory)
final public class PresetCategory: IndexedEditableModelObject, NestingModelCollection, ModelCollectionItem, RootedModel {

  @NSManaged public var presets: Set<Preset>
  @NSManaged public var childCategories: Set<PresetCategory>
  @NSManaged public var parentCategory: PresetCategory?

  public typealias ItemType = Preset
  public var items: [ItemType] { get { return Array(presets) } set { presets = Set(newValue) } }
  public func itemWithIndex(index: PathModelIndex) -> ItemType? { return findByIndex(presets, index) }

  public typealias CollectionType = PresetCategory
  public var collection: CollectionType? { get { return parentCategory } set { parentCategory = newValue } }

  public typealias NestedType = PresetCategory
  public var subcategories: [NestedType] { get { return Array(childCategories) } set { childCategories = Set(newValue) } }
  public func subcategoryWithIndex(index: PathModelIndex) -> NestedType? { return findByIndex(childCategories, index) }

  override public var pathIndex: PathModelIndex { return parentCategory != nil ? parentCategory!.pathIndex + "\(name)" : "\(name)" }

  /**
  itemWithIndex:context:

  :param: index PathModelIndex
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

    //TODO: Fill in stub
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override public func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    //TODO: Fill in stub

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }



}
