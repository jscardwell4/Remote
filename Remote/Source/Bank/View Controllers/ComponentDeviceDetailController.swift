//
//  ComponentDeviceDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import UIKit

@objc(ComponentDeviceDetailController)
class ComponentDeviceDetailController: BankItemDetailController {

  var componentDevice: ComponentDevice { return item as ComponentDevice }

  var codes: [IRCode]?

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is ComponentDevice, "we should have been given a component device")

    codes = (componentDevice.codeSet?.codes?.allObjects as? [IRCode])?.sorted{$0.0.name < $0.1.name}

    // section 0 - row 0: manufacturer
    let manufacturerRow = Row(identifier: .TextField, isEditable: true,
      selectionHandler: {
        if let manufacturer = self.componentDevice.manufacturer {
          self.navigationController?.pushViewController(manufacturer.detailController(), animated: true)
        }
      },
      configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Manufacturer"
          cell.pickerNilSelectionTitle = "No Manufacturer"
          cell.pickerSelectionHandler = { self.componentDevice.manufacturer = $0 as? Manufacturer }
          cell.pickerData = Manufacturer.findAllSortedBy("name", ascending: true) as? [Manufacturer]
          cell.pickerSelection = self.componentDevice.manufacturer
    })

    // section 0 - row 1: code set
    // TODO: Add ability to change the code set used by a component device
    let codeSetRow = Row(identifier: .Button,
      selectionHandler: {
        let controller = BankCollectionController(category: self.componentDevice.codeSet!)
        self.navigationController?.pushViewController(controller!, animated: true)
      },
      configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Code Set"
          cell.pickerNilSelectionTitle = "No Code Set"
          cell.pickerSelection = self.componentDevice.codeSet
          cell.pickerData = (self.componentDevice.manufacturer?.codeSets.allObjects as? [IRCodeSet])?.sorted{$0.0.name < $0.1.name}
    })

    // section 1 - row 0: network device
    let networkDeviceRow = Row(identifier: .Button, isEditable: true,
      selectionHandler: {
        if let networkDevice = self.componentDevice.networkDevice {
          self.navigationController?.pushViewController(networkDevice.detailController(), animated: true)
        }
      },
      configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Network Device"
          cell.info = self.componentDevice.networkDevice
          cell.pickerNilSelectionTitle = "No Network Device"
          cell.pickerSelectionHandler = {self.componentDevice.networkDevice = $0 as? NetworkDevice }
          cell.pickerData = NetworkDevice.findAllSortedBy("name", ascending: true) as? [NetworkDevice]
          cell.pickerSelection = self.componentDevice.networkDevice
    })

    // section 1 - row 1: port
    let portRow = Row(identifier: .Stepper, isEditable: true, configureCell: {
      (cell: BankItemCell) -> Void in
        cell.name = "Port"
        cell.info = Int(self.componentDevice.port)
        cell.stepperMinValue = 1
        cell.stepperMaxValue = 3
        cell.stepperWraps = true
        cell.changeHandler = { if let n = $0 as? NSNumber { self.componentDevice.port = n.shortValue } }
    })

    // TODO: Add button action handlers to allow setting of power on/off commands

    // section 2 - row 0: power on
    let powerOnRow = Row(identifier: .Button, isEditable: true, configureCell: {
      (cell: BankItemCell) -> Void in
        cell.name = "On"
        cell.info = self.componentDevice.onCommand
        cell.pickerNilSelectionTitle = "No On Command"
        cell.pickerSelection = self.componentDevice.onCommand?.code
        cell.pickerSelectionHandler = { if let code = $0 as? IRCode { self.componentDevice.onCommand?.code = code } }
        cell.pickerData = self.codes
    })

    // section 2 - row 1: power off
    let powerOffRow = Row(identifier: .Button, isEditable: true, configureCell: {
      (cell: BankItemCell) -> Void in
        cell.name = "Off"
        cell.info = self.componentDevice.offCommand
        cell.pickerNilSelectionTitle = "No Off Command"
        cell.pickerSelection = self.componentDevice.offCommand?.code
        cell.pickerSelectionHandler = { if let code = $0 as? IRCode { self.componentDevice.offCommand?.code = code } }
        cell.pickerData = self.codes
    })

    // section 3 - row 0: input powers on
    let inputPowersOnRow = Row(identifier: .Switch, isEditable: true, configureCell: {
      (cell: BankItemCell) -> Void in
        cell.name = "Inputs Power On Device"
        cell.info = self.componentDevice.inputPowersOn
        cell.changeHandler = { self.componentDevice.inputPowersOn = $0 as Bool }
    })

    // section 3 - row 1: inputs
    let inputsRow = Row(identifier: .Table, isEditable: true, height: 14.0, configureCell: { cell in})

    sections = [ Section(title: nil,              rows: [manufacturerRow, codeSetRow]),
                 Section(title: "Network Device", rows: [networkDeviceRow, portRow]),
                 Section(title: "Power",          rows: [powerOnRow, powerOffRow]),
                 Section(title: "Inputs",         rows: [inputPowersOnRow, inputsRow]) ]
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

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
  viewIRCodes
  */
  func viewIRCodes() {
    //TODO: Fill out stub
  }

}
