//
//  PresetCategory+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import MoonKit
import CoreData

extension PresetCategory: BankModelCollection {
  var itemType: CollectedModel.Type { return Preset.self }
  var collectionType: ModelCollection.Type { return PresetCategory.self }
  var previewable: Bool { return true }
}

extension PresetCategory: FormCreatable {

  static func formFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    return ["Name":FormViewController.Field.Text(value: "", placeholder: "The category's name") {
      $0 != nil && !$0!.isEmpty && PresetCategory.objectWithValue($0!, forAttribute: "name", context: context) == nil
      }]
  }

  static func createWithFormValues(values: FormViewController.FieldValues,
                                  context: NSManagedObjectContext) -> PresetCategory?
  {
    if let name = values["Name"] as? String { return PresetCategory(name: name, context: context) }
    else { return nil }
  }
}

extension PresetCategory: CreatableItemBankModelCollection {

  static func itemTypeFormFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    return Preset.formFields(context: context)
  }

  static func createItemTypeWithFormValues(values: FormViewController.FieldValues,
                                           context: NSManagedObjectContext) -> CollectedModel?
  {
    return Preset.createWithFormValues(values, context: context)
  }

}

extension PresetCategory: CreatableCollectionBankModelCollection {

  static func collectionTypeFormFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    return PresetCategory.formFields(context: context)
  }

  static func createCollectionTypeWithFormValues(values: FormViewController.FieldValues,
                                                 context: NSManagedObjectContext) -> ModelCollection?
  {
    return PresetCategory.createWithFormValues(values, context: context)
  }

}
