//
//  PresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc(PresetDetailController)
class PresetDetailController: BankItemDetailController {

  var preset: Preset { return item as Preset }

  lazy var categories: [PresetCategory] = PresetCategory.findAll() as? [PresetCategory] ?? []

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is Preset, "we should have been given a preset")

    // section 0 - row 0: category
    let categoryRow = Row(identifier: .TextField, isEditable: true, configureCell: {

      $0.name = "Category"
      $0.info = self.preset.presetCategory
//      $0.changeHandler = {[unowned self] c in
//        let text = c.info as? String
//        self.preset.category = text
//        if self.preset.category != nil && self.categories ∌ self.preset.category! {
//          self.categories.append(self.preset.category!)
//          self.categories.sort(<)
//        }
//      }
//      $0.pickerData = self.categories
//      $0.pickerSelection = self.preset.category
    })

    // section 0 - row 1: type
    let typeRow = Row(identifier: .Label, isEditable: false, configureCell: {
      $0.name = "Type"
      $0.info = "FIXME"
   })

    // section 1 - row 0: preview
    let previewRow = Row(identifier: .Image, isEditable: false, configureCell: {
      $0.info = self.preset.preview
    })

    sections = [ Section(title: nil, rows: [categoryRow, typeRow]),
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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
