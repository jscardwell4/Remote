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

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is Manufacturer, "we should have been given a manufacturer")

    // Devices
    // section 0 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let devicesSection = BankItemDetailSection(sectionNumber: 0, title: "Devices", createRows: {
      return sortedByName(self.manufacturer.devices.allObjects as? [ComponentDevice] ?? [])
              .map{BankItemDetailRow(pushableItem: $0)} ?? []
    })

    // Code Sets
    // section 1 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let codeSetsSection = BankItemDetailSection(sectionNumber: 1, title: "Code Sets", createRows: {
      return sortedByName(self.manufacturer.codeSets.allObjects as? [IRCodeSet] ?? [])
              .map{BankItemDetailRow(pushableCategory: $0)} ?? []
    })

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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
