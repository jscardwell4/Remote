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

  /** loadSections */
  override func loadSections() {
    super.loadSections()
    precondition(model is Manufacturer, "we should have been given a manufacturer")

    let manufacturer = model as Manufacturer

    // Devices
    // section 0 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let devicesSection = DetailSection(section: 0, title: "Devices")
    for device in sortedByName(manufacturer.devices?.allObjects as? [ComponentDevice] ?? []) {
      devicesSection.addRow { DetailListRow(pushableItem: device) }
    }

    // Code Sets
    // section 1 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let codeSetsSection = DetailSection(section: 1, title: "Code Sets")
    for codeSet in sortedByName(manufacturer.codeSets?.allObjects as? [IRCodeSet] ?? []) {
      codeSetsSection.addRow { DetailListRow(pushableCategory: codeSet) }
    }

    /// Create the sections
    ////////////////////////////////////////////////////////////////////////////////

    sections = [devicesSection, codeSetsSection]

  }

}
