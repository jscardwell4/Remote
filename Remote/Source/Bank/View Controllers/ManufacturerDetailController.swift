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
  var codeSets: [IRCodeSet] = [] { didSet { codeSets.sort{$0.0.name < $0.1.name} } }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is Manufacturer, "we should have been given a manufacturer")

    devices = manufacturer.devices.allObjects as [ComponentDevice]
    codeSets = manufacturer.codeSets.allObjects as [IRCodeSet]

    // section 0 - row 0: devices
    let devicesRow = Row(identifier: .Table, isEditable: true,
      height: CGFloat(devices.count) * BankItemDetailController.defaultRowHeight + 14.0, configureCell: { $0.info = self.devices })

    // section 1 - row 0: codeSets
    let codeSetsRow = Row(identifier: .Table, isEditable: false,
      height: CGFloat(codeSets.count) * BankItemDetailController.defaultRowHeight + 14.0, configureCell: { $0.info = self.codeSets })

    sections = [ Section(title: "Devices", rows: [devicesRow]),
                 Section(title: "Code Sets", rows: [codeSetsRow]) ]
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

  //TODO: Add table row selection support for sub-tables

}
