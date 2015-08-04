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

extension ComponentDevice: DelegateDetailable {

  /**
  sectionIndexForController:

  - parameter controller: BankCollectionDetailController

  - returns: BankModelDetailDelegate.SectionIndex
  */
  func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex {

    var sections: BankModelDetailDelegate.SectionIndex = [:]
    
    guard let moc = managedObjectContext else { return sections }

    enum SectionKey: String { case Manufacturer, NetworkDevice, Power, Inputs }

    enum RowKey: String { case Manufacturer, CodeSet, NetworkDevice, Port, On, Off, InputPowersOn }

     /** loadManufacturerSection */
      func loadManufacturerSection() {

        let manufacturerSection = BankCollectionDetailSection(section: 0)

        manufacturerSection.addRow({
          let row = BankCollectionDetailButtonRow()
          row.name = "Manufacturer"
          row.select = BankCollectionDetailRow.selectPushableItem(self.manufacturer)
          row.nilItem = .NilItem(title: "No Manufacturer")
          row.didSelectItem = { [unowned controller] in
            if !controller.didCancel,
              let manufacturer = $0 as? Manufacturer where self.manufacturer != manufacturer
            {
              self.manufacturer = manufacturer
              if let indexPath = manufacturerSection[RowKey.CodeSet.rawValue]?.indexPath {
                controller.reloadItemAtIndexPath(indexPath)
              }
            }
          }
          row.data = (Manufacturer.objectsInContext(moc) as? [Manufacturer])?.sortByName()
          row.info = self.manufacturer

          return row
        }, forKey: RowKey.Manufacturer.rawValue)
        manufacturerSection.addRow({ [unowned controller] in

          let row = BankCollectionDetailButtonRow()
          row.name = "Code Set"
          row.select = BankCollectionDetailRow.selectPushableCollection(self.codeSet)
          row.nilItem = .NilItem(title: "No Code Set")
          row.didSelectItem = {
            if !controller.didCancel {
              self.codeSet = $0 as? IRCodeSet
              if let powerSection = sections[SectionKey.Power.rawValue] { controller.reloadSection(powerSection) }
            }
          }
          row.data = self.manufacturer.codeSets.sortByName()
          row.info = self.codeSet

          return row
        }, forKey: RowKey.CodeSet.rawValue)

        sections[SectionKey.Manufacturer.rawValue] = manufacturerSection
      }

      /** loadNetworkDeviceSection */
      func loadNetworkDeviceSection() {

        let networkDeviceSection = BankCollectionDetailSection(section: 1, title: "Network Device")

        networkDeviceSection.addRow({ [unowned controller] in
          let row = BankCollectionDetailButtonRow()
          row.name = "Network Device"
          row.select = BankCollectionDetailRow.selectPushableItem(self.networkDevice as? BankCollectionDetailRow.PushableItem)
          row.nilItem = .NilItem(title: "No Network Device")
          row.didSelectItem = {
            if !controller.didCancel {
              self.networkDevice = $0 as? NetworkDevice
            }
          }
          row.data = (NetworkDevice.objectsInContext(moc) as? [NetworkDevice])?.sortByName()
          row.info = self.networkDevice

          return row
        }, forKey: RowKey.NetworkDevice.rawValue)

        networkDeviceSection.addRow({
          let row = BankCollectionDetailStepperRow()
          row.name = "Port"
          row.infoDataType = .IntData(1...3)
          row.info = NSNumber(short: self.port)
          row.stepperMinValue = 1
          row.stepperMaxValue = 3
          row.stepperWraps = true
          row.valueDidChange = { if let n = $0 as? NSNumber { self.port = n.shortValue } }

          return row
        }, forKey: RowKey.Port.rawValue)

        sections[SectionKey.NetworkDevice.rawValue] = networkDeviceSection
      }

      /** loadPowerSection */
      func loadPowerSection() {

        let powerSection = BankCollectionDetailSection(section: 2, title: "Power")

        powerSection.addRow({ [unowned controller] in
          let row = BankCollectionDetailButtonRow()
          row.name = "On"
          row.nilItem = .NilItem(title: "No On Command")
          row.didSelectItem = {
            (selection: AnyObject?) -> Void in
              if !controller.didCancel {
                moc.performBlock {
                  guard let code = selection as? IRCode else { self.onCommand = nil; return }
                  if let command = self.onCommand {
                    command.code = code
                  } else {
                    let command = ITachIRCommand(context: moc)
                    command.code = code
                    self.onCommand = command
                  }
                }
              }
          }
          row.data = self.codeSet?.codes.sortByName()
          row.info = self.onCommand?.code

          return row
        }, forKey: RowKey.On.rawValue)

        // ???: Why does on command show up but not off command?
        powerSection.addRow({ [unowned controller] in
          let row = BankCollectionDetailButtonRow()
          row.name = "Off"
          row.nilItem = .NilItem(title: "No Off Command")
          row.didSelectItem = {
            (selection: AnyObject?) -> Void in
              if !controller.didCancel {
                moc.performBlock {
                  guard let code = selection as? IRCode else { self.offCommand = nil; return }
                  if let command = self.offCommand {
                    command.code = code
                  } else {
                    let command = ITachIRCommand(context: moc)
                    command.code = code
                    self.offCommand = command
                  }
                }
              }
          }
          row.data = self.codeSet?.codes.sortByName()
          row.info = self.offCommand?.code

          return row
        }, forKey: RowKey.Off.rawValue)

        sections[SectionKey.Power.rawValue] = powerSection
      }

      /** loadInputsSection */
      func loadInputsSection() {

        let inputsSection = BankCollectionDetailSection(section: 3, title: "Inputs")

        inputsSection.addRow({
          let row = BankCollectionDetailSwitchRow()
          row.name = "Inputs Power On Device"
          row.info = NSNumber(bool: self.inputPowersOn)
          row.valueDidChange = { self.inputPowersOn = $0 as! Bool }

          return row
        }, forKey: RowKey.InputPowersOn.rawValue)

        for (idx, input) in self.inputs.sortByName().enumerate() {
          inputsSection.addRow({
            let row = BankCollectionDetailListRow()
            row.info = input
            row.select = BankCollectionDetailRow.selectPushableItem(input)
            row.delete = {input.delete()}
            return row
            }, forKey: "\(SectionKey.Inputs.rawValue)\(idx)")
        }

        sections[SectionKey.Inputs.rawValue] = inputsSection
      }

      loadManufacturerSection()
      loadNetworkDeviceSection()
      loadPowerSection()
      loadInputsSection()

      return sections
    }
}

