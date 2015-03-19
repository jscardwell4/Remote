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
class PresetCategory: NamedModelObject, BankCategory {

  @NSManaged var presets: Set<Preset>
  @NSManaged var childCategories: Set<PresetCategory>
  @NSManaged var parentCategory: PresetCategory?
  @NSManaged var user: Bool

  var subcategories: [BankCategory] {
    get { return Array(childCategories) }
    set { if let subcategories = newValue as? [PresetCategory] { childCategories = Set(subcategories) } }
  }
  var items: [BankCategoryItem] {
    get { return Array(presets) }
    set { if let items = newValue as? [Preset] { presets = Set(items) } }
  }
  var category: BankCategory? {
    get { return parentCategory }
    set { parentCategory = newValue as? PresetCategory }
  }

  var path: String { return category == nil ? name : "\(category!.path)/\(name)" }


}
