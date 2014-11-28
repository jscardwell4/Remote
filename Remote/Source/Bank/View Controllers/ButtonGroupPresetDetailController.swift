//
//  ButtonGroupPresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc(ButtonGroupPresetDetailController)
class ButtonGroupPresetDetailController: PresetDetailController {

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    if let detailsSection = sections.first {

      detailsSection.addRow {
        let row = BankItemDetailSwitchRow()
        row.name = "Autohide"
        row.info = NSNumber(bool: self.preset.attributes.autohide ?? false)
        row.valueDidChange = { self.preset.attributes.autohide = ($0 as? NSNumber)?.boolValue }

        return row
      }

      detailsSection.addRow {
        let row = BankItemDetailTextFieldRow()
        row.name = "Label"
        row.info =  self.preset.attributes.label?.string
        row.valueDidChange = { if let s = $0 as? String { self.preset.attributes.label = NSAttributedString(string: s) } }

        return row
      }

      // TODO: labelAttributes
      // TODO: labelConstraints
      // TODO: panelAssignment

    }
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
