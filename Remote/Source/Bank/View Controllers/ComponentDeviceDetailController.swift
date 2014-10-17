//
//  ComponentDeviceDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 9/26/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ComponentDeviceDetailController: BankItemDetailController {

  var componentDevice: ComponentDevice { return item as ComponentDevice }
  var codes: [IRCode]? { didSet { sortByName(&codes) } }
  var codeSets: [IRCodeSet]? { didSet { sortByName(&codeSets) } }
  var manufacturers: [Manufacturer]? { didSet { sortByName(&manufacturers) } }
  var networkDevices: [NetworkDevice]? { didSet { sortByName(&networkDevices) } }


  /**
  initWithItem:editing:

  :param: item BankableModelObject
  */
  required init?(item: BankDisplayItemModel) {
    super.init(item: item)
    precondition(item is ComponentDevice, "we should have been given a component device")

    codes = componentDevice.codeSet?.codes?.allObjects as? [IRCode]
    codeSets = componentDevice.manufacturer?.codeSets
    manufacturers = Manufacturer.findAllInContext(componentDevice.managedObjectContext!) as? [Manufacturer]
    networkDevices = NetworkDevice.findAllInContext(componentDevice.managedObjectContext!) as? [NetworkDevice]

    /// Manufacturer
    ////////////////////////////////////////////////////////////////////////////////

    let manufacturerSection = BankItemDetailSection(sectionNumber: 0, createRows: {
      let manufacturerRow = BankItemDetailRow(identifier: .Button, isEditable: true,
        selectionHandler: {
          if let manufacturer = self.componentDevice.manufacturer {
            self.navigationController?.pushViewController(manufacturer.detailController(), animated: true)
          }
        },
        configureCell: {
          (cell: BankItemCell) -> Void in
          cell.name = "Manufacturer"
          cell.pickerNilSelectionTitle = "No Manufacturer"
          cell.pickerCreateSelectionTitle = "⨁ New Manufacturer"
          cell.pickerSelectionHandler = {
            self.componentDevice.manufacturer = $0 as? Manufacturer
            self.tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
          }
          cell.pickerCreateSelectionHandler = {
            let alert = UIAlertController(title: "Create Manufacturer",
              message: "Enter a name for the manufacturer",
              preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler {
              $0.font = Bank.infoFont
              $0.textColor = Bank.infoColor
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
              action in
              cell.pickerSelection = self.componentDevice.manufacturer
              // re-select previous picker selection and dismiss picker
              self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Create", style: .Default) {
              action in
              if let text = (alert.textFields?.first as? UITextField)?.text {
                let moc = self.componentDevice.managedObjectContext!
                moc.performBlockAndWait {
                  let manufacturer = Manufacturer.createInContext(moc)
                  manufacturer.name = text
                  self.componentDevice.manufacturer = manufacturer
                  dispatch_async(dispatch_get_main_queue()) {
                    if self.manufacturers != nil {
                      self.manufacturers!.append(manufacturer)
                      self.manufacturers!.sort{$0.0.name < $0.1.name}
                    } else {
                      self.manufacturers = [manufacturer]
                    }
                    cell.pickerData = self.manufacturers
                    self.tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                  }
                }
              }
              self.dismissViewControllerAnimated(true, completion: nil)
              })

            self.presentViewController(alert, animated: true, completion: nil)
          }
          cell.pickerData = self.manufacturers
          cell.pickerSelection = self.componentDevice.manufacturer
      })
      let codeSetRow = BankItemDetailRow(identifier: .Button, isEditable: true,
        selectionHandler: {
          let controller = BankCollectionController(category: self.componentDevice.codeSet!)
          self.navigationController?.pushViewController(controller!, animated: true)
        },
        configureCell: {
          (cell: BankItemCell) -> Void in
          cell.name = "Code Set"
          cell.pickerNilSelectionTitle = "No Code Set"
          cell.pickerCreateSelectionTitle = "⨁ New Code Set"
          cell.pickerSelectionHandler = {
            self.componentDevice.codeSet = $0 as? IRCodeSet
            self.tableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
          }
          cell.pickerCreateSelectionHandler = {
            let alert = UIAlertController(title: "Create Code Set",
              message: "Enter a name for the code set",
              preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler {
              $0.font = Bank.infoFont
              $0.textColor = Bank.infoColor
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
              action in
              cell.pickerSelection = self.componentDevice.codeSet
              // re-select previous picker selection and dismiss picker
              self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Create", style: .Default) {
              action in
              if let text = (alert.textFields?.first as? UITextField)?.text {
                let moc = self.componentDevice.managedObjectContext!
                moc.performBlockAndWait {
                  let codeSet = IRCodeSet.createInContext(moc)
                  codeSet.name = text
                  codeSet.manufacturer = self.componentDevice.manufacturer
                  self.componentDevice.codeSet = codeSet
                  dispatch_async(dispatch_get_main_queue()) {
                    if self.codeSets != nil {
                      self.codeSets!.append(codeSet)
                      self.codeSets!.sort{$0.0.name < $0.1.name}
                    } else {
                      self.codeSets = [codeSet]
                    }
                    cell.pickerData = self.codeSets
                  }
                }
              }
              self.dismissViewControllerAnimated(true, completion: nil)
              })

            self.presentViewController(alert, animated: true, completion: nil)
          }
          cell.pickerSelection = self.componentDevice.codeSet
          cell.pickerData = self.codeSets
      })
      return [manufacturerRow, codeSetRow]
    })

    /// Network Device
    ////////////////////////////////////////////////////////////////////////////////

    let networkDeviceSection = BankItemDetailSection(sectionNumber: 1, title: "Network Device", createRows: {
      let networkDeviceRow = BankItemDetailRow(identifier: .Button, isEditable: true,
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
            //cell.pickerCreateSelectionTitle = "⨁ New Network Device"
            cell.pickerSelectionHandler = {self.componentDevice.networkDevice = $0 as? NetworkDevice }
            cell.pickerData = self.networkDevices
            cell.pickerSelection = self.componentDevice.networkDevice
      })
      let portRow = BankItemDetailRow(identifier: .Stepper, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Port"
          cell.info = Int(self.componentDevice.port)
          cell.stepperMinValue = 1
          cell.stepperMaxValue = 3
          cell.stepperWraps = true
          cell.changeHandler = { if let n = $0 as? NSNumber { self.componentDevice.port = n.shortValue } }
      })
      return [networkDeviceRow, portRow]
    })

    /// Power
    ////////////////////////////////////////////////////////////////////////////////

    let powerSection = BankItemDetailSection(sectionNumber: 2, title: "Power", createRows: {
      let powerOnRow = BankItemDetailRow(identifier: .Button, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "On"
          cell.info = self.componentDevice.onCommand
          cell.pickerNilSelectionTitle = "No On Command"
          cell.pickerSelection = self.componentDevice.onCommand?.code
          cell.pickerSelectionHandler = {
            (selection: NSObject?) -> Void in
            let moc = self.componentDevice.managedObjectContext!
            moc.performBlock {
              if let code = selection as? IRCode {
                if let command = self.componentDevice.onCommand {
                  command.code = code
                } else {
                  let command = SendIRCommand(inContext: moc)
                  command.code = code
                  self.componentDevice.onCommand = command
                }
              } else {
                self.componentDevice.onCommand = nil
              }
            }
          }
          cell.pickerData = self.codes
      })
      let powerOffRow = BankItemDetailRow(identifier: .Button, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Off"
          cell.info = self.componentDevice.offCommand
          cell.pickerNilSelectionTitle = "No Off Command"
          cell.pickerSelection = self.componentDevice.offCommand?.code
          cell.pickerSelectionHandler = {
            (selection: NSObject?) -> Void in
            let moc = self.componentDevice.managedObjectContext!
            moc.performBlock {
              if let code = selection as? IRCode {
                if let command = self.componentDevice.offCommand {
                  command.code = code
                } else {
                  let command = SendIRCommand(inContext: moc)
                  command.code = code
                  self.componentDevice.offCommand = command
                }
              } else {
                self.componentDevice.offCommand = nil
              }
            }
          }
          cell.pickerData = self.codes
      })
      return [powerOnRow, powerOffRow]
    })

    // Inputs
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let inputsSection = BankItemDetailSection(sectionNumber: 3, title: "Inputs", createRows: {
      let inputPowersOnRow = BankItemDetailRow(identifier: .Switch, isEditable: true, configureCell: {
        (cell: BankItemCell) -> Void in
          cell.name = "Inputs Power On Device"
          cell.info = self.componentDevice.inputPowersOn
          cell.changeHandler = { self.componentDevice.inputPowersOn = $0 as Bool }
      })
      var rows = [inputPowersOnRow]
      if let inputs = sortedByName(self.componentDevice.inputs.allObjects as? [IRCode]) {
        for input in inputs {
          let inputRow = BankItemDetailRow(identifier: .Button, isEditable: true,
            selectionHandler: {
              let controller = input.detailController()
              self.navigationController?.pushViewController(controller, animated: true)
            },
            configureCell: {
              (cell: BankItemCell) -> Void in
                cell.info = input
          })
        }
      }
      return rows
    })

    /// Create the sections
    ////////////////////////////////////////////////////////////////////////////////

    sections = [manufacturerSection, networkDeviceSection, powerSection, inputsSection]
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
