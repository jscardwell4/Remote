//
//  ComponentDevice+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import CoreData
import MoonKit

extension ComponentDevice: Detailable {
  func detailController() -> UIViewController { return ComponentDeviceDetailController(model: self) }
}

extension ComponentDevice: DelegateDetailable {
    func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex {

      var sections: BankModelDetailDelegate.SectionIndex = [:]

      struct SectionKey {
        static let Manufacturer  = "Manufacturer"
        static let NetworkDevice = "Network Device"
        static let Power         = "Power"
        static let Inputs        = "Inputs"
      }

      struct RowKey {
        static let Manufacturer  = "Manufacturer"
        static let CodeSet       = "Code Set"
        static let NetworkDevice = "Network Device"
        static let Port          = "Port"
        static let On            = "On"
        static let Off           = "Off"
        static let InputPowersOn = "Input Powers On"
      }

     /** loadManufacturerSection */
      func loadManufacturerSection() {

        let componentDevice = self

        if componentDevice.managedObjectContext == nil { return }

        let moc = componentDevice.managedObjectContext!

        /// Manufacturer
        ////////////////////////////////////////////////////////////////////////////////


        let manufacturerSection = BankCollectionDetailSection(section: 0)

        manufacturerSection.addRow({
          var row = BankCollectionDetailButtonRow()
          row.name = "Manufacturer"
          row.info = componentDevice.manufacturer
          row.select = BankCollectionDetailRow.selectPushableItem(componentDevice.manufacturer)

          var pickerRow = BankCollectionDetailPickerRow()
          pickerRow.nilItemTitle = "No Manufacturer"
          pickerRow.createItemTitle = "⨁ New Manufacturer"
          pickerRow.didSelectItem = {
            if !controller.didCancel {
              if let manufacturer = $0 as? Manufacturer {
                componentDevice.manufacturer = manufacturer
              }
              controller.reloadItemAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
              controller.cellDisplayingPicker?.info = $0
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
              controller.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(UIAlertAction(title: "Create", style: .Default) {
              action in
                if let text = (alert.textFields?.first as? UITextField)?.text {
                  moc.performBlockAndWait {
                    let manufacturer = Manufacturer.createInContext(moc)
                    manufacturer.name = text
                    componentDevice.manufacturer = manufacturer
                    dispatch_async(dispatch_get_main_queue()) {
                      controller.reloadItemAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
                    }
                  }
                }
                controller.dismissViewControllerAnimated(true, completion: nil)
            })

            controller.presentViewController(alert, animated: true, completion: nil)
          }
          let data = sortedByName((Manufacturer.objectsInContext(moc) as? [Manufacturer] ?? []))
          pickerRow.data = data
          pickerRow.info = componentDevice.manufacturer

          row.detailPickerRow = pickerRow

          return row
        }, forKey: RowKey.Manufacturer)

        manufacturerSection.addRow({

          var row = BankCollectionDetailButtonRow()
          row.name = "Code Set"
          row.info = componentDevice.codeSet
          row.select = BankCollectionDetailRow.selectPushableCollection(componentDevice.codeSet)

          var pickerRow = BankCollectionDetailPickerRow()
          pickerRow.nilItemTitle = "No Code Set"
          pickerRow.createItemTitle = "⨁ New Code Set"
          pickerRow.didSelectItem = {
            if !controller.didCancel {
              componentDevice.codeSet = $0 as? IRCodeSet
              controller.reloadItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
              controller.cellDisplayingPicker?.info = $0
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
              controller.dismissViewControllerAnimated(true, completion: nil)
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
              controller.dismissViewControllerAnimated(true, completion: nil)
              })

            controller.presentViewController(alert, animated: true, completion: nil)
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
      func loadNetworkDeviceSection() {

        let componentDevice = self

        if componentDevice.managedObjectContext == nil { return }

        let moc = componentDevice.managedObjectContext!

        /// Network Device
        ////////////////////////////////////////////////////////////////////////////////

        let networkDeviceSection = BankCollectionDetailSection(section: 1, title: "Network Device")

        networkDeviceSection.addRow({
          var row = BankCollectionDetailButtonRow()
          row.info = componentDevice.networkDevice ?? "No Network Device"
          row.name = "Network Device"
          row.select = {
              if let networkDevice = componentDevice.networkDevice as? Detailable {
                controller.navigationController?.pushViewController(networkDevice.detailController(), animated: true)
              }
            }

          var pickerRow = BankCollectionDetailPickerRow()
          pickerRow.nilItemTitle = "No Network Device"
          pickerRow.didSelectItem = {
            if !controller.didCancel {
              componentDevice.networkDevice = $0 as? NetworkDevice
              controller.cellDisplayingPicker?.info = $0
              pickerRow.info = $0
            }
          }
          let data = sortedByName(NetworkDevice.objectsInContext(moc) as? [NetworkDevice] ?? [])
          pickerRow.data = data
          pickerRow.info = componentDevice.networkDevice

          row.detailPickerRow = pickerRow

          return row
        }, forKey: RowKey.NetworkDevice)

        networkDeviceSection.addRow({
          var row = BankCollectionDetailStepperRow()
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
      func loadPowerSection() {

        let componentDevice = self

        if componentDevice.managedObjectContext == nil { return }

        let moc = componentDevice.managedObjectContext!


        /// Power
        ////////////////////////////////////////////////////////////////////////////////

        let powerSection = BankCollectionDetailSection(section: 2, title: "Power")

        powerSection.addRow({
          var row = BankCollectionDetailButtonRow()
          row.name = "On"
          row.info = componentDevice.onCommand ?? "No On Command"

          var pickerRow = BankCollectionDetailPickerRow()
          pickerRow.nilItemTitle = "No On Command"
          pickerRow.didSelectItem = {
            (selection: AnyObject?) -> Void in
              if !controller.didCancel {
                moc.performBlock {
                  if let code = selection as? IRCode {
                    if let command = componentDevice.onCommand {
                      command.code = code
                    } else {
                      let command = ITachIRCommand(context: moc)
                      command.code = code
                      componentDevice.onCommand = command
                    }
                  } else {
                    componentDevice.onCommand = nil
                  }
                }
                controller.cellDisplayingPicker?.info = selection
                pickerRow.info = selection
              }
          }
          let data = sortedByName(componentDevice.codeSet?.codes)
          pickerRow.data = data
          pickerRow.info = componentDevice.onCommand?.code

          row.detailPickerRow = pickerRow

          return row
        }, forKey: RowKey.On)

        powerSection.addRow({
          var row = BankCollectionDetailButtonRow()
          row.name = "Off"
          row.info = componentDevice.offCommand ?? "No Off Command"

          var pickerRow = BankCollectionDetailPickerRow()
          pickerRow.nilItemTitle = "No Off Command"
          pickerRow.didSelectItem = {
            (selection: AnyObject?) -> Void in
              if !controller.didCancel {
                moc.performBlock {
                  if let code = selection as? IRCode {
                    if let command = componentDevice.offCommand {
                      command.code = code
                    } else {
                      let command = ITachIRCommand(context: moc)
                      command.code = code
                      componentDevice.offCommand = command
                    }
                  } else {
                    componentDevice.offCommand = nil
                  }
                }
                controller.cellDisplayingPicker?.info = selection
                pickerRow.info = selection
              }
          }
          let data = sortedByName(componentDevice.codeSet?.codes)
          pickerRow.data = data
          pickerRow.info = componentDevice.offCommand?.code

          row.detailPickerRow = pickerRow

          return row
        }, forKey: RowKey.Off)

      }

      /** loadInputsSection */
      func loadInputsSection() {

        let componentDevice = self

        if componentDevice.managedObjectContext == nil { return }

        let moc = componentDevice.managedObjectContext!


        // Inputs
        ////////////////////////////////////////////////////////////////////////////////////////////////////

        let inputsSection = BankCollectionDetailSection(section: 3, title: "Inputs")

        inputsSection.addRow({
          var row = BankCollectionDetailSwitchRow()
          row.name = "Inputs Power On Device"
          row.info = NSNumber(bool: componentDevice.inputPowersOn)
          row.valueDidChange = { componentDevice.inputPowersOn = $0 as! Bool }

          return row
        }, forKey: RowKey.InputPowersOn)

        for (idx, input) in enumerate(sortedByName(componentDevice.inputs)) {
          inputsSection.addRow({
            let row = BankCollectionDetailListRow()
            row.info = input
            row.select = BankCollectionDetailRow.selectPushableItem(input)
            row.delete = {input.delete()}
            return row
            }, forKey: "\(SectionKey.Inputs)\(idx)")
        }

        sections[SectionKey.Inputs] = inputsSection
      }

      loadManufacturerSection()
      loadNetworkDeviceSection()
      loadPowerSection()
      loadInputsSection()

      return sections
    }
}
extension ComponentDevice: FormCreatable {

  /**
  creationForm:

  :param: #context NSManagedObjectContext

  :returns: Form
  */
  static func creationForm(#context: NSManagedObjectContext) -> Form {

    var fields: OrderedDictionary<String, FieldTemplate> = [:]

    fields["Name"]            = nameFormFieldTemplate(context: context)
    fields["Manufacturer"]    = Manufacturer.pickerFormFieldTemplate(context: context)
    fields["Port"]            = .Stepper(value: 1, min: 1, max: 3, step: 1, editable: true)
    fields["Network Device"]  = ITachDevice.pickerFormFieldTemplate(context: context)
    fields["Always On"]       = .Switch(value: false, editable: true)
    fields["Input Powers On"] = .Switch(value: false, editable: true)

    /**
    codeSet:       IRCodeSet?
    */

    return Form(templates: fields)
  }

  /**
  createWithForm:context:

  :param: form Form
  :param: context NSManagedObjectContext

  :returns: ComponentDevice?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> ComponentDevice? {
    MSLogDebug("\(form)")
    if let values = form.values,
      name = values["Name"] as? String,
      port = values["Port"] as? Double,
      alwaysOn = values["Always On"] as? Bool,
      inputPowersOn = values["Input Powers On"] as? Bool
    {
      let componentDevice = ComponentDevice(name: name, context: context)
      componentDevice.port = Int16(port)
      componentDevice.alwaysOn = alwaysOn
      componentDevice.inputPowersOn = inputPowersOn
      if let manufacturerName = values["Manufacturer"] as? String,
        manufacturer = Manufacturer.objectWithValue(manufacturerName, forAttribute: "name", context: context)
      {
        componentDevice.manufacturer = manufacturer
      }
      if let networkDeviceName = values["Network Device"] as? String,
        networkDevice = ITachDevice.objectWithValue(networkDeviceName, forAttribute: "name", context: context)
      {
        componentDevice.networkDevice = networkDevice
      }
      return componentDevice
    }
    return nil
  }

}