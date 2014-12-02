//
//  RemotePresetDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/27/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

@objc(RemotePresetDetailController)
class RemotePresetDetailController: PresetDetailController {

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)
    if var detailsSection = sections.first {

      detailsSection.addRow {
        var row = DetailSwitchRow()
        row.name = "Top Bar Hidden"
        row.info = NSNumber(bool: self.preset.attributes.topBarHidden ?? false)
        row.valueDidChange = { self.preset.attributes.topBarHidden = ($0 as? NSNumber)?.boolValue }

        return row
      }

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
