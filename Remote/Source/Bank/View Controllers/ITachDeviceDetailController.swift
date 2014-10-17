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

	var iTachDevice: ITachDevice { return item as ITachDevice }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is ITachDevice, "we should have been given an itach device")

    let mainSection = BankItemDetailSection(sectionNumber: 0, createRows: {

			let uniqueIdentifierRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "Identifier"
					cell.info = self.iTachDevice.uniqueIdentifier
			})

			let makeRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "Make"
					cell.info = self.iTachDevice.make
			})

			let modelRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "Model"
					cell.info = self.iTachDevice.model
			})

			let configURLRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "Config-URL"
					cell.info = self.iTachDevice.configURL
			})

			let revisionRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "Revision"
					cell.info = self.iTachDevice.revision
			})

			let pcbPNRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "Pcb_PN"
					cell.info = self.iTachDevice.pcbPN
			})

			let pkgLevelRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "Pkg_Level"
					cell.info = self.iTachDevice.pkgLevel
			})

			let sDKClassRow = BankItemDetailRow(identifier: .Label, configureCell:{
				(cell: BankItemCell) -> Void in
					cell.name = "SDKClass"
					cell.info = self.iTachDevice.sdkClass
			})

			return [uniqueIdentifierRow, makeRow, modelRow, configURLRow, revisionRow, pcbPNRow, pkgLevelRow, sDKClassRow]

		})

		let componentDevicesSection = BankItemDetailSection(sectionNumber: 1, title: "Component Devices", createRows: {
			var rows: [BankItemDetailRow] = []
			if let devices = sortedByName(self.iTachDevice.componentDevices.allObjects as? [ComponentDevice]) {
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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
