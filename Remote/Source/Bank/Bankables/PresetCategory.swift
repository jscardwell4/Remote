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

  override class func itemType() -> BankableModelObject.Type { return Preset.self }

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

  /**
  updateWithData:

  :param: data [NSObject AnyObject]!
  */
  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data) // sets uuid, name

    // Try importing images
    if let presetData = data["presets"] as? NSArray {
      if presets == nil { presets = NSSet() }
      let mutablePresets = mutableSetValueForKey("presets")
      if let importedPresets = Preset.importObjectsFromData(presetData, context: managedObjectContext) {
        mutablePresets.addObjectsFromArray(importedPresets)
      }
    }

    // Try importing subcategories
    if let subCategoryData = data["subcategories"] as? NSArray {
      if subcategoriesSet == nil { subcategoriesSet = NSSet() }
      let mutableSubcategories = mutableSetValueForKey("subcategoriesSet")
      if let importedSubcategories = PresetCategory.importObjectsFromData(subCategoryData, context: managedObjectContext) {
        mutableSubcategories.addObjectsFromArray(importedSubcategories)
      }
    }

  }


  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary! {
    let dictionary = super.JSONDictionary()

    if let presetDictionaries = sortedByName(presets?.allObjects as? [Preset])?.map({$0.JSONDictionary()}) {
      if presetDictionaries.count > 0 {
        apply(presetDictionaries){$0.removeObjectForKey("category")}
        dictionary["presets"] = presetDictionaries
      }
    }

    if let subcategoryDictionaries = sortedByName(subcategoriesSet?.allObjects as? [ImageCategory])?.map({$0.JSONDictionary()}) {
      if subcategoryDictionaries.count > 0 {
        dictionary["subcategories"] = subcategoryDictionaries
      }
    }

    return dictionary
  }
  

  
}
