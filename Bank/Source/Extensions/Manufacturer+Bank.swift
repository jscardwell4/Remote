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

    struct SectionKey {
      static let Devices  = "Devices"
      static let CodeSets = "Code Sets"
    }

    struct RowKey {
      static let Devices  = "Devices"
      static let CodeSets = "Code Sets"
    }

    /** loadDevicesSection */
    func loadDevicesSection() {

      let manufacturer = self

      // Devices
      // section 0 - row 0
      ////////////////////////////////////////////////////////////////////////////////////////////////////

      let devicesSection = BankCollectionDetailSection(section: 0, title: "Devices")
      for (idx, device) in sortedByName(manufacturer.devices).enumerate() {
        devicesSection.addRow({
          let row = BankCollectionDetailListRow()
          row.info = device
          row.select = BankCollectionDetailRow.selectPushableItem(device)
          return row
          }, forKey: "\(RowKey.Devices)\(idx)")
      }

      sections[SectionKey.Devices] = devicesSection
    }

    /** loadCodeSetsSection */
    func loadCodeSetsSection() {

      let manufacturer = self

      // Code Sets
      // section 1 - row 0
      ////////////////////////////////////////////////////////////////////////////////////////////////////

      let codeSetsSection = BankCollectionDetailSection(section: 1, title: "Code Sets")
      for (idx, codeSet) in sortedByName(manufacturer.codeSets).enumerate() {
        codeSetsSection.addRow({
          let row = BankCollectionDetailListRow()
          row.info = codeSet
          row.select = BankCollectionDetailRow.selectPushableCollection(codeSet)
          return row
          }, forKey: "\(RowKey.CodeSets)\(idx)")
      }

      /// Create the sections
      ////////////////////////////////////////////////////////////////////////////////

      sections[SectionKey.CodeSets] = codeSetsSection

    }

    loadDevicesSection()
    loadCodeSetsSection()

    return sections
  }
}

extension Manufacturer: FormCreatable {

  /**
  creationForm:

  - parameter #context: NSManagedObjectContext

  - returns: Form
  */
  static func creationForm(context context: NSManagedObjectContext) -> Form {
    return Form(templates: OrderedDictionary<String, FieldTemplate>(["Name": nameFormFieldTemplate(context: context)]))
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