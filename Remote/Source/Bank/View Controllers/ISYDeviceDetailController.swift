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

  var iSYDevice: ISYDevice { return item as ISYDevice }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is ISYDevice, "we should have been given an isy device")

    /// Identification section: Identifier, Base URL
    ////////////////////////////////////////////////////////////////////////////////

    let idSection = BankItemDetailSection(sectionNumber: 0)
    idSection.addRow { return BankItemDetailLabelRow(label: "Identifier", value: self.iSYDevice.uniqueIdentifier) }
    idSection.addRow { return BankItemDetailLabelRow(label: "Base URL", value: self.iSYDevice.baseURL) }

    /// Model section: Name, Number, Description, Friendly Name
    ////////////////////////////////////////////////////////////////////////////////

    let modelSection = BankItemDetailSection(sectionNumber: 1, title: "Model")
    modelSection.addRow { return BankItemDetailLabelRow(label: "Name", value: self.iSYDevice.modelName) }
    modelSection.addRow { return BankItemDetailLabelRow(label: "Number", value: self.iSYDevice.modelNumber) }
    modelSection.addRow { return BankItemDetailLabelRow(label: "Description", value: self.iSYDevice.modelDescription) }
    modelSection.addRow { return BankItemDetailLabelRow(label: "Friendly Name", value: self.iSYDevice.friendlyName) }


    /// Manufacturer section: Name, URL
    ////////////////////////////////////////////////////////////////////////////////

    let manufacturerSection = BankItemDetailSection(sectionNumber: 2, title: "Manufacturer")
    manufacturerSection.addRow { return BankItemDetailLabelRow(label: "Name", value: self.iSYDevice.manufacturer) }
    manufacturerSection.addRow { return BankItemDetailLabelRow(label: "URL", value: self.iSYDevice.manufacturerURL) }

    /// Nodes section
    ////////////////////////////////////////////////////////////////////////////////

    let nodesSection = BankItemDetailSection(sectionNumber: 3, title: "Nodes")
    for node in sortedByName(self.iSYDevice.nodes) {
      nodesSection.addRow { return BankItemDetailListRow(namedItem: node) }
    }

    /// Groups section
    ////////////////////////////////////////////////////////////////////////////////

    let groupsSection = BankItemDetailSection(sectionNumber: 4, title: "Groups")
    for group in sortedByName(self.iSYDevice.groups) {
      groupsSection.addRow { return BankItemDetailListRow(namedItem: group) }
    }


    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    let componentDevicesSection = BankItemDetailSection(sectionNumber: 5, title: "Component Devices")
    for device in sortedByName(self.iSYDevice.componentDevices) {
      componentDevicesSection.addRow { return BankItemDetailListRow(pushableItem: device) }
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
