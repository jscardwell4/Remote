//
//  ImageCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 9/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ImageCategory)
class ImageCategory: BankCategory {

  var images: [Image] {
    get { return items as! [Image] }
    set { items = newValue }
  }

  override var previewableItems:   Bool { return true }
  override var editableItems:      Bool { return true }

  /**
  updateWithData:

  :param: data [String:AnyObject]
  */
  override func updateWithData(data: [String:AnyObject]) {
    super.updateWithData(data) // sets uuid, name

    // Try importing images
//    if let imageData = data["images"] as? NSArray, let moc = managedObjectContext {
//      if images == nil { images = NSSet() }
//      let mutableImages = mutableSetValueForKey("images")
//      mutableImages.addObjectsFromArray(Image.importObjectsFromData(imageData, context: moc))
//    }

    // Try importing subcategories
//    if let subCategoryData = data["subcategories"] as? NSArray, let moc = managedObjectContext {
//      if subcategoriesSet == nil { subcategoriesSet = NSSet() }
//      let mutableSubcategories = mutableSetValueForKey("subcategoriesSet")
//      mutableSubcategories.addObjectsFromArray(ImageCategory.importObjectsFromData(subCategoryData, context: moc))
//    }

  }

  /**
  JSONDictionary

  :returns: MSDictionary!
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

//    if let imageDictionaries = sortedByName(images?.allObjects as? [Image])?.map({$0.JSONDictionary()}) {
//      if imageDictionaries.count > 0 {
//        apply(imageDictionaries){$0.removeObjectForKey("category")}
//        dictionary["images"] = imageDictionaries
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
