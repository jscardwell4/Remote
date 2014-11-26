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

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is Preset, "we should have been given a preset")

    let element = (item as Preset).generateElement()
    if element != nil { println("\(element!.JSONDictionary())") }
    else { println("failed to create element from preset") }
    let detailsSection = BankItemDetailSection(sectionNumber: 0)

    detailsSection.addRow { return BankItemDetailLabelRow(pushableCategory: self.preset.presetCategory!, label: "Category") }
    detailsSection.addRow { return BankItemDetailLabelRow(label: "Type", value: "FIXME") }

    let previewSection = BankItemDetailSection(sectionNumber: 1)
    previewSection.addRow { return BankItemDetailImageRow(previewableItem: self.preset) }

    sections = [detailsSection, previewSection]

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
