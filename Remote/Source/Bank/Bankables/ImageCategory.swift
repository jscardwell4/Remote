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
class ImageCategory: IndexedBankCategoryObject, PreviewableCategory {

  @NSManaged var images: Set<Image>
  @NSManaged var childCategories: Set<ImageCategory>
  @NSManaged var parentCategory: ImageCategory?

  let previewableItems = true
  let editableItems = true

  var indexedItems: [IndexedBankCategoryItem] { return Array(images) }
  func setIndexedItems(items: [IndexedBankCategoryItem]) {
    if let images = items as? [Image] { self.images = Set(images) }
  }

  var indexedSubcategories: [IndexedBankCategory] { return Array(childCategories) }
  func setIndexedSubcategories(subcategories: [IndexedBankCategory]) {
    if let childCategories = subcategories as? [ImageCategory] { self.childCategories = Set(childCategories) }
  }

  var indexedCategory: IndexedBankCategory? { return parentCategory }
  func setIndexedCategory(category: IndexedBankCategory?) {
    if let parentCategory = category as? ImageCategory { self.parentCategory = parentCategory }
    else if category == nil { parentCategory = nil }
  }

  override var index: String { return indexedCategory == nil ? name : "\(indexedCategory!.index)/\(name)" }

}
