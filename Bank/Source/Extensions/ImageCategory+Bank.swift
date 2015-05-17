//
//  ImageCategory+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import MoonKit
import CoreData

extension ImageCategory: BankModelCollection {
  var itemType: CollectedModel.Type { return Image.self }
  var collectionType: ModelCollection.Type { return ImageCategory.self }
  var previewable: Bool { return true }
}


extension ImageCategory: FormCreatable {
  static func formFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    return ["Name":FormViewController.Field.Text(initial: nil, placeholder: "The category's name") {
      $0 != nil && !$0!.isEmpty && ImageCategory.objectWithValue($0!, forAttribute: "name", context: context) == nil
      }]
  }
  static func createWithFormValues(values: FormViewController.FieldValues, context: NSManagedObjectContext) -> ImageCategory? {
    if let name = values["Name"] as? String {
      let category = ImageCategory(context: context)
      category.name = name
      return category
    } else {
      return nil
    }
  }
}