extension ComponentDevice: RelatedItemCreatable {

  var relatedItemCreationTransactions: [ItemCreationTransaction] {

    var transactions: [ItemCreationTransaction] = []

    if let context = managedObjectContext {

      // Manufacturer transaction
      let createManufacturer = { () -> FormTransaction in

        let label = "Manufacturer"

        let form = Manufacturer.creationForm(context: context)

        let processedForm: (Form) -> Bool = {
          [unowned self, unowned context] form in
          do {
            try DataManager.saveContext(context, withBlock: {
              if let manufacturer = Manufacturer.createWithForm(form, context: $0) { self.manufacturer = manufacturer }
            })
            return true
          } catch {
            logError(error)
            return false
          }
        }

        return FormTransaction(label: label, form: form, processedForm: processedForm)

      }()

      transactions.append(createManufacturer)

      // Code set transaction
      let createCodeSet = { () -> FormTransaction in

        let label = "Code Set"

        let form = IRCodeSet.creationForm(context: context)
        if let manufacturerField = form.fields["Manufacturer"] {
          manufacturerField.value = self.manufacturer.name
          manufacturerField.editable = false
        }

        let processedForm: (Form) -> Bool = {
          [unowned self] form in
          do {
            try DataManager.saveContext(context, withBlock: {
              guard let codeSet = IRCodeSet.createWithForm(form, context: $0) else { return }
              self.codeSet = codeSet
            })
            return true
          } catch { logError(error); return false }
        }

        return FormTransaction(label: label, form: form, processedForm: processedForm)
        
      }()

      transactions.append(createCodeSet)

      // Network device transaction
      let discoverNetworkDevice = { () -> CustomTransaction in

        let label = "Network Device"

        let controller = {
          [unowned self] (didCancel: () -> Void, didCreate: (ModelObject) -> Void) -> UIViewController? in

          let didCreateWrapper = {
            [unowned self] (model: ModelObject) -> Void in

            guard let networkDevice = model as? NetworkDevice else { didCreate(model); return }
            self.networkDevice = networkDevice
            didCreate(model)

          }
          return NetworkDevice.creationControllerWithContext(context,
                                         cancellationHandler: didCancel,
                                             creationHandler: didCreateWrapper)
        }

        return CustomTransaction(label: label, controller: controller)

      }()

      transactions.append(discoverNetworkDevice)

      // TODO: Add power commands
      // TODO: Add inputs
    }
    return transactions
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