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
    return ["Name":FormViewController.Field.Text(initial: nil, placeholder: "The category's name") {
      $0 != nil && !$0!.isEmpty && PresetCategory.objectWithValue($0!, forAttribute: "name", context: context) == nil
      }]
  }
  static func createWithFormValues(values: FormViewController.FieldValues, context: NSManagedObjectContext) -> PresetCategory? {
    if let name = values["Name"] as? String {
      let category = PresetCategory(context: context)
      category.name = name
      return category
    } else {
      return nil
    }
  }
}