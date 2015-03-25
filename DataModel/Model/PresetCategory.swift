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
final public class PresetCategory: IndexedEditableModelObject, NestingModelCategory, ModelCategoryItem, RootedEditableModel {

  @NSManaged public var presets: Set<Preset>
  @NSManaged public var childCategories: Set<PresetCategory>
  @NSManaged public var parentCategory: PresetCategory?

  public typealias ItemType = Preset
  public var items: [ItemType] { get { return Array(presets) } set { presets = Set(newValue) } }
  public func itemWithIndex(index: ModelIndex) -> ItemType? { return findByIndex(presets, index) }

  public typealias CategoryType = PresetCategory
  public var category: CategoryType? { get { return parentCategory } set { parentCategory = newValue } }

  public typealias NestedType = PresetCategory
  public var subcategories: [NestedType] { get { return Array(childCategories) } set { childCategories = Set(newValue) } }
  public func subcategoryWithIndex(index: ModelIndex) -> NestedType? { return findByIndex(childCategories, index) }

  override public var index: ModelIndex { return parentCategory != nil ? parentCategory!.index + "\(name)" : "\(name)" }

  /**
  itemWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: T?
  */
  public class func itemWithIndex<T:IndexedEditableModel>(index: ModelIndex, context: NSManagedObjectContext) -> T? {
    if index.isEmpty { return nil }
    var i = 1
    if let rootCategory = rootItemWithIndex(index[0..<i], context: context) {
      return itemWithIndexFromRoot(index, rootCategory)
    } else { return nil }
  }

  /**
  rootItemWithIndex:context:

  :param: index ModelIndex
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  public class func rootItemWithIndex(index: ModelIndex, context: NSManagedObjectContext) -> Self? {
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
