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

  var iSYDevice: ISYDevice { return model as ISYDevice }

  /**
  initWithItem:editing:

  :param: model BankableModelObject
  :param: editing Bool
  */
  override init(model: BankableModelObject) {
    super.init(model: model)
    precondition(model is ISYDevice, "we should have been given an isy device")

    /// Identification section: Identifier, Base URL
    ////////////////////////////////////////////////////////////////////////////////

    var idSection = DetailSection(section: 0)
    idSection.addRow { return DetailLabelRow(label: "Identifier", value: self.iSYDevice.uniqueIdentifier) }
    idSection.addRow { return DetailLabelRow(label: "Base URL", value: self.iSYDevice.baseURL) }

    /// Model section: Name, Number, Description, Friendly Name
    ////////////////////////////////////////////////////////////////////////////////

    var modelSection = DetailSection(section: 1, title: "Model")
    modelSection.addRow { return DetailLabelRow(label: "Name", value: self.iSYDevice.modelName) }
    modelSection.addRow { return DetailLabelRow(label: "Number", value: self.iSYDevice.modelNumber) }
    modelSection.addRow { return DetailLabelRow(label: "Description", value: self.iSYDevice.modelDescription) }
    modelSection.addRow { return DetailLabelRow(label: "Friendly Name", value: self.iSYDevice.friendlyName) }


    /// Manufacturer section: Name, URL
    ////////////////////////////////////////////////////////////////////////////////

    var manufacturerSection = DetailSection(section: 2, title: "Manufacturer")
    manufacturerSection.addRow { return DetailLabelRow(label: "Name", value: self.iSYDevice.manufacturer) }
    manufacturerSection.addRow { return DetailLabelRow(label: "URL", value: self.iSYDevice.manufacturerURL) }

    /// Nodes section
    ////////////////////////////////////////////////////////////////////////////////

    var nodesSection = DetailSection(section: 3, title: "Nodes")
    for node in sortedByName(self.iSYDevice.nodes) {
      nodesSection.addRow { return DetailListRow(namedItem: node) }
    }

    /// Groups section
    ////////////////////////////////////////////////////////////////////////////////

    var groupsSection = DetailSection(section: 4, title: "Groups")
    for group in sortedByName(self.iSYDevice.groups) {
      groupsSection.addRow { return DetailListRow(namedItem: group) }
    }


    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    var componentDevicesSection = DetailSection(section: 5, title: "Component Devices")
    for device in sortedByName(self.iSYDevice.componentDevices?.allObjects as? [ComponentDevice] ?? []) {
      componentDevicesSection.addRow { return DetailListRow(pushableItem: device) }
    }

    sections = [idSection, modelSection, manufacturerSection, nodesSection, groupsSection, componentDevicesSection]

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
