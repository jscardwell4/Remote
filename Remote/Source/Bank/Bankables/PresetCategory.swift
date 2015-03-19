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

  override var subcategories: [BankCategory] {
    get { return Array(childCategories) }
    set { if let subcategories = newValue as? [PresetCategory] { childCategories = Set(subcategories) } }
  }
  override var items: [BankCategoryItem] {
    get { return Array(presets) }
    set { if let items = newValue as? [Preset] { presets = Set(items) } }
  }
  override var category: BankCategory? {
    get { return parentCategory }
    set { parentCategory = newValue as? PresetCategory }
  }

  override var path: String { return category == nil ? name : "\(category!.path)/\(name)" }


}
