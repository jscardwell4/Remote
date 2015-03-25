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
final class PresetCategory: IndexedEditableModelObject, NestingModelCategory, ModelCategoryItem, RootedEditableModel {

  @NSManaged var presets: Set<Preset>
  @NSManaged var childCategories: Set<PresetCategory>
  @NSManaged var parentCategory: PresetCategory?

  typealias ItemType = Preset
  var items: [ItemType] { get { return Array(presets) } set { presets = Set(newValue) } }
  func itemWithIndex(index: ModelIndex) -> ItemType? { return findByIndex(presets, index) }

  typealias CategoryType = PresetCategory
  var category: CategoryType? { get { return parentCategory } set { parentCategory = newValue } }

  typealias NestedType = PresetCategory
  var subcategories: [NestedType] { get { return Array(childCategories) } set { childCategories = Set(newValue) } }
  func subcategoryWithIndex(index: ModelIndex) -> NestedType? { return findByIndex(childCategories, index) }

  override var index: ModelIndex { return parentCategory != nil ? parentCategory!.index + "\(name)" : "\(name)" }

  /**
  itemWithIndex:context:

  :param: index ModelIndex
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

    //TODO: Fill in stub
  }

  /**
  JSONDictionary

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    //TODO: Fill in stub

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }



}
