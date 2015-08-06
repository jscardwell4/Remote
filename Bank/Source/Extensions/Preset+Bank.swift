//
//  Preset+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import CoreData
import MoonKit

extension Preset: Previewable {}

extension Preset: DelegateDetailable {
    func sectionIndexForController(controller: BankCollectionDetailController) -> BankModelDetailDelegate.SectionIndex {
      let sections: BankModelDetailDelegate.SectionIndex = [:]


      return sections
    }
}

extension Preset: RelatedItemCreatable {

  var relatedItemCreationTransactions: [ItemCreationTransaction] {
    var transactions: [ItemCreationTransaction] = []

    if let context = managedObjectContext {

      let categoryTransaction = FormTransaction(
        label: "Category",
        form: PresetCategory.creationForm(context: context),
        processedForm: {

          [unowned self, unowned context] form in
          do {
            try DataManager.saveContext(context, withBlock: {
              if let category = PresetCategory.createWithForm(form, context: $0) { self.presetCategory = category }
              })
            return true
          } catch {
            logError(error)
            return false
          }
        })

      transactions.append(categoryTransaction)
      
    }

    return transactions
  }
}


// TODO: Fill out `FormCreatable` stubs
extension Preset: FormCreatable {

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

  - returns: Preset?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Preset? {
    if let name = form.values?["Name"] as? String { return Preset(name: name, context: context) } else { return nil }
  }

}