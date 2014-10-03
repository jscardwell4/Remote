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

	var componentDevices: [ComponentDevice]? { return iTachDevice.componentDevices.allObjects as? [ComponentDevice] }


  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init(item: BankDisplayItemModel, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is ITachDevice, "we should have been given an itach device")

		// section 0 - row 0: unique identifier
		let uniqueIdentifierRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "Identifier"
			$0.info = self.iTachDevice.uniqueIdentifier
		}

		// section 0 - row 1: make
		let makeRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "Make"
			$0.info = self.iTachDevice.make
		}

		// section 0 - row 2: model
		let modelRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "Model"
			$0.info = self.iTachDevice.model
		}

		// section 0 - row 3: config url
		let configURLRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "Config-URL"
			$0.info = self.iTachDevice.configURL
		}

		// section 0 - row 4: revision
		let revisionRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "Revision"
			$0.info = self.iTachDevice.revision
		}

		// section 0 - row 5: pcbpn
		let pcbPNRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "Pcb_PN"
			$0.info = self.iTachDevice.pcbPN
		}

		// section 0 - row 6: pkg level
		let pkgLevelRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "Pkg_Level"
			$0.info = self.iTachDevice.pkgLevel
		}

		// section 0 - row 7: sdk class
		let sDKClassRow = Row(identifier: .Label, isEditable: false){[unowned self] in
			$0.name = "SDKClass"
			$0.info = self.iTachDevice.sdkClass
		}

		// section 1 - row 0: component devices
		let componentDevicesRow = Row(identifier: .Table, isEditable: false){[unowned self] in $0.info = self.componentDevices}

		sections = [ Section(title: nil, rows: [uniqueIdentifierRow,
																						makeRow,
																						modelRow,
																						configURLRow,
																						revisionRow,
																						pcbPNRow,
																						pkgLevelRow,
																						sDKClassRow]),
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
  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

}
