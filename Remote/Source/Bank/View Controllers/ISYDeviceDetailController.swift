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

class ISYDeviceDetailController: BankItemDetailController {

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is ISYDevice, "we should have been given an isy device")

    let iSYDevice = model as ISYDevice

    /// Identification section: Identifier, Base URL
    ////////////////////////////////////////////////////////////////////////////////

    var idSection = DetailSection(section: 0)
    idSection.addRow { DetailLabelRow(label: "Identifier", value: iSYDevice.uniqueIdentifier) }
    idSection.addRow { DetailLabelRow(label: "Base URL", value: iSYDevice.baseURL) }

    /// Model section: Name, Number, Description, Friendly Name
    ////////////////////////////////////////////////////////////////////////////////

    var modelSection = DetailSection(section: 1, title: "Model")
    modelSection.addRow { DetailLabelRow(label: "Name", value: iSYDevice.modelName) }
    modelSection.addRow { DetailLabelRow(label: "Number", value: iSYDevice.modelNumber) }
    modelSection.addRow { DetailLabelRow(label: "Description", value: iSYDevice.modelDescription) }
    modelSection.addRow { DetailLabelRow(label: "Friendly Name", value: iSYDevice.friendlyName) }


    /// Manufacturer section: Name, URL
    ////////////////////////////////////////////////////////////////////////////////

    var manufacturerSection = DetailSection(section: 2, title: "Manufacturer")
    manufacturerSection.addRow { DetailLabelRow(label: "Name", value: iSYDevice.manufacturer) }
    manufacturerSection.addRow { DetailLabelRow(label: "URL", value: iSYDevice.manufacturerURL) }

    /// Nodes section
    ////////////////////////////////////////////////////////////////////////////////

    var nodesSection = DetailSection(section: 3, title: "Nodes")
    for node in sortedByName(iSYDevice.nodes) { nodesSection.addRow { DetailListRow(namedItem: node) } }

    /// Groups section
    ////////////////////////////////////////////////////////////////////////////////

    var groupsSection = DetailSection(section: 4, title: "Groups")
    for group in sortedByName(iSYDevice.groups) { groupsSection.addRow { DetailListRow(namedItem: group) } }


    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    var componentDevicesSection = DetailSection(section: 5, title: "Component Devices")
    for device in sortedByName(iSYDevice.componentDevices?.allObjects as? [ComponentDevice] ?? []) {
      componentDevicesSection.addRow { DetailListRow(pushableItem: device) }
    }

    sections = ["ID": idSection,
                "Model": modelSection,
                "Manufacturer": manufacturerSection,
                "Nodes": nodesSection,
                "Groups": groupsSection,
                "Component Device": componentDevicesSection]

  }

}
