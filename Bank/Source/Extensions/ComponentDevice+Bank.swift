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
          let row = BankCollectionDetailButtonRow()
          row.name = "Manufacturer"
          row.info = componentDevice.manufacturer
          row.select = BankCollectionDetailRow.selectPushableItem(componentDevice.manufacturer)

          row.nilItem = .NilItem(title: "No Manufacturer")
          row.didSelectItem = {
            if !controller.didCancel {
              if let manufacturer = $0 as? Manufacturer {
                componentDevice.manufacturer = manufacturer
              }
//              controller.reloadItemAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
//              controller.cellDisplayingPicker?.info = $0
//              row.info = $0
            }
          }
          row.createItem = .CreateItem(title: "⨁ New Manufacturer", createItem: {
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
                if let text = alert.textFields?.first?.text {
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
          })
          let data = sortedByName((Manufacturer.objectsInContext(moc) as? [Manufacturer] ?? []))
          row.data = data
          row.info = componentDevice.manufacturer

          return row
        }, forKey: RowKey.Manufacturer)

        manufacturerSection.addRow({

          let row = BankCollectionDetailButtonRow()
          row.name = "Code Set"
          row.info = componentDevice.codeSet
          row.select = BankCollectionDetailRow.selectPushableCollection(componentDevice.codeSet)

          row.nilItem = .NilItem(title: "No Code Set")
          row.didSelectItem = {
            if !controller.didCancel {
              componentDevice.codeSet = $0 as? IRCodeSet
              controller.reloadItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
//              controller.cellDisplayingPicker?.info = $0
//              row.info = $0
            }
          }
          row.createItem = .CreateItem(title: "⨁ New Code Set", createItem: {
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
              if let text = alert.textFields?.first?.text {
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
          })
          let data = sortedByName(componentDevice.manufacturer.codeSets)
          row.data = data
          row.info = componentDevice.codeSet

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
          let row = BankCollectionDetailButtonRow()
          row.info = componentDevice.networkDevice ?? "No Network Device"
          row.name = "Network Device"
          row.select = {
              if let networkDevice = componentDevice.networkDevice as? Detailable {
                controller.navigationController?.pushViewController(networkDevice.detailController(), animated: true)
              }
            }

          row.nilItem = .NilItem(title: "No Network Device")
          row.didSelectItem = {
            if !controller.didCancel {
              componentDevice.networkDevice = $0 as? NetworkDevice
//              controller.cellDisplayingPicker?.info = $0
//              row.info = $0
            }
          }
          let data = sortedByName(NetworkDevice.objectsInContext(moc) as? [NetworkDevice] ?? [])
          row.data = data
          row.info = componentDevice.networkDevice

          return row
        }, forKey: RowKey.NetworkDevice)

        networkDeviceSection.addRow({
          let row = BankCollectionDetailStepperRow()
          row.name = "Port"
          row.infoDataType = .IntData(1...3)
          row.info = NSNumber(short: componentDevice.port)
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
          let row = BankCollectionDetailButtonRow()
          row.name = "On"
          row.info = componentDevice.onCommand ?? "No On Command"

          row.nilItem = .NilItem(title: "No On Command")
          row.didSelectItem = {
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
//                controller.cellDisplayingPicker?.info = selection
//                row.info = selection
              }
          }
          let data = sortedByName(componentDevice.codeSet?.codes)
          row.data = data
          row.info = componentDevice.onCommand?.code

          return row
        }, forKey: RowKey.On)

        powerSection.addRow({
          let row = BankCollectionDetailButtonRow()
          row.name = "Off"
          row.info = componentDevice.offCommand ?? "No Off Command"

          row.nilItem = .NilItem(title: "No Off Command")
          row.didSelectItem = {
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
//                controller.cellDisplayingPicker?.info = selection
//                row.info = selection
              }
          }
          let data = sortedByName(componentDevice.codeSet?.codes)
          row.data = data
          row.info = componentDevice.offCommand?.code

          return row
        }, forKey: RowKey.Off)

      }

      /** loadInputsSection */
      func loadInputsSection() {

        let componentDevice = self

        if componentDevice.managedObjectContext == nil { return }

        // Inputs
        ////////////////////////////////////////////////////////////////////////////////////////////////////

        let inputsSection = BankCollectionDetailSection(section: 3, title: "Inputs")

        inputsSection.addRow({
          let row = BankCollectionDetailSwitchRow()
          row.name = "Inputs Power On Device"
          row.info = NSNumber(bool: componentDevice.inputPowersOn)
          row.valueDidChange = { componentDevice.inputPowersOn = $0 as! Bool }

          return row
        }, forKey: RowKey.InputPowersOn)

        for (idx, input) in sortedByName(componentDevice.inputs).enumerate() {
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

  - parameter #context: NSManagedObjectContext

  - returns: Form
  */
  static func creationForm(context context: NSManagedObjectContext) -> Form {

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

  - parameter form: Form
  - parameter context: NSManagedObjectContext

  - returns: ComponentDevice?
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