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
class PresetCategory: BankCategoryObject, PreviewableCategory {

  @NSManaged var presets: Set<Preset>
  @NSManaged var childCategories: Set<PresetCategory>
  @NSManaged var parentCategory: PresetCategory?

  var items: [BankCategoryItem] { return Array(presets) }
  func setItems(items: [BankCategoryItem]) {
    if let presets = items as? [Preset] { self.presets = Set(presets) }
  }

  var subcategories: [BankCategory] { return Array(childCategories) }
  func setSubcategories(subcategories: [BankCategory]) {
    if let childCategories = subcategories as? [PresetCategory] { self.childCategories = Set(childCategories) }
  }

  var category: BankCategory? { return parentCategory }
  func setCategory(category: BankCategory?) {
    if let parentCategory = category as? PresetCategory { self.parentCategory = parentCategory }
    else if category == nil { parentCategory = nil }
  }

  override var index: String { return category == nil ? name : "\(category!.index)/\(name)" }


}
