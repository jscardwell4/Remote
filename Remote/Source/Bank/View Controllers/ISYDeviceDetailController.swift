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

	var devices: [ComponentDevice]? { return iSYDevice.componentDevices.allObjects as? [ComponentDevice] }
	var nodes:   [ISYDeviceNode]?   { return iSYDevice.nodes.allObjects            as? [ISYDeviceNode]   }
	var groups:  [ISYDeviceGroup]?  { return iSYDevice.groups.allObjects           as? [ISYDeviceGroup]  }

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is ISYDevice, "we should have been given an isy device")

    let uniqueIdentifierRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "Identifier"
    	$0.info = self.iSYDevice.uniqueIdentifier
    }
    let baseURLRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "Base URL"
    	$0.info = self.iSYDevice.baseURL
    }
    let modelNameRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "Name"
    	$0.info = self.iSYDevice.modelName
    }
    let modelNumberRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "Number"
    	$0.info = self.iSYDevice.modelNumber
    }
    let modelDescriptionRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "Description"
    	$0.info = self.iSYDevice.modelDescription
    }
    let friendlyNameRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "Friendly Name"
    	$0.info = self.iSYDevice.friendlyName
    }
    let manufacturerRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "Name"
    	$0.info = self.iSYDevice.manufacturer
    }
    let manufacturerURLRow = Row(identifier: .Label, isEditable: false) {[unowned self] in
    	$0.name = "URL"
    	$0.info = self.iSYDevice.manufacturerURL
    }
    let nodesRow            = Row(identifier: .Table, isEditable: false) {[unowned self] in $0.info = self.nodes   }
    let groupsRow           = Row(identifier: .Table, isEditable: false) {[unowned self] in $0.info = self.groups  }
    let componentDevicesRow = Row(identifier: .Table, isEditable: false) {[unowned self] in $0.info = self.devices }

    sections = [ Section(title: nil,                 rows: [uniqueIdentifierRow, baseURLRow]),
                 Section(title: "Model",             rows: [modelNameRow, modelNumberRow, modelDescriptionRow]),
                 Section(title: "Manufacturer",      rows: [manufacturerRow, manufacturerURLRow]),
                 Section(title: "Nodes",             rows: [nodesRow]),
                 Section(title: "Groups",            rows: [groupsRow]),
                 Section(title: "Component Devices", rows: [componentDevicesRow]) ]

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
