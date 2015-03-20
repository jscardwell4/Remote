//
//  BankCategoryItemObject.swift
//  Remote
//
//  Created by Jason Cardwell on 3/15/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

class BankCategoryItemObject: BankModelObject, BankCategoryItem {

  var category: BankCategory {
    get { fatalError("category must be overridden by subclass") }
    set { fatalError("category must be overridden by subclass") }
  }


}

class IndexedBankCategoryItemObject: BankCategoryItemObject, IndexedBankCategoryItem {
  var indexedCategory: IndexedBankCategory {
    precondition(category is IndexedBankCategory, "category object must conform to IndexedBankCategory")
    return category as! IndexedBankCategory
  }
  var index: String { return "\(indexedCategory.index)/\(name)" }
}