//
//  ISYDeviceDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//
import Foundation
import UIKit
import MoonKit
import DataModel

class ISYDeviceDetailController: BankItemDetailController {

  private struct SectionKey {
    static let ID               = "ID"
    static let Model            = "Model"
    static let Manufacturer     = "Manufacturer"
    static let Nodes            = "Nodes"
    static let Groups           = "Groups"
    static let ComponentDevices = "ComponentDevices"
  }

  private struct RowKey {
    static let Identifier       = "Identifier"
    static let BaseURL          = "Base URL"
    static let Model            = "Model"
    static let ModelName        = "Model Name"
    static let Number           = "Number"
    static let Description      = "Description"
    static let FriendlyName     = "Friendly Name"
    static let Manufacturer     = "Manufacturer"
    static let ManufacturerName = "Manufacturer Name"
    static let URL              = "URL"
    static let Nodes            = "Nodes"
    static let Groups           = "Groups"
    static let ComponentDevices = "Component Devices"
  }

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is ISYDevice, "we should have been given an isy device")

    loadIDSection()
    loadModelSection()
    loadManufacturerSection()
    loadNodesSection()
    loadGroupsSection()
    loadComponentDevicesSection()

}

/** loadIDSection */
private func loadIDSection() {

    let iSYDevice = model as! ISYDevice

    /// Identification section: Identifier, Base URL
    ////////////////////////////////////////////////////////////////////////////////

    var idSection = DetailSection(section: 0)
    idSection.addRow({
      let row = DetailLabelRow()
      row.name = "Identifier"
      row.info = iSYDevice.uniqueIdentifier
      return row
    }, forKey: RowKey.Identifier)
    idSection.addRow({
      let row = DetailLabelRow()
      row.name = "Base URL"
      row.info = iSYDevice.baseURL
      return row
    }, forKey: RowKey.BaseURL)

    sections[SectionKey.ID] = idSection
}

/** loadModelSection */
private func loadModelSection() {

    let iSYDevice = model as! ISYDevice

    /// Model section: Name, Number, Description, Friendly Name
    ////////////////////////////////////////////////////////////////////////////////

    var modelSection = DetailSection(section: 1, title: "Model")
    modelSection.addRow({
      let row = DetailLabelRow()
      row.name = "Name"
      row.info = iSYDevice.modelName
      return row
    }, forKey: RowKey.ModelName)
    modelSection.addRow({
      let row = DetailLabelRow()
      row.name = "Number"
      row.info = iSYDevice.modelNumber
      return row
    }, forKey: RowKey.Number)
    modelSection.addRow({
      let row = DetailLabelRow()
      row.name = "Description"
      row.info = iSYDevice.modelDescription
      return row
    }, forKey: RowKey.Description)
    modelSection.addRow({
      let row = DetailLabelRow()
      row.name = "Friendly Name"
      row.info = iSYDevice.friendlyName
      return row
    }, forKey: RowKey.FriendlyName)

    sections[SectionKey.Model] = modelSection
}

/** loadManufacturerSection */
private func loadManufacturerSection() {

    let iSYDevice = model as! ISYDevice

    /// Manufacturer section: Name, URL
    ////////////////////////////////////////////////////////////////////////////////

    var manufacturerSection = DetailSection(section: 2, title: "Manufacturer")
    manufacturerSection.addRow({
      let row = DetailLabelRow()
      row.name = "Name"
      row.info = iSYDevice.manufacturer
      return row
    }, forKey: RowKey.ManufacturerName)
    manufacturerSection.addRow({
      let row = DetailLabelRow()
      row.name = "URL"
      row.info = iSYDevice.manufacturerURL
      return row
    }, forKey: RowKey.URL)

    sections[SectionKey.Manufacturer] = manufacturerSection
}

/** loadNodesSection */
private func loadNodesSection() {

    let iSYDevice = model as! ISYDevice

    /// Nodes section
    ////////////////////////////////////////////////////////////////////////////////

    var nodesSection = DetailSection(section: 3, title: "Nodes")
    for (idx, node) in sortedByName(iSYDevice.nodes).enumerate() {
      nodesSection.addRow({
        let row = DetailListRow()
        row.info = node
        return row
        }, forKey: "\(RowKey.Nodes)\(idx)")
    }

    sections[SectionKey.Nodes] = nodesSection
}

/** loadGroupsSection */
private func loadGroupsSection() {

    let iSYDevice = model as! ISYDevice

    /// Groups section
    ////////////////////////////////////////////////////////////////////////////////

    var groupsSection = DetailSection(section: 4, title: "Groups")
    for (idx, group) in sortedByName(iSYDevice.groups).enumerate() {
      groupsSection.addRow({
        let row = DetailListRow()
        row.info = group
        return row
        }, forKey: "\(RowKey.Groups)\(idx)")
    }

    sections[SectionKey.Groups] = groupsSection
}

/** loadComponentDevicesSection */
private func loadComponentDevicesSection() {

    let iSYDevice = model as! ISYDevice

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    var componentDevicesSection = DetailSection(section: 5, title: "Component Devices")
    for (idx, device) in sortedByName(iSYDevice.componentDevices).enumerate() {
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
