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
class PresetCategory: IndexedBankCategoryObject, PreviewableCategory {

  @NSManaged var presets: Set<Preset>
  @NSManaged var childCategories: Set<PresetCategory>
  @NSManaged var parentCategory: PresetCategory?

  var indexedItems: [IndexedBankCategoryItem] { return Array(presets) }
  func setIndexedItems(items: [IndexedBankCategoryItem]) {
    if let presets = items as? [Preset] { self.presets = Set(presets) }
  }

  var indexedSubcategories: [IndexedBankCategory] { return Array(childCategories) }
  func setIndexedSubcategories(subcategories: [IndexedBankCategory]) {
    if let childCategories = subcategories as? [PresetCategory] { self.childCategories = Set(childCategories) }
  }

  var indexedCategory: IndexedBankCategory? { return parentCategory }
  func setIndexedCategory(category: IndexedBankCategory?) {
    if let parentCategory = category as? PresetCategory { self.parentCategory = parentCategory }
    else if category == nil { parentCategory = nil }
  }

  override var index: String { return indexedCategory == nil ? name : "\(indexedCategory!.index)/\(name)" }

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
