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

  private struct SectionKey {
    static let Devices  = "Devices"
    static let CodeSets = "Code Sets"
  }

  private struct RowKey {
    static let Devices  = "Devices"
    static let CodeSets = "Code Sets"
  }

  /** loadSections */
  override func loadSections() {
    super.loadSections()
    precondition(model is Manufacturer, "we should have been given a manufacturer")

    loadDevicesSection()
    loadCodeSetsSection()

  }

  /** loadDevicesSection */
  private func loadDevicesSection() {

    let manufacturer = model as Manufacturer

    // Devices
    // section 0 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let devicesSection = DetailSection(section: 0, title: "Devices")
    for (idx, device) in enumerate(sortedByName(manufacturer.devices?.allObjects as? [ComponentDevice] ?? [])) {
      devicesSection.addRow({ DetailListRow(pushableItem: device) }, forKey: "\(RowKey.Devices)\(idx)")
    }

    sections[SectionKey.Devices] = devicesSection
  }

  /** loadCodeSetsSection */
  private func loadCodeSetsSection() {

    let manufacturer = model as Manufacturer

    // Code Sets
    // section 1 - row 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let codeSetsSection = DetailSection(section: 1, title: "Code Sets")
    for (idx, codeSet) in enumerate(sortedByName(manufacturer.codeSets?.allObjects as? [IRCodeSet] ?? [])) {
      codeSetsSection.addRow({ DetailListRow(pushableCategory: codeSet) }, forKey: "\(RowKey.CodeSets)\(idx)")
    }

    /// Create the sections
    ////////////////////////////////////////////////////////////////////////////////

    sections[SectionKey.CodeSets] = codeSetsSection

  }

}
