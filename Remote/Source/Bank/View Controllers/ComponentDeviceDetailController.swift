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

  var inputs: [AnyObject] = []

  lazy var manufacturers: [Manufacturer] = {
    var manufacturers: [Manufacturer] = []
    if let fetchedManufacturers = Manufacturer.findAllSortedBy("name", ascending: true) as? [Manufacturer] {
      manufacturers += fetchedManufacturers
    }
    return manufacturers
    }()

  lazy var networkDevices: [NetworkDevice] = {
    var networkDevices: [NetworkDevice] = []
    if let fetchedNetworkDevices = NetworkDevice.findAllSortedBy("name", ascending: true) as? [NetworkDevice] {
      networkDevices += fetchedNetworkDevices
    }
    return networkDevices
    }()

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init(item: BankableModelObject, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is ComponentDevice, "we should have been given a component device")

    // section 0 - row 0: manufacturer
    let manufacturerRow = Row(identifier: BankItemCellTextFieldStyleIdentifier, isEditable: true) { [unowned self] in
      $0.name = "Manufacturer"
      $0.info = self.componentDevice.manufacturer ?? "No Manufacturer"
      $0.pickerSelectionHandler = {[unowned self] cell in
        if let selection = cell.pickerSelection as? Manufacturer { self.componentDevice.manufacturer = selection }
        else { self.componentDevice.manufacturer = nil }
      }
      $0.pickerData = self.manufacturers
      $0.pickerSelection = self.componentDevice.manufacturer
    }

    // section 0 - row 1: all codes
    let allCodesRow = Row(identifier: BankItemCellDetailStyleIdentifier, isEditable: false) {[unowned self] in
      $0.info = "Device Codes"
      let viewCodes = self.viewIRCodes
      $0.buttonActionHandler = {cell in viewCodes()}
    }

    // section 1 - row 0: network device
    let networkDeviceRow = Row(identifier: BankItemCellButtonStyleIdentifier, isEditable: false) {[unowned self] in
      $0.name = "Network Device"
      $0.info = self.componentDevice.networkDevice ?? "No Network Device"
      $0.pickerSelectionHandler = {[unowned self] cell in
        if let selection = cell.pickerSelection as? NetworkDevice { self.componentDevice.networkDevice = selection }
        else { self.componentDevice.networkDevice = nil }
      }
      $0.pickerData = self.networkDevices
      $0.pickerSelection = self.componentDevice.networkDevice
    }

    // section 1 - row 1: port
    let portRow = Row(identifier: BankItemCellStepperStyleIdentifier, isEditable: true) { [unowned self] in
      $0.name = "Port"
      $0.info = Int(self.componentDevice.port)
      $0.stepperMinValue = 1
      $0.stepperMaxValue = 3
      $0.stepperWraps = true
      $0.changeHandler = {[unowned self] cell in self.componentDevice.port = cell.info.shortValue}
    }

    // section 2 - row 0: power on
    let powerOnRow = Row(identifier: BankItemCellButtonStyleIdentifier, isEditable: true) { [unowned self] in
      $0.name = "On"
      $0.info = self.componentDevice.onCommand ?? "No On Command"
    }

    // section 2 - row 1: power off
    let powerOffRow = Row(identifier: BankItemCellButtonStyleIdentifier, isEditable: true) { [unowned self] in
      $0.name = "Off"
      $0.info = self.componentDevice.offCommand ?? "No Off Command"
    }

    // section 3 - row 0: input powers on
    let inputPowersOnRow = Row(identifier: BankItemCellSwitchStyleIdentifier, isEditable: true) { [unowned self] in
      $0.name = "Inputs Power On Device"
      $0.info = self.componentDevice.inputPowersOn
      $0.changeHandler = {[unowned self] cell in self.componentDevice.inputPowersOn = cell.info as Bool }
    }

    // section 3 - row 1: inputs
    let inputsRow = Row(identifier: BankItemCellTableStyleIdentifier, isEditable: true) { [unowned self] in
      $0.info = self.inputs
    }

    sections = [ Section(title: nil,              rows: [manufacturerRow, allCodesRow]),
                 Section(title: "Network Device", rows: [networkDeviceRow, portRow]),
                 Section(title: "Power Commands", rows: [powerOnRow, powerOffRow]),
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
  override init(style: UITableViewStyle) { super.init(style: style) }
  
  /**
  viewIRCodes
  */
  func viewIRCodes() {
    //TODO: Fill out stub
  }

}
