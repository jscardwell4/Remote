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

  var iTachDevice: ITachDevice { return model as ITachDevice }

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)
    precondition(model is ITachDevice, "we should have been given an itach device")

    /// Main section: Identifier, Make, Model, Config-URL, Revision, Pcb_PN, Pkg_Level, SDKClass
    ////////////////////////////////////////////////////////////////////////////////////////////

    let mainSection = DetailSection(sectionNumber: 0)

    mainSection.addRow { return DetailLabelRow(label: "Identifier", value: self.iTachDevice.uniqueIdentifier)}
    mainSection.addRow { return DetailLabelRow(label: "Make", value: self.iTachDevice.make)}
    mainSection.addRow { return DetailLabelRow(label: "Model", value: self.iTachDevice.model)}
    mainSection.addRow { return DetailLabelRow(label: "Config-URL", value: self.iTachDevice.configURL)}
    mainSection.addRow { return DetailLabelRow(label: "Revision", value: self.iTachDevice.revision)}
    mainSection.addRow { return DetailLabelRow(label: "Pcb_PN", value: self.iTachDevice.pcbPN)}
    mainSection.addRow { return DetailLabelRow(label: "Pkg_Level", value: self.iTachDevice.pkgLevel)}
    mainSection.addRow { return DetailLabelRow(label: "SDKClass", value: self.iTachDevice.sdkClass)}

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    let componentDevicesSection = DetailSection(sectionNumber: 1, title: "Component Devices")
    for device in sortedByName(self.iTachDevice.componentDevices) {
      componentDevicesSection.addRow { return DetailListRow(pushableItem: device) }
    }

    sections = [mainSection, componentDevicesSection]

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
