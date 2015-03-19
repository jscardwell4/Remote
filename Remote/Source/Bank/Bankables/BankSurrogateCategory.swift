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

//class BankSurrogateCategoryItem: NSObject, BankCategoryItem {
//  let item: BankModel
//  let category: BankCategory
//  var path: String { return "" }
//}

@objc(BankSurrogateCategory)
class BankSurrogateCategory: NSObject, BankCategory {

  var subcategories: [BankCategory] = []
  var category: BankCategory?

  var items: [BankCategoryItem] = []
  var name: String
  let user = false
  let uuid: String = MSNonce()

  let previewableItems:   Bool
  let editableItems:      Bool

  var path: String { return "" }

  func save() {}
  func rollback() {}
  func delete() {}
  let editable = false

  /**
  initWithTitle:subcategories:items:previewableItems:editableItems:

  :param: title String
  :param: subcategories [BankItemCategory] = []
  :param: items [BankModel] = []
  :param: previewableItems Bool = false
  :param: editableItems Bool = false
  */
  init(title: String,
       subcategories: [BankCategory] = [],
       items: [BankCategoryItem] = [],
       previewableItems: Bool = false,
       editableItems: Bool = false)
  {
    self.name = title
    self.subcategories = subcategories
    self.items = items
    self.previewableItems = previewableItems
    self.editableItems = editableItems
  }

}

extension BankSurrogateCategory: MSJSONExport {

  var JSONObject: AnyObject { return ["subcategories": subcategories, "items": items] }

  var JSONString: String { return (JSONObject as! NSDictionary).JSONString }

}