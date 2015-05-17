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
}

extension Manufacturer: Detailable {
  func detailController() -> UIViewController { return ManufacturerDetailController(model: self) }
}

extension Manufacturer: FormCreatable {
  static func formFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    return ["Name":FormViewController.Field.Text(initial: nil, placeholder: "The manufacturer's name") {
      $0 != nil && !$0!.isEmpty && Manufacturer.objectWithValue($0!, forAttribute: "name", context: context) == nil
      }]
  }
  static func createWithFormValues(values: FormViewController.FieldValues, context: NSManagedObjectContext) -> Manufacturer? {
    if let name = values["Name"] as? String {
      let manufacturer = Manufacturer(context: context)
      manufacturer.name = name
      return manufacturer
    } else {
      return nil
    }
  }
}