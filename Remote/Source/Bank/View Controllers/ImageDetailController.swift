//
//  ImageDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit

@objc(ImageDetailController)
class ImageDetailController: BankItemDetailController {

  var image: Image { return item as Image }

  lazy var categories: [String] = { [unowned self] in
    var categories: [String] = []
    if let fetchedCategories = Image.allValuesForAttribute("category") as? [String] { categories += fetchedCategories }
    return categories
    }()

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init(item: BankableModelObject, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is Image, "we should have been given a image")

    // section 0 - row 0: category
    let categoryRow = Row(identifier: BankItemCellTextFieldStyleIdentifier, isEditable: true) { [unowned self] in

      $0.name = "Category"
      $0.info = self.image.category ?? "Uncategorized"
      $0.changeHandler = {[unowned self] cell in
        let text = cell.info as? String
        self.image.category = text
        if self.image.category != nil && self.categories ∌ self.image.category! {
          self.categories.append(self.image.category!)
          self.categories.sort(<)
        }
      }
      $0.pickerData = self.categories
      $0.pickerSelection = self.image.category
    }

    // section 0 - row 1: file
    let fileRow = Row(identifier: BankItemCellLabelStyleIdentifier, isEditable: false) { [unowned self] in
      $0.name = "File"
      $0.info = self.image.fileName
    }

    // section 0 - row 2: size
    let sizeRow = Row(identifier: BankItemCellLabelStyleIdentifier, isEditable: false) { [unowned self] in
      $0.name = "Size"
      $0.info = PrettySize(self.image.size)
    }

    // section 1 - row 0: preview
    let previewRow = Row(identifier: BankItemCellImageStyleIdentifier, isEditable: false) {[unowned self] in
      $0.info = self.image.preview
    }

    sections = [ Section(title: nil, rows: [categoryRow, fileRow, sizeRow]),
                 Section(title: nil, rows: [previewRow]) ]
  }

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
  override init(style: UITableViewStyle) { super.init(style: style) }
  
  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
