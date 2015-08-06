//
//  Manufacturer+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import CoreData
import MoonKit

extension Manufacturer: BankModelCollection {
  var collectionType: ModelCollection.Type { return IRCodeSet.self }
  var collectionLabel: String { return "Code Set" }
}

extension Manufacturer: DelegateDetailable {

  func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex {

    var sections: BankModelDetailDelegate.SectionIndex = [:]

    enum SectionKey: String { case Devices, CodeSets }

    enum RowKey: String { case Devices, CodeSets }

    /** loadDevicesSection */
    func loadDevicesSection() {

      let manufacturer = self

      let devicesSection = BankCollectionDetailSection(section: 0, title: "Devices")
      for (idx, device) in manufacturer.devices.sortByName().enumerate() {
        devicesSection.addRow({
          let row = BankCollectionDetailListRow()
          row.info = device
          row.select = BankCollectionDetailRow.selectPushableItem(device)
          return row
          }, forKey: "\(RowKey.Devices.rawValue)\(idx)")
      }

      sections[SectionKey.Devices.rawValue] = devicesSection
    }

    /** loadCodeSetsSection */
    func loadCodeSetsSection() {

      let manufacturer = self

      let codeSetsSection = BankCollectionDetailSection(section: 1, title: "Code Sets")
      for (idx, codeSet) in manufacturer.codeSets.sortByName().enumerate() {
        codeSetsSection.addRow({
          let row = BankCollectionDetailListRow()
          row.info = codeSet
          row.select = BankCollectionDetailRow.selectPushableCollection(codeSet)
          return row
          }, forKey: "\(RowKey.CodeSets.rawValue)\(idx)")
      }

      sections[SectionKey.CodeSets.rawValue] = codeSetsSection

    }

    loadDevicesSection()
    loadCodeSetsSection()

    return sections
  }
}

extension Manufacturer: RelatedItemCreatable {

  var relatedItemCreationTransactions: [ItemCreationTransaction] {

    var transactions: [ItemCreationTransaction] = []

    if let context = managedObjectContext {

      // Component device transaction
      let componentDeviceForm = ComponentDevice.creationForm(context: context)

      if let manufacturerField = componentDeviceForm.fields["Manufacturer"] {
        manufacturerField.value = name
        manufacturerField.editable = false
      }

      let createComponentDevice = FormTransaction(
        label: "Component Device",
        form: componentDeviceForm,
        processedForm: {
          form in
          do {
            try DataManager.saveContext(context, withBlock: {
              _ = ComponentDevice.createWithForm(form, context: $0)
              })
            return true
          } catch {
            logError(error)
            return false
          }
      })

      transactions.append(createComponentDevice)

      // Code set transaction
      let codeSetForm = IRCodeSet.creationForm(context: context)

      if let manufacturerField = codeSetForm.fields["Manufacturer"] {
        manufacturerField.value = name
        manufacturerField.editable = false
      }

      let createCodeSet = FormTransaction(
        label: "Code Set",
        form: codeSetForm,
        processedForm: {
          form in
          do {
            try DataManager.saveContext(context, withBlock: {
               _ = IRCodeSet.createWithForm(form, context: $0)
              })
            return true
          } catch {
            logError(error)
            return false
          }
      })

      transactions.append(createCodeSet)
    }
    return transactions
  }
  
}

extension Manufacturer: FormCreatable {

  /**
  creationForm:

  - parameter #context: NSManagedObjectContext

  - returns: Form
  */
  static func creationForm(context context: NSManagedObjectContext) -> Form {
    return Form(templates: OrderedDictionary<String, Field.Template>(["Name": nameFormFieldTemplate(context: context)]))
  }

  /**
  createWithForm:context:

  - parameter form: Form
  - parameter context: NSManagedObjectContext

  - returns: Manufacturer?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Manufacturer? {
    if let name = form.values?["Name"] as? String { return Manufacturer(name: name, context: context) }
    else { return nil }
  }

}