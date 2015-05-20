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

  /**
  creationForm:

  :param: #context NSManagedObjectContext

  :returns: Form
  */
  static func creationForm(#context: NSManagedObjectContext) -> Form {
    return Form(templates: OrderedDictionary<String, FieldTemplate>(["Name": nameFormFieldTemplate(context: context)]))
  }

  /**
  createWithForm:context:

  :param: form Form
  :param: context NSManagedObjectContext

  :returns: Manufacturer?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Manufacturer? {
    if let name = form.values?["Name"] as? String { return Manufacturer(name: name, context: context) }
    else { return nil }
  }

}