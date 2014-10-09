//
//  BankSurrogateCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 10/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MoonKit

@objc(BankSurrogateCategory)
class BankSurrogateCategory: NSObject, BankDisplayItemCategory {

  let subcategories: [BankDisplayItemCategory]
  var parentCategory: BankDisplayItemCategory? { return nil }

	let items: [BankDisplayItemModel]
  let title: String

  let thumbnailableItems: Bool
  let previewableItems:   Bool
  let detailableItems:    Bool
  let editableItems:      Bool

  init(title: String,
       subcategories: [BankDisplayItemCategory] = [],
       items: [BankDisplayItemModel] = [],
       thumbnailableItems: Bool = false,
       previewableItems: Bool = false,
       detailableItems: Bool = false,
       editableItems: Bool = false)
  {
    self.title = title
    self.subcategories = subcategories
    self.items = items
    self.thumbnailableItems = thumbnailableItems
    self.previewableItems = previewableItems
    self.detailableItems = detailableItems
    self.editableItems = editableItems
  }

}
