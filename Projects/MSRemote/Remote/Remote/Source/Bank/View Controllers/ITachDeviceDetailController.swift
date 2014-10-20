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

    /// Main section: Identifier, Make, Model, Config-URL, Revision, Pcb_PN, Pkg_Level, SDKClass
    ////////////////////////////////////////////////////////////////////////////////////////////

    let mainSection = BankItemDetailSection(sectionNumber: 0, createRows: {

			let uniqueIdentifierRow = BankItemDetailRow(label: "Identifier", value: self.iTachDevice.uniqueIdentifier)
			let makeRow = BankItemDetailRow(label: "Make", value: self.iTachDevice.make)
			let modelRow = BankItemDetailRow(label: "Model", value: self.iTachDevice.model)
			let configURLRow = BankItemDetailRow(label: "Config-URL", value: self.iTachDevice.configURL)
			let revisionRow = BankItemDetailRow(label: "Revision", value: self.iTachDevice.revision)
			let pcbPNRow = BankItemDetailRow(label: "Pcb_PN", value: self.iTachDevice.pcbPN)
			let pkgLevelRow = BankItemDetailRow(label: "Pkg_Level", value: self.iTachDevice.pkgLevel)
			let sDKClassRow = BankItemDetailRow(label: "SDKClass", value: self.iTachDevice.sdkClass)

			return [uniqueIdentifierRow, makeRow, modelRow, configURLRow, revisionRow, pcbPNRow, pkgLevelRow, sDKClassRow]

		})

    /// Component Devices section
    ////////////////////////////////////////////////////////////////////////////////

		let componentDevicesSection = BankItemDetailSection(sectionNumber: 1, title: "Component Devices", createRows: {
      return sortedByName(self.iTachDevice.componentDevices).map{BankItemDetailRow(pushableItem: $0)} ?? []
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
