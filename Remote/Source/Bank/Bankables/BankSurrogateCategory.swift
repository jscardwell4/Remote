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

  var subcategories: [BankDisplayItemCategory] 
  var parentCategory: BankDisplayItemCategory? { return nil }

	var items: [BankDisplayItemModel] = []
  var title: String = ""

  var thumbnailableItems: Bool { return false }
  var previewableItems:   Bool { return false }
  var detailableItems:    Bool { return false }
  var editableItems:      Bool { return false }

  init(title: String, subcategories: [BankDisplayItemCategory]) {
    self.title = title
    self.subcategories = subcategories
  }

}
