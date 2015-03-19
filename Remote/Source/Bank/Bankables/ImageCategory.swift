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

  override var items: [BankCategoryItem] {
    get { return Array(images) }
    set { if let items = newValue as? [Image] { images = Set(items) } }
  }
  override var subcategories: [BankCategory] {
    get { return Array(childCategories) }
    set { if let subcategories = newValue as? [ImageCategory] { childCategories = Set(subcategories) } }
  }

  override var category: BankCategory? {
    get { return parentCategory }
    set { parentCategory = newValue as? ImageCategory }
  }

  override var path: String { return category == nil ? name : "\(category!.name)/\(name)" }

}
