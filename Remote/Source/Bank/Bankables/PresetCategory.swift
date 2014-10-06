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

  override var subcategories: [BankDisplayItemCategory] { return (subcategoriesSet?.allObjects ?? []) as [PresetCategory] }
  override var items: [BankDisplayItemModel] { return (presets?.allObjects ?? []) as [Preset] }
  override var thumbnailableItems: Bool { return Preset.isThumbnailable() }
  override var previewableItems:   Bool { return Preset.isPreviewable()   }
  override var detailableItems:    Bool { return Preset.isDetailable()    }
  override var editableItems:      Bool { return Preset.isEditable()      }

}
