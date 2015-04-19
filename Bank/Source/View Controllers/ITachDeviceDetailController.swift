//
//  ITachDeviceDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit
import DataModel

class ITachDeviceDetailController: BankItemDetailController {

  private struct SectionKey {
    static let Details = "Details"
    static let ComponentDevices = "ComponentDevices"
  }

  private struct RowKey {
    static let Identifier       = "Identifier"
    static let Make             = "Make"
    static let Model            = "Model"
    static let ConfigURL        = "Config-URL"
    static let Revision         = "Revision"
    static let Pcb_PN           = "Pcb_PN"
    static let Pkg_Level        = "Pkg_Level"
    static let SDKClass         = "SDKClass"
    static let ComponentDevices = "ComponentDevices"
  }

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is ITachDevice, "we should have been given an itach device")

    loadDetailsSection()
    loadComponentDevicesSection()

  }

  /** loadDetailsSection */
  private func loadDetailsSection() {

    /// Main section: Identifier, Make, Model, Config-URL, Revision, Pcb_PN, Pkg_Level, SDKClass
    ////////////////////////////////////////////////////////////////////////////////////////////

    let iTachDevice = model as! ITachDevice

    let mainSection = DetailSection(section: 0)

    mainSection.addRow({ DetailLabelRow(label: "Identifier", value: iTachDevice.uniqueIdentifier)}, forKey: RowKey.Identifier)
    mainSection.addRow({ DetailLabelRow(label: "Make", value: iTachDevice.make)}, forKey: RowKey.Make)
    mainSection.addRow({ DetailLabelRow(label: "Model", value: iTachDevice.model)}, forKey: RowKey.Model)
    mainSection.addRow({ DetailLabelRow(label: "Config-URL", value: iTachDevice.configURL)}, forKey: RowKey.ConfigURL)
    mainSection.addRow({ DetailLabelRow(label: "Revision", value: iTachDevice.revision)}, forKey: RowKey.Revision)
    mainSection.addRow({ DetailLabelRow(label: "Pcb_PN", value: iTachDevice.pcbPN)}, forKey: RowKey.Pcb_PN)
    mainSection.addRow({ DetailLabelRow(label: "Pkg_Level", value: iTachDevice.pkgLevel)}, forKey: RowKey.Pkg_Level)
    mainSection.addRow({ DetailLabelRow(label: "SDKClass", value: iTachDevice.sdkClass)}, forKey: RowKey.SDKClass)

    sections[SectionKey.Details] = mainSection

  }

  /** loadComponentDevicesSection */
  private func loadComponentDevicesSection() {

    let iTachDevice = model as! ITachDevice

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    let componentDevicesSection = DetailSection(section: 1, title: "Component Devices")
    for (idx, device) in enumerate(sortedByName(iTachDevice.componentDevices)) {
      componentDevicesSection.addRow({ DetailListRow(pushableItem: device) }, forKey: "\(RowKey.ComponentDevices)\(idx)")
    }

    sections[SectionKey.ComponentDevices] = componentDevicesSection

  }

}
