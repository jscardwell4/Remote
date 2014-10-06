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
class ImageCategory: BankableModelCategory {

  @NSManaged var subcategoriesSet: NSSet?
  @NSManaged var primitiveParentCategory: ImageCategory?
  override var parentCategory: BankDisplayItemCategory? {
    get {
      willAccessValueForKey("parentCategory")
      let category = primitiveParentCategory
      didAccessValueForKey("parentCategory")
      return category
    }
    set {
      willChangeValueForKey("parentCategory")
      primitiveParentCategory = newValue as? ImageCategory
      didChangeValueForKey("parentCategory")
    }
  }
  @NSManaged var images: NSSet?

  override var subcategories: [BankDisplayItemCategory] {
    var categories = (subcategoriesSet?.allObjects ?? []) as [ImageCategory]
    categories.sort{$0.0.title < $0.1.title}
    return categories
  }
  override var items: [BankDisplayItemModel] {
    var items = (images?.allObjects ?? []) as [Image]
    items.sort{$0.0.name < $0.1.name}
    return items
  }
  override var thumbnailableItems: Bool { return Image.isThumbnailable() }
  override var previewableItems:   Bool { return Image.isPreviewable()   }
  override var detailableItems:    Bool { return Image.isDetailable()    }
  override var editableItems:      Bool { return Image.isEditable()      }

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
