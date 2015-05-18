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

  static func formFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    typealias Field = FormViewController.Field

    var formFields: FormViewController.FieldCollection = [:]

    formFields["Name"]            = nameFormField(context: context)
    formFields["Manufacturer"]    = Manufacturer.pickerFormField(context: context)
    formFields["Port"]            = Field.Stepper(value: 1, min: 1, max: 3, step: 1)
    formFields["Network Device"]  = ITachDevice.pickerFormField(context: context)
    formFields["Always On"]       = Field.Switch(value: false)
    formFields["Input Powers On"] = Field.Switch(value: false)

    /**
    codeSet:       IRCodeSet?
    */

    return formFields
  }

  static func createWithFormValues(values: FormViewController.FieldValues, context: NSManagedObjectContext) -> Self? {
    return nil
  }

}