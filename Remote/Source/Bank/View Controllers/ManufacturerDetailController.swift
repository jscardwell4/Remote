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

  var manufacturer: Manufacturer { return model as Manufacturer }

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)
    precondition(model is Manufacturer, "we should have been given a manufacturer")

    // Devices
    // section 0 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let devicesSection = DetailSection(sectionNumber: 0, title: "Devices")
    for device in sortedByName(self.manufacturer.devices?.allObjects as? [ComponentDevice] ?? []) {
      devicesSection.addRow { return DetailListRow(pushableItem: device) }
    }

    // Code Sets
    // section 1 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let codeSetsSection = DetailSection(sectionNumber: 1, title: "Code Sets")
    for codeSet in sortedByName(self.manufacturer.codeSets?.allObjects as? [IRCodeSet] ?? []) {
      codeSetsSection.addRow { return DetailListRow(pushableCategory: codeSet) }
    }

    /// Create the sections
    ////////////////////////////////////////////////////////////////////////////////

    sections = [devicesSection, codeSetsSection]

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
