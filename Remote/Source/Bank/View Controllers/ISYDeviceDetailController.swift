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

    let idSection = BankItemDetailSection(sectionNumber: 0, createRows: {

      let uniqueIdentifierRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
        	cell.name = "Identifier"
        	cell.info = self.iSYDevice.uniqueIdentifier
      })

      let baseURLRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
        	cell.name = "Base URL"
        	cell.info = self.iSYDevice.baseURL
      })

      return [uniqueIdentifierRow, baseURLRow]
    })

    let modelSection = BankItemDetailSection(sectionNumber: 1, title: "Model", createRows: {

      let modelNameRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
        	cell.name = "Name"
        	cell.info = self.iSYDevice.modelName
      })

      let modelNumberRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
        	cell.name = "Number"
        	cell.info = self.iSYDevice.modelNumber
      })

      let modelDescriptionRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
        	cell.name = "Description"
        	cell.info = self.iSYDevice.modelDescription
      })

      let friendlyNameRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Friendly Name"
          cell.info = self.iSYDevice.friendlyName
      })

      return [modelNameRow, modelNumberRow, modelDescriptionRow, friendlyNameRow]
    })

    let manufacturerSection = BankItemDetailSection(sectionNumber: 2, title: "Manufacturer", createRows: {

      let manufacturerRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
        	cell.name = "Name"
        	cell.info = self.iSYDevice.manufacturer
      })

      let manufacturerURLRow = BankItemDetailRow(identifier: .Label, configureCell: {
        (cell: BankItemCell) -> Void in
        	cell.name = "URL"
        	cell.info = self.iSYDevice.manufacturerURL
      })

      return [manufacturerRow, manufacturerURLRow]
    })

    let nodesSection = BankItemDetailSection(sectionNumber: 3, title: "Nodes", createRows: {
      var rows: [BankItemDetailRow] = []
      if let nodes = sortedByName(self.iSYDevice.nodes.allObjects as? [ISYDeviceNode]) {
        for node in nodes {
          let nodeRow = BankItemDetailRow(identifier: .List, configureCell: {
            (cell: BankItemCell) -> Void in
              cell.info = node
          })
          rows.append(nodeRow)
        }
      }
      return rows
    })

    let groupsSection = BankItemDetailSection(sectionNumber: 4, title: "Groups", createRows: {
      var rows: [BankItemDetailRow] = []
      if let groups = sortedByName(self.iSYDevice.groups.allObjects as? [ISYDeviceGroup]) {
        for group in groups {
          let groupRow = BankItemDetailRow(identifier: .List, configureCell: {
            (cell: BankItemCell) -> Void in
              cell.info = group
          })
          rows.append(groupRow)
        }
      }
      return rows
    })

    let componentDevicesSection = BankItemDetailSection(sectionNumber: 5, title: "Component Devices", createRows: {
      var rows: [BankItemDetailRow] = []
      if let devices = sortedByName(self.iSYDevice.componentDevices.allObjects as? [ComponentDevice]) {
        for device in devices {
          let deviceRow = BankItemDetailRow(identifier: .List, configureCell: {
            (cell: BankItemCell) -> Void in
              cell.info = device
          })
          rows.append(deviceRow)
        }
      }
      return rows
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
