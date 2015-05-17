//
//  IRCodeSet+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import MoonKit
import CoreData

extension IRCodeSet: BankModelCollection {
  var itemType: CollectedModel.Type { return IRCode.self }
}

extension IRCodeSet: FormCreatable {
  static func formFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    return ["Name":FormViewController.Field.Text(initial: nil, placeholder: "The code set's name") {
      $0 != nil && !$0!.isEmpty && IRCodeSet.objectWithValue($0!, forAttribute: "name", context: context) == nil
      }]
  }
  static func createWithFormValues(values: FormViewController.FieldValues, context: NSManagedObjectContext) -> IRCodeSet? {
    if let name = values["Name"] as? String {
      let codeSet = IRCodeSet(context: context)
      codeSet.name = name
      return codeSet
    } else {
      return nil
    }
  }
}