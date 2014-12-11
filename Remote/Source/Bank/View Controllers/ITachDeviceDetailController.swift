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

class ITachDeviceDetailController: BankItemDetailController {

  /** loadSections() */
  override func loadSections() {
    super.loadSections()

    precondition(model is ITachDevice, "we should have been given an itach device")

    /// Main section: Identifier, Make, Model, Config-URL, Revision, Pcb_PN, Pkg_Level, SDKClass
    ////////////////////////////////////////////////////////////////////////////////////////////

    let iTachDevice = model as ITachDevice

    let mainSection = DetailSection(section: 0)

    mainSection.addRow { DetailLabelRow(label: "Identifier", value: iTachDevice.uniqueIdentifier)}
    mainSection.addRow { DetailLabelRow(label: "Make", value: iTachDevice.make)}
    mainSection.addRow { DetailLabelRow(label: "Model", value: iTachDevice.model)}
    mainSection.addRow { DetailLabelRow(label: "Config-URL", value: iTachDevice.configURL)}
    mainSection.addRow { DetailLabelRow(label: "Revision", value: iTachDevice.revision)}
    mainSection.addRow { DetailLabelRow(label: "Pcb_PN", value: iTachDevice.pcbPN)}
    mainSection.addRow { DetailLabelRow(label: "Pkg_Level", value: iTachDevice.pkgLevel)}
    mainSection.addRow { DetailLabelRow(label: "SDKClass", value: iTachDevice.sdkClass)}

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    let componentDevicesSection = DetailSection(section: 1, title: "Component Devices")
    for device in sortedByName(iTachDevice.componentDevices?.allObjects as? [ComponentDevice] ?? []) {
      componentDevicesSection.addRow { DetailListRow(pushableItem: device) }
    }

    sections = ["Main": mainSection, "Component Devices": componentDevicesSection]

  }

}
