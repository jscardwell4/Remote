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

  /**
  createWithForm:context:

  :param: form Form
  :param: context NSManagedObjectContext

  :returns: ComponentDevice?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> ComponentDevice? {
    MSLogDebug("\(form)")
    if let values = form.values,
      name = values["Name"] as? String,
      port = values["Port"] as? Double,
      alwaysOn = values["Always On"] as? Bool,
      inputPowersOn = values["Input Powers On"] as? Bool
    {
      let componentDevice = ComponentDevice(name: name, context: context)
      componentDevice.port = Int16(port)
      componentDevice.alwaysOn = alwaysOn
      componentDevice.inputPowersOn = inputPowersOn
      if let manufacturerName = values["Manufacturer"] as? String,
        manufacturer = Manufacturer.objectWithValue(manufacturerName, forAttribute: "name", context: context)
      {
        componentDevice.manufacturer = manufacturer
      }
      if let networkDeviceName = values["Network Device"] as? String,
        networkDevice = ITachDevice.objectWithValue(networkDeviceName, forAttribute: "name", context: context)
      {
        componentDevice.networkDevice = networkDevice
      }
      return componentDevice
    }
    return nil
  }

}