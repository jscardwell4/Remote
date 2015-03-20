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
class ImageCategory: BankCategoryObject, PreviewableCategory {

  @NSManaged var images: Set<Image>
  @NSManaged var childCategories: Set<ImageCategory>
  @NSManaged var parentCategory: ImageCategory?

  let previewableItems = true
  let editableItems = true

  var items: [BankCategoryItem] { return Array(images) }
  func setItems(items: [BankCategoryItem]) {
    if let images = items as? [Image] { self.images = Set(images) }
  }

  var subcategories: [BankCategory] { return Array(childCategories) }
  func setSubcategories(subcategories: [BankCategory]) {
    if let childCategories = subcategories as? [ImageCategory] { self.childCategories = Set(childCategories) }
  }

  var category: BankCategory? { return parentCategory }
  func setCategory(category: BankCategory?) {
    if let parentCategory = category as? ImageCategory { self.parentCategory = parentCategory }
    else if category == nil { parentCategory = nil }
  }

  override var index: String { return category == nil ? name : "\(category!.index)/\(name)" }

}
