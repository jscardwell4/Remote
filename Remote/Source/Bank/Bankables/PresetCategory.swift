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
class PresetCategory: BankCategory {

  var presets: [Preset] { get { return items as! [Preset] } set { items = newValue } }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data) // sets uuid, name

    // Try importing images
//    if let presetData = data["presets"] as? NSArray, let moc = managedObjectContext {
//      if presets == nil { presets = NSSet() }
//      let mutablePresets = mutableSetValueForKey("presets")
//      mutablePresets.addObjectsFromArray(Preset.importObjectsFromData(presetData, context: moc))
//    }

    // Try importing subcategories
//    if let subCategoryData = data["subcategories"] as? NSArray, let moc = managedObjectContext {
//      if subcategoriesSet == nil { subcategoriesSet = NSSet() }
//      let mutableSubcategories = mutableSetValueForKey("subcategoriesSet")
//      mutableSubcategories.addObjectsFromArray(PresetCategory.importObjectsFromData(subCategoryData, context: moc))
//    }

  }


  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

//    if let presetDictionaries = sortedByName(presets?.allObjects as? [Preset])?.map({$0.JSONDictionary()}) {
//      if presetDictionaries.count > 0 {
//        apply(presetDictionaries){$0.removeObjectForKey("category")}
//        dictionary["presets"] = presetDictionaries
//      }
//    }

//    if let subcategoryDictionaries = sortedByName(subcategoriesSet?.allObjects as? [ImageCategory])?.map({$0.JSONDictionary()}) {
//      if subcategoryDictionaries.count > 0 {
//        dictionary["subcategories"] = subcategoryDictionaries
//      }
//    }

    return dictionary
  }
  

  
}
