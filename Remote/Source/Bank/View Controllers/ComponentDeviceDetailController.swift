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

  private struct SectionKey {
    static let Manufacturer  = "Manufacturer"
    static let NetworkDevice = "Network Device"
    static let Power         = "Power"
    static let Inputs        = "Inputs"
  }

  private struct RowKey {
    static let Manufacturer  = "Manufacturer"
    static let CodeSet       = "Code Set"
    static let NetworkDevice = "Network Device"
    static let Port          = "Port"
    static let On            = "On"
    static let Off           = "Off"
    static let InputPowersOn = "Input Powers On"
  }

  /** loadSections */
  override func loadSections() {
    super.loadSections()

    precondition(model is ComponentDevice, "we should have been given a component device")

    loadManufacturerSection()
    loadNetworkDeviceSection()
    loadPowerSection()
    loadInputsSection()

  }

  /** loadManufacturerSection */
  private func loadManufacturerSection() {

    let componentDevice = model as! ComponentDevice

    if componentDevice.managedObjectContext == nil { return }

    let moc = componentDevice.managedObjectContext!

    /// Manufacturer
    ////////////////////////////////////////////////////////////////////////////////


    let manufacturerSection = DetailSection(section: 0)

    manufacturerSection.addRow({
      var row = DetailButtonRow(pushableItem: componentDevice.manufacturer)
      row.name = "Manufacturer"
      row.info = componentDevice.manufacturer
//      row.editActions = [UITableViewRowAction(style: .Default, title: "Clear", handler: {
//        (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
//          componentDevice.manufacturer = nil
//          self.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)])
//      })]

      var pickerRow = DetailPickerRow()
      pickerRow.nilItemTitle = "No Manufacturer"
      pickerRow.createItemTitle = "⨁ New Manufacturer"
      pickerRow.didSelectItem = {
        if !self.didCancel {
          if let manufacturer = $0 as? Manufacturer {
            componentDevice.manufacturer = manufacturer
          }
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
      let data = sortedByName((Manufacturer.findAllInContext(moc) as? [Manufacturer] ?? []))
      pickerRow.data = data
      pickerRow.info = componentDevice.manufacturer

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.Manufacturer)

    manufacturerSection.addRow({

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
      let data = sortedByName(componentDevice.manufacturer.codeSets)
      pickerRow.data = data
      pickerRow.info = componentDevice.codeSet

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.CodeSet)

    sections[SectionKey.Manufacturer] = manufacturerSection
  }

  /** loadNetworkDeviceSection */
  private func loadNetworkDeviceSection() {

    let componentDevice = model as! ComponentDevice

    if componentDevice.managedObjectContext == nil { return }

    let moc = componentDevice.managedObjectContext!

    /// Network Device
    ////////////////////////////////////////////////////////////////////////////////

    let networkDeviceSection = DetailSection(section: 1, title: "Network Device")

    networkDeviceSection.addRow({
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
      let data = sortedByName(NetworkDevice.findAllInContext(moc) as? [NetworkDevice] ?? [])
      pickerRow.data = data
      pickerRow.info = componentDevice.networkDevice

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.NetworkDevice)

    networkDeviceSection.addRow({
      var row = DetailStepperRow()
      row.name = "Port"
      row.info = Int(componentDevice.port)
      row.stepperMinValue = 1
      row.stepperMaxValue = 3
      row.stepperWraps = true
      row.valueDidChange = { if let n = $0 as? NSNumber { componentDevice.port = n.shortValue } }

      return row
    }, forKey: RowKey.Port)

    sections[SectionKey.NetworkDevice] = networkDeviceSection
  }

  /** loadPowerSection */
  private func loadPowerSection() {

    let componentDevice = model as! ComponentDevice

    if componentDevice.managedObjectContext == nil { return }

    let moc = componentDevice.managedObjectContext!


    /// Power
    ////////////////////////////////////////////////////////////////////////////////

    let powerSection = DetailSection(section: 2, title: "Power")

    powerSection.addRow({
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
                  let command = SendIRCommand(context: moc)
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
      let data = sortedByName(componentDevice.codeSet?.items as? [IRCode] ?? [])
      pickerRow.data = data
      pickerRow.info = componentDevice.onCommand?.code

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.On)

    powerSection.addRow({
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
                  let command = SendIRCommand(context: moc)
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
      let data = sortedByName(componentDevice.codeSet?.items as? [IRCode] ?? [])
      pickerRow.data = data
      pickerRow.info = componentDevice.offCommand?.code

      row.detailPickerRow = pickerRow

      return row
    }, forKey: RowKey.Off)

  }

  /** loadInputsSection */
  private func loadInputsSection() {

    let componentDevice = model as! ComponentDevice

    if componentDevice.managedObjectContext == nil { return }

    let moc = componentDevice.managedObjectContext!


    // Inputs
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    let inputsSection = DetailSection(section: 3, title: "Inputs")

    inputsSection.addRow({
      var row = DetailSwitchRow()
      row.name = "Inputs Power On Device"
      row.info = NSNumber(bool: componentDevice.inputPowersOn)
      row.valueDidChange = { componentDevice.inputPowersOn = $0 as! Bool }

      return row
    }, forKey: RowKey.InputPowersOn)

    for (idx, input) in enumerate(sortedByName(componentDevice.inputs)) {
      inputsSection.addRow({ return DetailListRow(pushableItem: input) }, forKey: "\(SectionKey.Inputs)\(idx)")
    }

    sections[SectionKey.Inputs] = inputsSection
  }

}
