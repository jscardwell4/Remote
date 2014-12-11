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

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is ComponentDevice, "we should have been given a component device")

    let componentDevice = model as ComponentDevice

    if componentDevice.managedObjectContext == nil { return }

    let moc = componentDevice.managedObjectContext!

    /// Manufacturer
    ////////////////////////////////////////////////////////////////////////////////


    let manufacturerSection = DetailSection(section: 0)

    manufacturerSection.addRow {
      var row = DetailButtonRow(pushableItem: componentDevice.manufacturer)
      row.name = "Manufacturer"
      row.info = componentDevice.manufacturer
      row.editActions = [UITableViewRowAction(style: .Default, title: "Clear", handler: {
        (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
          componentDevice.manufacturer = nil
          self.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)])
      })]

      var pickerRow = DetailPickerRow()
      pickerRow.nilItemTitle = "No Manufacturer"
      pickerRow.createItemTitle = "⨁ New Manufacturer"
      pickerRow.didSelectItem = {
        if !self.didCancel {
          componentDevice.manufacturer = $0 as? Manufacturer
          self.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)])
          self.cellDisplayingPicker?.info = $0
          pickerRow.info = $0
        }
      }
      pickerRow.createItem = {
        let alert = UIAlertController(title: "Create Manufacturer",
          message: "Enter a name for the manufacturer",
          preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler {
          $0.font = Bank.infoFont
          $0.textColor = Bank.infoColor
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
          action in
          row.info = componentDevice.manufacturer
          // re-select previous picker selection and dismiss picker
          self.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Create", style: .Default) {
          action in
            if let text = (alert.textFields?.first as? UITextField)?.text {
              moc.performBlockAndWait {
                let manufacturer = Manufacturer.createInContext(moc)
                manufacturer.name = text
                componentDevice.manufacturer = manufacturer
                dispatch_async(dispatch_get_main_queue()) {
                  self.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)])
                }
              }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        })

        self.presentViewController(alert, animated: true, completion: nil)
      }
      pickerRow.data = sortedByName(Manufacturer.findAllInContext(moc) as? [Manufacturer] ?? [])
      pickerRow.info = componentDevice.manufacturer

      row.detailPickerRow = pickerRow

      return row
    }

    manufacturerSection.addRow {

      var row = DetailButtonRow(pushableCategory: componentDevice.codeSet)
      row.name = "Code Set"
      row.info = componentDevice.codeSet

      var pickerRow = DetailPickerRow()
      pickerRow.nilItemTitle = "No Code Set"
      pickerRow.createItemTitle = "⨁ New Code Set"
      pickerRow.didSelectItem = {
        if !self.didCancel {
          componentDevice.codeSet = $0 as? IRCodeSet
          self.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
          self.cellDisplayingPicker?.info = $0
          pickerRow.info = $0
        }
      }
      pickerRow.createItem = {
        let alert = UIAlertController(title: "Create Code Set",
          message: "Enter a name for the code set",
          preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler {
          $0.font = Bank.infoFont
          $0.textColor = Bank.infoColor
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
          action in
          row.info = componentDevice.codeSet
          // re-select previous picker selection and dismiss picker
          self.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Create", style: .Default) {
          action in
          if let text = (alert.textFields?.first as? UITextField)?.text {
            moc.performBlockAndWait {
              let codeSet = IRCodeSet.createInContext(moc)
              codeSet.name = text
              codeSet.manufacturer = componentDevice.manufacturer
              componentDevice.codeSet = codeSet
            }
          }
          self.dismissViewControllerAnimated(true, completion: nil)
          })

        self.presentViewController(alert, animated: true, completion: nil)
      }
      pickerRow.data = sortedByName(componentDevice.manufacturer?.codeSets?.allObjects as? [IRCodeSet] ?? [])
      pickerRow.info = componentDevice.codeSet

      row.detailPickerRow = pickerRow

      return row
    }


    /// Network Device
    ////////////////////////////////////////////////////////////////////////////////

    let networkDeviceSection = DetailSection(section: 1, title: "Network Device")

    networkDeviceSection.addRow {
      var row = DetailButtonRow()
      row.info = componentDevice.networkDevice ?? "No Network Device"
      row.name = "Network Device"
      row.select = {
          if let networkDevice = componentDevice.networkDevice {
            self.navigationController?.pushViewController(networkDevice.detailController(), animated: true)
          }
        }

      var pickerRow = DetailPickerRow()
      pickerRow.nilItemTitle = "No Network Device"
      pickerRow.didSelectItem = {
        if !self.didCancel {
          componentDevice.networkDevice = $0 as? NetworkDevice
          self.cellDisplayingPicker?.info = $0
          pickerRow.info = $0
        }
      }
      pickerRow.data = sortedByName(NetworkDevice.findAllInContext(moc) as? [NetworkDevice] ?? [])
      pickerRow.info = componentDevice.networkDevice

      row.detailPickerRow = pickerRow

      return row
    }

    networkDeviceSection.addRow {
      var row = DetailStepperRow()
      row.name = "Port"
      row.info = Int(componentDevice.port)
      row.stepperMinValue = 1
      row.stepperMaxValue = 3
      row.stepperWraps = true
      row.valueDidChange = { if let n = $0 as? NSNumber { componentDevice.port = n.shortValue } }

      return row
    }

    /// Power
    ////////////////////////////////////////////////////////////////////////////////

    let powerSection = DetailSection(section: 2, title: "Power")

    powerSection.addRow {
      var row = DetailButtonRow()
      row.name = "On"
      row.info = componentDevice.onCommand ?? "No On Command"

      var pickerRow = DetailPickerRow()
      pickerRow.nilItemTitle = "No On Command"
      pickerRow.didSelectItem = {
        (selection: AnyObject?) -> Void in
          if !self.didCancel {
            moc.performBlock {
              if let code = selection as? IRCode {
                if let command = componentDevice.onCommand {
                  command.code = code
                } else {
                  let command = SendIRCommand(inContext: moc)
                  command.code = code
                  componentDevice.onCommand = command
                }
              } else {
                componentDevice.onCommand = nil
              }
            }
            self.cellDisplayingPicker?.info = selection
            pickerRow.info = selection
          }
      }
      pickerRow.data = sortedByName(componentDevice.codeSet?.items as? [IRCode] ?? [])
      pickerRow.info = componentDevice.onCommand?.code

      row.detailPickerRow = pickerRow

      return row
    }

    powerSection.addRow {
      var row = DetailButtonRow()
      row.name = "Off"
      row.info = componentDevice.offCommand ?? "No Off Command"

      var pickerRow = DetailPickerRow()
      pickerRow.nilItemTitle = "No Off Command"
      pickerRow.didSelectItem = {
        (selection: AnyObject?) -> Void in
          if !self.didCancel {
            moc.performBlock {
              if let code = selection as? IRCode {
                if let command = componentDevice.offCommand {
                  command.code = code
                } else {
                  let command = SendIRCommand(inContext: moc)
                  command.code = code
                  componentDevice.offCommand = command
                }
              } else {
                componentDevice.offCommand = nil
              }
            }
            self.cellDisplayingPicker?.info = selection
            pickerRow.info = selection
          }
      }
      pickerRow.data = sortedByName(componentDevice.codeSet?.items as? [IRCode] ?? [])
      pickerRow.info = componentDevice.offCommand?.code

      row.detailPickerRow = pickerRow

      return row
    }


    // Inputs
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let inputsSection = DetailSection(section: 3, title: "Inputs")

    inputsSection.addRow {
      var row = DetailSwitchRow()
      row.name = "Inputs Power On Device"
      row.info = NSNumber(bool: componentDevice.inputPowersOn)
      row.valueDidChange = { componentDevice.inputPowersOn = $0 as Bool }

      return row
    }

    for input in sortedByName(componentDevice.inputs) {
      inputsSection.addRow { return DetailListRow(pushableItem: input) }
    }

    /// Create the sections
    ////////////////////////////////////////////////////////////////////////////////

    sections = ["Manufacturer": manufacturerSection,
                "Network Device": networkDeviceSection,
                "Power": powerSection,
                "Inputs": inputsSection]
  }

}
