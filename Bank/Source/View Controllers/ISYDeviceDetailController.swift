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
    idSection.addRow({ DetailLabelRow(label: "Identifier", value: iSYDevice.uniqueIdentifier) }, forKey: RowKey.Identifier)
    idSection.addRow({ DetailLabelRow(label: "Base URL", value: iSYDevice.baseURL) }, forKey: RowKey.BaseURL)

    sections[SectionKey.ID] = idSection
}

/** loadModelSection */
private func loadModelSection() {

    let iSYDevice = model as! ISYDevice

    /// Model section: Name, Number, Description, Friendly Name
    ////////////////////////////////////////////////////////////////////////////////

    var modelSection = DetailSection(section: 1, title: "Model")
    modelSection.addRow({ DetailLabelRow(label: "Name", value: iSYDevice.modelName) }, forKey: RowKey.ModelName)
    modelSection.addRow({ DetailLabelRow(label: "Number", value: iSYDevice.modelNumber) }, forKey: RowKey.Number)
    modelSection.addRow({ DetailLabelRow(label: "Description", value: iSYDevice.modelDescription) }, forKey: RowKey.Description)
    modelSection.addRow({ DetailLabelRow(label: "Friendly Name", value: iSYDevice.friendlyName) }, forKey: RowKey.FriendlyName)

    sections[SectionKey.Model] = modelSection
}

/** loadManufacturerSection */
private func loadManufacturerSection() {

    let iSYDevice = model as! ISYDevice

    /// Manufacturer section: Name, URL
    ////////////////////////////////////////////////////////////////////////////////

    var manufacturerSection = DetailSection(section: 2, title: "Manufacturer")
    manufacturerSection.addRow({ DetailLabelRow(label: "Name", value: iSYDevice.manufacturer) }, forKey: RowKey.ManufacturerName)
    manufacturerSection.addRow({ DetailLabelRow(label: "URL", value: iSYDevice.manufacturerURL) }, forKey: RowKey.URL)

    sections[SectionKey.Manufacturer] = manufacturerSection
}

/** loadNodesSection */
private func loadNodesSection() {

    let iSYDevice = model as! ISYDevice

    /// Nodes section
    ////////////////////////////////////////////////////////////////////////////////

    var nodesSection = DetailSection(section: 3, title: "Nodes")
    for (idx, node) in enumerate(sortedByName(iSYDevice.nodes)) { nodesSection.addRow({ DetailListRow(namedItem: node) }, forKey: "\(RowKey.Nodes)\(idx)") }

    sections[SectionKey.Nodes] = nodesSection
}

/** loadGroupsSection */
private func loadGroupsSection() {

    let iSYDevice = model as! ISYDevice

    /// Groups section
    ////////////////////////////////////////////////////////////////////////////////

    var groupsSection = DetailSection(section: 4, title: "Groups")
    for (idx, group) in enumerate(sortedByName(iSYDevice.groups)) { groupsSection.addRow({ DetailListRow(namedItem: group) }, forKey: "\(RowKey.Groups)\(idx)") }

    sections[SectionKey.Groups] = groupsSection
}

/** loadComponentDevicesSection */
private func loadComponentDevicesSection() {

    let iSYDevice = model as! ISYDevice

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    var componentDevicesSection = DetailSection(section: 5, title: "Component Devices")
    for (idx, device) in enumerate(sortedByName(iSYDevice.componentDevices)) {
      componentDevicesSection.addRow({ DetailListRow(pushableItem: device) }, forKey: "\(RowKey.ComponentDevices)\(idx)")
    }

    sections[SectionKey.ComponentDevices] = componentDevicesSection

  }

}
