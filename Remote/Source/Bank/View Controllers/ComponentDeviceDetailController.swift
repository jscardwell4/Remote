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

  lazy var manufacturers: [Manufacturer] = Manufacturer.findAllSortedBy("name", ascending: true) as? [Manufacturer] ?? []

  lazy var networkDevices: [NetworkDevice] = NetworkDevice.findAllSortedBy("name", ascending: true) as? [NetworkDevice] ?? []

  /**
  initWithItem:editing:

  :param: item BankableModelObject
  :param: editing Bool
  */
  required init?(item: BankDisplayItemModel, editing: Bool) {
    super.init(item: item, editing: editing)
    precondition(item is ComponentDevice, "we should have been given a component device")

    // section 0 - row 0: manufacturer
    let manufacturerRow = Row(identifier: .TextField, isEditable: true, configureCell: {
      $0.name = "Manufacturer"
      $0.info = self.componentDevice.manufacturer
      $0.pickerNilSelectionTitle = "No Manufacturer"
      $0.pickerSelectionHandler = { self.componentDevice.manufacturer = $0 as? Manufacturer }
      $0.pickerData = self.manufacturers
      $0.pickerSelection = self.componentDevice.manufacturer
    })

    // section 0 - row 1: all codes
    // TODO: Add ability to change the code set used by a component device
    let allCodesRow = Row(identifier: .Button, isEditable: false, configureCell: {
      $0.info = "Device Codes"
      let viewCodes = self.viewIRCodes
      $0.buttonActionHandler = {_ in viewCodes()}
    })

    // section 1 - row 0: network device
    let networkDeviceRow = Row(identifier: .Button, isEditable: false, configureCell: {
      $0.name = "Network Device"
      $0.info = self.componentDevice.networkDevice
      $0.pickerNilSelectionTitle = "No Network Device"
      $0.pickerSelectionHandler = {self.componentDevice.networkDevice = $0 as? NetworkDevice }
      $0.pickerData = self.networkDevices
      $0.pickerSelection = self.componentDevice.networkDevice
    })

    // section 1 - row 1: port
    let portRow = Row(identifier: .Stepper, isEditable: true, configureCell: {
      $0.name = "Port"
      $0.info = Int(self.componentDevice.port)
      $0.stepperMinValue = 1
      $0.stepperMaxValue = 3
      $0.stepperWraps = true
      $0.changeHandler = {[unowned self] c in if let n = c.info as? NSNumber { self.componentDevice.port = n.shortValue } }
    })

    // TODO: Add button action handlers to allow setting of power on/off commands

    // section 2 - row 0: power on
    let powerOnRow = Row(identifier: .Button, isEditable: true, configureCell: {
      $0.name = "On"
      $0.info = self.componentDevice.onCommand ?? "No On Command"
    })

    // section 2 - row 1: power off
    let powerOffRow = Row(identifier: .Button, isEditable: true, configureCell: {
      $0.name = "Off"
      $0.info = self.componentDevice.offCommand ?? "No Off Command"
    })

    // section 3 - row 0: input powers on
    let inputPowersOnRow = Row(identifier: .Switch, isEditable: true, configureCell: {
      $0.name = "Inputs Power On Device"
      $0.info = self.componentDevice.inputPowersOn
      $0.changeHandler = {[unowned self] c in self.componentDevice.inputPowersOn = c.info as Bool }
    })

    // section 3 - row 1: inputs
    let inputsRow = Row(identifier: .Table, isEditable: true,
      height: CGFloat(inputs.count) * BankItemDetailController.defaultRowHeight + 14.0,
      configureCell: { $0.info = self.inputs })

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
  override init?(style: UITableViewStyle) { super.init(style: style) }

  /**
  viewIRCodes
  */
  func viewIRCodes() {
    //TODO: Fill out stub
  }

}
