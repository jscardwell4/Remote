//
//  ComponentDevice+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import CoreData
import MoonKit

extension ComponentDevice: Detailable {
  func detailController() -> UIViewController { return ComponentDeviceDetailController(model: self) }
}

extension ComponentDevice: FormCreatable {

  /**
  creationForm:

  :param: #context NSManagedObjectContext

  :returns: Form
  */
  static func creationForm(#context: NSManagedObjectContext) -> Form {

    var fields: OrderedDictionary<String, FieldTemplate> = [:]

    fields["Name"]            = nameFormFieldTemplate(context: context)
    fields["Manufacturer"]    = Manufacturer.pickerFormFieldTemplate(context: context)
    fields["Port"]            = .Stepper(value: 1, min: 1, max: 3, step: 1)
    fields["Network Device"]  = ITachDevice.pickerFormFieldTemplate(context: context)
    fields["Always On"]       = .Switch(value: false)
    fields["Input Powers On"] = .Switch(value: false)

    /**
    codeSet:       IRCodeSet?
    */

    return Form(templates: fields)
  }

  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Self? {
    return nil
  }

}