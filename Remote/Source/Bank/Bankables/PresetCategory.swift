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
class PresetCategory: BankableModelCategory {

  @NSManaged var subcategoriesSet: NSSet?
  @NSManaged var primitiveParentCategory: PresetCategory?
  override var parentCategory: BankDisplayItemCategory? {
    get {
      willAccessValueForKey("parentCategory")
      let category = primitiveParentCategory
      didAccessValueForKey("parentCategory")
      return category
    }
    set {
        willChangeValueForKey("parentCategory")
        primitiveParentCategory = newValue as? PresetCategory
        didChangeValueForKey("parentCategory")
    }
  }
  @NSManaged var presets: NSSet?

  override var subcategories: [BankDisplayItemCategory] {
    get { return (subcategoriesSet?.allObjects ?? []) as [PresetCategory] }
    set { if let newSubcategories = newValue as? [PresetCategory] { subcategoriesSet = NSSet(array: newSubcategories) } }
  }

  override var items: [BankDisplayItemModel] {
    get { return (presets?.allObjects ?? []) as [Preset] }
    set { if let newItems = newValue as? [Preset] { presets = NSSet(array: newItems) } }
  }
  
  override var previewableItems:   Bool { return Preset.isPreviewable()   }
  override var editableItems:      Bool { return Preset.isEditable()      }

}
