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

    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "Identifier"
      row.info = iTachDevice.uniqueIdentifier
      return row
      }, forKey: RowKey.Identifier)
    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "Make"
      row.info = iTachDevice.make
      return row
      }, forKey: RowKey.Make)
    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "Model"
      row.info = iTachDevice.model
      return row
      }, forKey: RowKey.Model)
    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "Config-URL"
      row.info = iTachDevice.configURL
      return row
      }, forKey: RowKey.ConfigURL)
    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "Revision"
      row.info = iTachDevice.revision
      return row
      }, forKey: RowKey.Revision)
    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "Pcb_PN"
      row.info = iTachDevice.pcbPN
      return row
      }, forKey: RowKey.Pcb_PN)
    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "Pkg_Level"
      row.info = iTachDevice.pkgLevel
      return row
      }, forKey: RowKey.Pkg_Level)
    mainSection.addRow({
      let row = DetailLabelRow()
      row.name = "SDKClass"
      row.info = iTachDevice.sdkClass
      return row
      }, forKey: RowKey.SDKClass)

    sections[SectionKey.Details] = mainSection

  }

  /** loadComponentDevicesSection */
  private func loadComponentDevicesSection() {

    let iTachDevice = model as! ITachDevice

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    let componentDevicesSection = DetailSection(section: 1, title: "Component Devices")
    for (idx, device) in sortedByName(iTachDevice.componentDevices).enumerate() {
      componentDevicesSection.addRow({
       let row = DetailListRow()
       row.info = device
       row.select = DetailRow.selectPushableItem(device)
       return row
       }, forKey: "\(RowKey.ComponentDevices)\(idx)")
    }

    sections[SectionKey.ComponentDevices] = componentDevicesSection

  }

}
