//
//  BankItem.swift
//  Remote
//
//  Created by Jason Cardwell on 3/1/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

/** Protocol for items displayed by the bank */
@objc protocol BankItemModel: class, NSObjectProtocol, Renameable, Model, MSJSONExport, EditableItem {}

/** Protocol for types that serve as a category for `BankItemModel` objects */
@objc protocol BankItemCategory: class, NSObjectProtocol, MSJSONExport {

  var title: String { get }

  var items: [BankItemModel] { get set }

  var previewableItems:   Bool { get }
  var editableItems:      Bool { get }

  var editable: Bool { get }

  var categoryPath: String { get }

  func save()
  func delete()
  func rollback()

  var subcategories:  [BankItemCategory] { get set }
  var parentCategory: BankItemCategory?   { get set }
}


/**
recursiveItemCountForCategory:

:param: category BankItemCategory

:returns: Int
*/
func recursiveItemCountForCategory(category: BankItemCategory) -> Int {
  return recursiveReduce(0, {$0.subcategories}, {$0.0 + $0.1.items.count}, category)
}

/**
categoryPath:

:param: category BankItemCategory?

:returns: String?
*/
func categoryPath(category: BankItemCategory?) -> String? {
  if category == nil { return nil }
  var path: [String] = [category!.title]
  var tempCategory = category!.parentCategory
  while tempCategory != nil {
    path.append(tempCategory!.title)
    tempCategory = tempCategory!.parentCategory
  }
  return "/".join(path.reverse())
}

/**
itemForCategory:atPath:

:param: category BankItemCategory
:param: path String

:returns: BankItemModel?
*/
func itemForCategory(category: BankItemCategory, atPath path: String) -> BankItemModel? {
  var item: BankItemModel?
  var components = split(path){$0 == "/"}
  let itemName = components.removeLast()
  var currentCategory: BankItemCategory? = category
  if components.count > 0 {
    components = components.reverse()
    var categoryName: String
    while currentCategory != nil && components.count > 0 {
      categoryName = components.removeLast()
      currentCategory = currentCategory?.subcategories.filter{$0.title == categoryName}.first
    }
  }
  if currentCategory != nil && components.count == 0 {
    item = currentCategory?.items.filter{$0.name == itemName}.first
  }
  return item
}

