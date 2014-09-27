//
//  ManufacturerDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit

@objc(ManufacturerDetailController)
class ManufacturerDetailController: BankItemDetailController {

  var manufacturer: Manufacturer { return item as Manufacturer }

  var devices: [ComponentDevice] = [] { didSet { devices.sort{$0.0.name < $0.1.name} } }
  var codesets: [String] = [] { didSet { codesets.sort(<) } }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init(item: BankableModelObject, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is Manufacturer, "we should have been given a manufacturer")

    devices = manufacturer.devices.allObjects as [ComponentDevice]
    codesets = manufacturer.codesets.allObjects as [String]

    // section 0 - row 0: devices
    let devicesRow = Row(identifier: BankItemCellTableStyleIdentifier, isEditable: true) { [unowned self] in
      $0.info = self.devices
    }

    // section 1 - row 0: codesets
    let codesetsRow = Row(identifier: BankItemCellImageStyleIdentifier, isEditable: false) {[unowned self] in
      $0.info = self.codesets
    }

    sections = [ Section(title: "Devices",  rows: [devicesRow]),
                 Section(title: "Codesets", rows: [codesetsRow]) ]
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

  //TODO: Add table row selection support for sub-tables

}
