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
class BankSurrogateCategory: NSObject, BankItemCategory {

  var subcategories: [BankItemCategory] = []
  var parentCategory: BankItemCategory?

	var items: [BankItemModel] = []
  let title: String

  let previewableItems:   Bool
  let editableItems:      Bool

  func save() {}
  func delete() {}
  func rollback() {}

  var editable: Bool { return false }

  var categoryPath: String { return "" }

  /**
  initWithTitle:subcategories:items:previewableItems:editableItems:

  :param: title String
  :param: subcategories [BankItemCategory] = []
  :param: items [BankItemModel] = []
  :param: previewableItems Bool = false
  :param: editableItems Bool = false
  */
  init(title: String,
       subcategories: [BankItemCategory] = [],
       items: [BankItemModel] = [],
       previewableItems: Bool = false,
       editableItems: Bool = false)
  {
    self.title = title
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