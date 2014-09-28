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
class ImageCategory: NamedModelObject, BankableCategory {

  @NSManaged var subCategories: NSSet?
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

  var allItems: NSSet? { return images }

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
      if subCategories == nil { subCategories = NSSet() }
      let mutableSubCategories = mutableSetValueForKey("subCategories")
      if let importedSubCategories = ImageCategory.importObjectsFromData(subCategoryData, context: managedObjectContext) {
        mutableSubCategories.addObjectsFromArray(importedSubCategories)
      }
    }

  }

}
