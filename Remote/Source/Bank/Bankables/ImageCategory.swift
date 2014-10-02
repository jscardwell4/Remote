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
class ImageCategory: NamedModelObject, BankableModelCategory {

  @NSManaged var subcategoriesSet: NSSet?
  @NSManaged var parentCategory: ImageCategory?
  @NSManaged var images: NSSet?

  var categoryPath: String {
    var path = name
    var currentCategory = self
      while let parent = currentCategory.parentCategory {
        path = parent.name + "/" + path
        currentCategory = parent
      }
    return path
  }

  var subcategories: [ImageCategory] { return (subcategoriesSet?.allObjects ?? []) as [ImageCategory] }

  var allItems: [Image] { return (images?.allObjects ?? []) as [Image] }

  /**
  updateWithData:

  :param: data [NSObject AnyObject]!
  */
  override func updateWithData(data: [NSObject : AnyObject]!) {
    super.updateWithData(data) // sets uuid, name

    // Try importing images
    if let imageData = data["images"] as? NSArray {
      if images == nil { images = NSSet() }
      let mutableImages = mutableSetValueForKey("images")
      if let importedImages = Image.importObjectsFromData(imageData, context: managedObjectContext) {
        mutableImages.addObjectsFromArray(importedImages)
      }
    }

    // Try importing subcategories
    if let subCategoryData = data["subcategories"] as? NSArray {
      if subcategoriesSet == nil { subcategoriesSet = NSSet() }
      let mutableSubcategories = mutableSetValueForKey("subcategoriesSet")
      if let importedSubcategories = ImageCategory.importObjectsFromData(subCategoryData, context: managedObjectContext) {
        mutableSubcategories.addObjectsFromArray(importedSubcategories)
      }
    }

  }

}
