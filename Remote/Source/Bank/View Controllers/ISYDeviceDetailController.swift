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

    let idSection = BankItemDetailSection(sectionNumber: 0, createRows: {

      let uniqueIdentifierRow = BankItemDetailRow(label: "Identifier", value: self.iSYDevice.uniqueIdentifier)
      let baseURLRow = BankItemDetailRow(label: "Base URL", value: self.iSYDevice.baseURL)

      return [uniqueIdentifierRow, baseURLRow]
    })

    /// Model section: Name, Number, Description, Friendly Name
    ////////////////////////////////////////////////////////////////////////////////

    let modelSection = BankItemDetailSection(sectionNumber: 1, title: "Model", createRows: {

      let modelNameRow = BankItemDetailRow(label: "Name", value: self.iSYDevice.modelName)
      let modelNumberRow = BankItemDetailRow(label: "Number", value: self.iSYDevice.modelNumber)
      let modelDescriptionRow = BankItemDetailRow(label: "Description", value: self.iSYDevice.modelDescription)
      let friendlyNameRow = BankItemDetailRow(label: "Friendly Name", value: self.iSYDevice.friendlyName)

      return [modelNameRow, modelNumberRow, modelDescriptionRow, friendlyNameRow]
    })

    /// Manufacturer section: Name, URL
    ////////////////////////////////////////////////////////////////////////////////

    let manufacturerSection = BankItemDetailSection(sectionNumber: 2, title: "Manufacturer", createRows: {

      let manufacturerRow = BankItemDetailRow(label: "Name", value: self.iSYDevice.manufacturer)
      let manufacturerURLRow = BankItemDetailRow(label: "URL", value: self.iSYDevice.manufacturerURL)

      return [manufacturerRow, manufacturerURLRow]
    })

    /// Nodes section
    ////////////////////////////////////////////////////////////////////////////////

    let nodesSection = BankItemDetailSection(sectionNumber: 3, title: "Nodes", createRows: {
      return sortedByName(self.iSYDevice.nodes).map{BankItemDetailRow(namedItem: $0)} ?? []
    })

    /// Groups section
    ////////////////////////////////////////////////////////////////////////////////

    let groupsSection = BankItemDetailSection(sectionNumber: 4, title: "Groups", createRows: {
      return sortedByName(self.iSYDevice.groups).map{BankItemDetailRow(namedItem: $0)} ?? []
    })

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

    let componentDevicesSection = BankItemDetailSection(sectionNumber: 5, title: "Component Devices", createRows: {
      return sortedByName(self.iSYDevice.componentDevices).map{BankItemDetailRow(pushableItem: $0)} ?? []
    })

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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
