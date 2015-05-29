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
  var itemLabel: String { return "Code" }
}

extension IRCodeSet: FormCreatable {

  /**
  creationForm:

  :param: #context NSManagedObjectContext

  :returns: Form
  */
  static func creationForm(#context: NSManagedObjectContext) -> Form {

    var fields: OrderedDictionary<String, FieldTemplate> = [:]

    fields["Name"]         = nameFormFieldTemplate(context: context)
    fields["Manufacturer"] = Manufacturer.pickerFormFieldTemplate(context: context, optional: false)

    return Form(templates: fields)
  }

  static func createWithForm(form: Form, context: NSManagedObjectContext) -> IRCodeSet? {
    if let name = form.values?["Name"] as? String,
      manufacturerName = form.values?["Manufacturer"] as? String,
      manufacturer = Manufacturer.objectWithValue(manufacturerName, forAttribute: "name", context: context)
    {
      let codeSet = IRCodeSet(name: name, context: context)
      codeSet.manufacturer = manufacturer
      return codeSet
    } else { return nil }
  }
}